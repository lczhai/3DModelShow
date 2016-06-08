//
//  NewParser.m
//  ModelShow_Nic
//
//  Created by shining3d on 16/5/18.
//  Copyright © 2016年 shining3d. All rights reserved.
//

#import "NewParser.h"
#include <iomanip>
#include <iostream>
#include <fstream>
#include <sstream>
#include <stdio.h>
#include <iostream>
#include <fstream>
#include <string>
#include <vector>

using namespace std;

struct ModelData{
    float *squareVertexData;
    int facetNum;
    int size;
};


@implementation NewParser

vector<float> vertexVArray;
vector<string> temp;
size_t size;

float nX = 0.0f,nY = 0.0f,nZ = 0.0f;
float vX = 0.0f,vY = 0.0f,vZ = 0.0f;
vector<string> vLines,vtLines,vnLines;
vector<string> vinfoV,indexV;
float *squareVertexData;
int facetNum;


const int FACET_ROW_SIZE = 7;
const int NORMAL_ROW = 1;
const int VERTEX_ROW = 3;
const int BINARRY_HEADER_INFO_SIZE = 80;
const int BINARRY_FACET_SIZE = 50;
const string OBJ_ANO = "#";
const string OBJ_VERTEX = "v";//顶点
const string OBJ_TEXTURE = "vt";//贴图
const string OBJ_NORMAL = "vn";//法线
const string OBJ_FACET = "f";//面




//字符串分割函数
std::vector<std::string> split(std::string str,std::string pattern)
{
    std::string::size_type pos;
    std::vector<std::string> result;
    str+=pattern;//扩展字符串以方便操作
    int size=str.size();
    for(int i=0; i<size; i++)
    {
        pos=str.find(pattern,i);
        if(pos<size)
        {
            std::string s=str.substr(i,pos-i);
            result.push_back(s);
            i=pos+pattern.size()-1;
        }
    }
    return result;
}


//追加normal法向量信息
void appendNormal(float x,float y,float z){
    vertexVArray.push_back(x);
    vertexVArray.push_back(y);
    vertexVArray.push_back(z);
}

//没有纹理时添加默认值
void appendEmptyVt(){
    vertexVArray.push_back(1.0);
    vertexVArray.push_back(1.0);
}

//解析normal、vertex
void parseLine(string line,bool isVertex){
    temp = split(line, " ");
    size = temp.size();
    if(size!=string::npos&&size>=3){
        if(isVertex){
            vX = atof(temp[size-3].c_str());
            vY = atof(temp[size-2].c_str());
            vZ = atof(temp[size-1].c_str());
            vertexVArray.push_back(vX);
            vertexVArray.push_back(vY);
            vertexVArray.push_back(vZ);
        }else{
            nX = atof(temp[size-3].c_str());
            nY = atof(temp[size-2].c_str());
            nZ = atof(temp[size-1].c_str());
        }
    }
    
}

//检验当前行是否为vertex
bool isVertex(int row){
    return (row%FACET_ROW_SIZE==VERTEX_ROW)||
    (row%FACET_ROW_SIZE==VERTEX_ROW+1)||
    (row%FACET_ROW_SIZE==VERTEX_ROW+2);
}

//检验当前行是否为vertex
bool isNormal(int row){
    return row%FACET_ROW_SIZE==NORMAL_ROW;
}

void vectorTofloat(){
    cout<<"vertexArray size:"<<vertexVArray.size()<<endl;
    squareVertexData = (float *)malloc(vertexVArray.size()*sizeof(float));
    for (int i = 0; i < vertexVArray.size(); i++) {
        squareVertexData[i] = vertexVArray[i];
    }
}

//解析ascii stl
ModelData parseAscii(string filePath){
    cout<<"parseAscii begin"<<endl;
    ModelData modelData;
    //以只读的方式打开文件
    ifstream fin;
    fin.open(filePath,ios::in);
    if(fin.good()){
        int row = 0;
        bool isVertexRow,isNormalRow;
        string line;
        while(!fin.eof()){//一直读，直到结束
            isVertexRow = isVertex(row);
            isNormalRow = isNormal(row);
            getline(fin, line);
            if(isVertexRow){
                parseLine(line,true);
                appendNormal(nX, nY, nZ);
                appendEmptyVt();
            }else if(isNormalRow){
                parseLine(line,false);
            }
            row++;
        }
        
        facetNum = (row-2)/7;
        vectorTofloat();
        
        cout<<"facet num:"<<facetNum<<endl;
    }
    modelData = {squareVertexData,facetNum,(int)vertexVArray.size()};
    vertexVArray.clear();
    cout<<"parseAscii end"<<endl;
    fin.close();
    return modelData;
}

