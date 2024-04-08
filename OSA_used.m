clear all;
clc;

%%%%%%%%%%%%%%%%%%%%光谱仪连接控制
hOSA=visa('ni','GPIB0::0::INSTR');
set(hOSA,'InputBufferSize',400000);
set(hOSA,'OutputBufferSize',400000);
fopen(hOSA);
fprintf(hOSA,'*IDN?');
instrument_id = fscanf(hOSA);
disp(instrument_id);

%%%%%%%%%%%%%%%%%%%%设置光谱仪测量参数
fprintf(hOSA,[ '*RST']);%Setting initialize
fprintf(hOSA,[ 'CFORM1']);%Command mode set(AQ637X mode)
fprintf(hOSA,['sens:wav:cent 1550nm']);%sweep center wl
fprintf(hOSA,[ ':mmem:stor:grap col,bmp,"center",ext']);% Save bmp file to extra memory
fprintf(hOSA,['sens:wav:span 1nm']);%sweep span
fprintf(hOSA,[ ':mmem:stor:grap col,bmp,"span",ext']);
fprintf(hOSA,['sens:sens mid']);%sens mode = MID
fprintf(hOSA,[ ':mmem:stor:grap col,bmp,"sens",ext']);
fprintf(hOSA,['sens:sweep:points:auto on']);%Sampling Point = AUTO
fprintf(hOSA,[ ':mmem:stor:grap col,bmp,"samplingpoint",ext']);
fprintf(hOSA,['sens:bwid:res 0.02nm']);%resolution
fprintf(hOSA,[ ':mmem:stor:grap col,bmp,"resolution",ext']);

%%%%%%%%%%%%%%%%%%%%光谱仪执行扫描
fprintf(hOSA,[ ':init:smode 1']);%single sweep mode
fprintf(hOSA,[ '*CLS']);%status clear
fprintf(hOSA,[ ':init']);%sweep start
fprintf(hOSA,[ ':mmem:stor:grap col,bmp,<"sweep">,ext']);

%%%%%%%%%%%%%%%%%%%%分析并捕捉分析结果
fprintf(hOSA,[ ':calc:mark:max']);%Detects a peak and places the moving marker on that peak.
fprintf(hOSA,[ ':mmem:stor:grap col,bmp,"peaksearch",ext']);

fprintf(hOSA,[ ':calc:par:cat:swth 3db']);%Spectrum width analysis (THRESH type)
fprintf(hOSA,[ ':calc']);% Analysis Execute
fprintf(hOSA,[ ':calc:data?']);% get data
strData=fscanf(hOSA);
ThreeDB=str2num(strData);
fprintf(hOSA,[ ':mmem:stor:grap col,bmp,"threedb",ext']);

fprintf(hOSA,[ ':calc:cat smsr']);%Side-Mode Suppression Ratio analysis
fprintf(hOSA,[ ':calc']);
fprintf(hOSA,[ ':calc:data?']);
strData=fscanf(hOSA);
SMSR=str2num(strData);
fprintf(hOSA,[ ':mmem:stor:grap col,bmp,"smsr",ext']);

fprintf(hOSA,[ ':mmemory:rem']);%REMOVE USB STORAGE

%%%%%%%%%%%%%%%%%%%%输出结果到屏幕上
result=msgbox({['PEAK WL : ' num2str(SMSR(1,1)) ' m' ] ['Peak Power : ' num2str(SMSR(1,2)) ' dBm'] ['3dB SW : ' num2str(ThreeDB(1,2)) ' Hz'] ['SMSR  : ' num2str(SMSR(1,6)) ]},'results');

fclose(hOSA);