//解析二进制
ModelData parseBinary(string filePath){
    cout<<"parseBinary begin"<<endl;
    ModelData modelData;
    //以只读的方式打开文件
    ifstream fin;
    fin.open(filePath,ios::in|ios::binary);
    float normalAndvertexs[ 12 ];
    int facetNums[1];
    int startIndex;
    char info[2];
    if(fin.good()){
        //跳过头部信息部分
        fin.seekg(BINARRY_HEADER_INFO_SIZE);
        fin.read(reinterpret_cast <char*> (&facetNums), sizeof( facetNums ) );
        facetNum = facetNums[0];
        cout<<"facetNum:"<<facetNum<<endl;
        for(int curFacet = 0;curFacet < facetNum;curFacet++){
            //读取12个float，1个normal，3个vertex
            fin.read(reinterpret_cast <char*> (&normalAndvertexs), sizeof( normalAndvertexs ) );
            //两个字节的其他
            fin.read(info,sizeof(info));
            //解析normal
            nX = normalAndvertexs[0];
            nY = normalAndvertexs[1];
            nZ = normalAndvertexs[2];
            //解析vertex
            for(int i = 1 ; i <= 3; i++){
                startIndex = 3 * i;
                vX = normalAndvertexs[startIndex];
                vY = normalAndvertexs[startIndex+1];
                vZ = normalAndvertexs[startIndex+2];
                vertexVArray.push_back(vX);
                vertexVArray.push_back(vY);
                vertexVArray.push_back(vZ);
                appendEmptyVt();
                appendNormal(nX,nY,nZ);
            }
        }
        
    }
    vectorTofloat();
    modelData = {squareVertexData,facetNum, (int)vertexVArray.size()};
    cout<<"parseBinary end"<<endl;
    fin.close();
    vertexVArray.clear();
    return modelData;
    
}

//todo  判断stl是二进制还是ascii，看看是否可以改进
ModelData parseStl(string filePath){
    ModelData modelData;
    int c;
    ifstream fin(filePath);
    while((c = fin.get()) != EOF && c <= 127);
    if(c == EOF) {//ascii
        cout<<"stl is ascii"<<endl;
        modelData = parseAscii(filePath);
    }else{//binary
        cout<<"stl is binary"<<endl;
        modelData = parseBinary(filePath);
    }
    fin.close();
    cout<<"float size:"<<sizeof(modelData.squareVertexData)<<endl;
    return modelData;
}

//解析obj的vt纹理
void parseObjTexture(int index){
    size = vtLines.size();
    if(size==0){
        appendEmptyVt();
    }else{
        string line = vtLines[index];
        if(!line.empty()){
            temp = split(line, " ");
            size = temp.size();
            if(size!=string::npos&&size>=2){
                vertexVArray.push_back(atof(temp[size-2].c_str()));
                vertexVArray.push_back(atof(temp[size-1].c_str()));
            }
        }
    }
}

//解析obj的v和vn
void parseObjVertexOrNormal(int index,bool isVertex){
    string line = isVertex?vLines[index]:vnLines[index];
    if(!line.empty()){
        temp = split(line, " ");
        size = temp.size();
        if(size!=string::npos&&size>=3){
            vertexVArray.push_back(atof(temp[size-3].c_str()));
            vertexVArray.push_back(atof(temp[size-2].c_str()));
            vertexVArray.push_back(atof(temp[size-1].c_str()));
        }
    }
}

//解析obj面
void parseObjFacet(string line){
    vinfoV = split(line, " ");
    size = vinfoV.size();
    if(size!=string::npos&&size>=3){
        for(int i = 1; i < size; i++){
            indexV = split(vinfoV[i],"/");
            size = indexV.size();
            if(size!=string::npos&&size==3){
                //vertex
                parseObjVertexOrNormal(atoi(indexV[0].c_str())-1,true);
                //vn
                parseObjVertexOrNormal(atoi(indexV[2].c_str())-1,false);
                //vt
//                parseObjTexture(atoi(indexV[1].c_str()));
                vertexVArray.push_back(1);
                vertexVArray.push_back(1);
            }
        }
        line.clear();
        facetNum++;
    }
}


void parseObjLine(string line){
    if(line.find(OBJ_ANO)==0||line.empty()){
        return;
    }else if(line.find(OBJ_NORMAL)==0){
        vnLines.push_back(line);
    }else if(line.find(OBJ_TEXTURE)==0){
        vtLines.push_back(line);
    }else if(line.find(OBJ_VERTEX)==0){
        vLines.push_back(line);
    }else if(line.find(OBJ_FACET)==0){
        parseObjFacet(line);
    }
}

//解析obj
ModelData parseObj(string filePath){
    ModelData modelData;
    ifstream is;
    is.open(filePath,ios::in);
    facetNum = 0;
    if(is.good()){
        string line;
        int lineFeedIndex = -1;
        while(!is.eof()){
            getline(is, line);
            lineFeedIndex = line.find("\r");
            if(lineFeedIndex!=string::npos){
                line = line.replace(line.end()-1,line.end(),"");
            }
            parseObjLine(line);
            line.clear();
        }
        vLines.clear();
        vtLines.clear();
        vnLines.clear();
        vectorTofloat();
    }
    
    modelData = {squareVertexData,facetNum, (int)vertexVArray.size()};
    is.close();
    vertexVArray.clear();
    cout<<"facetNum: "<<facetNum<<endl;
    cout<<"parseObj end"<<endl;
    return modelData;
}


+ (NSValue *)getParserDataWithFile:(NSString *)path
{
    string newpath = [path UTF8String];
    
    ModelData pro = parseObj(newpath);
    
    
   
    //结构体转NSValue
    NSValue *value = [NSValue valueWithBytes:&pro objCType:@encode(ModelData)];

    
    return value;
}



@end
