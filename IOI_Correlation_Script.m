clear
clc
% Minimum Threshold where intereference level is important 
hurdle=input('Please enter the 2G DCR Hurdle= ');
peaks_number=input('Please enter the leniency (1-10) = ');

%% Import of CSV data , IOI excel file where it has Interference levels (IOI3+4, IOI5), Drop Call Rate 
[IOI3,~]=xlsread('IOI.xlsx','Report 1','E2:E13000'); % to save IOI3+4
[IOI5,~]=xlsread('IOI.xlsx','Report 1','D2:D13000'); % to save IOI5
[DCR,~]=xlsread('IOI.xlsx','Report 1','C2:C13000'); % to save DCR
[~,Cells]=xlsread('IOI.xlsx','Report 1','A2:A13000'); % to save Cells
 IOI3_Peaks=[];
 IOI5_Peaks=[];
 DCR_Peaks=[];
 IOI3_Peaks_Time=[]; % Peaks' date of IOI3
 IOI5_Peaks_Time=[];% Peaks' date of IOI5
 DCR_Peaks_Time=[];
 C3=[]; % Number of IOI 3 correlatred peaks
 C5=[]; % Number of IOI 5 correlatred peaks
 TH3=[];% Number of times peaks exceeding IOI3> 30
 TH5=[];% Number of times peaks exceeding IOI5> 3
 DCR_TH=[];% Number of times peaks exceeding DCR> 0.4
 peaks_number;
 hurdle;
%% KPIs preprocessing for NAN values 
DCR(isnan(DCR))=0;
IOI3(isnan(IOI3))=0;
IOI5(isnan(IOI5))=0;


%% Peak detection 
% IOI3+4 Detection 
for i=2:length(IOI3)-1
    
    if IOI3(i-1) < IOI3(i) && IOI3(i+1) <IOI3(i) 
        IOI3_Peaks(i)=IOI3(i);
        IOI3_Peaks_Time(i)=i;
    end  
end
IOI3_Peaks=transpose(IOI3_Peaks);
IOI3_Peaks_Time=transpose(IOI3_Peaks_Time);

% IOI5 Detection
for i=2:length(IOI5)-1
    if IOI5(i-1) < IOI5(i) && IOI5(i+1) <IOI5(i) 
        IOI5_Peaks(i)=IOI5(i);
        IOI5_Peaks_Time(i)=i;
    end    
end
IOI5_Peaks=transpose(IOI5_Peaks);
IOI5_Peaks_Time=transpose(IOI5_Peaks_Time);

% DCR Detection 
for i=2:length(DCR)-1
    if DCR(i-1) < DCR(i) && DCR(i+1) < DCR(i) 
        DCR_Peaks(i)=DCR(i);
        DCR_Peaks_Time(i)=i;
       
       
    end    
end
DCR_Peaks=transpose(DCR_Peaks);
DCR_Peaks_Time=transpose(DCR_Peaks_Time);

%% Getting cell names 
% Getting number of duplications
[b,i,j]=unique(Cells,'first');
CellsUnique=Cells(sort(i)); % to remove duplications from the array
str = [];
double it=[];
for i=1:numel(CellsUnique)
    numDuplicates = sum(strcmp(CellsUnique(i),Cells));
    it(i)=numDuplicates;  
end
it=transpose(it);




%% Array padding 
 % matching lengths of the arrays
delta= length(DCR_Peaks)- length(IOI3_Peaks);
length1=length(IOI3_Peaks);
length2=length(IOI3_Peaks_Time);
if delta ~=0    
    for i=1:length(delta)
      
       IOI3_Peaks(length1+i)=0;
       IOI3_Peaks_Time(length2+i)=0;
       
        
    end
end

delta= length(IOI3_Peaks)- length(DCR_Peaks);
length1=length(DCR_Peaks);
length2=length(DCR_Peaks_Time);
if delta ~=0    
    for i=1:length(delta)
      
       DCR_Peaks(length1+i)=0;
       DCR_Peaks_Time(length2+i)=0;
       
        
    end
end

delta= length(IOI5_Peaks)- length(DCR_Peaks);
length1=length(DCR_Peaks);
length2=length(DCR_Peaks_Time);
if delta ~=0    
    for i=1:length(delta)
      
       DCR_Peaks(length1+i)=0;
       DCR_Peaks_Time(length2+i)=0;
       
        
    end
end
 
delta= length(DCR_Peaks)- length(IOI5_Peaks);
length1=length(IOI5_Peaks);
length2=length(IOI5_Peaks_Time);
if delta ~=0    
    for i=1:length(delta)
      
       IOI5_Peaks(length1+i)=0;
       IOI5_Peaks_Time(length2+i)=0;
       
        
    end
end
 A=[ length(DCR_Peaks),length(IOI3_Peaks),length(IOI5_Peaks)];
minimum=min(A);
DCR_Peaks=DCR_Peaks(1:minimum);
DCR_Peaks_Time=DCR_Peaks_Time(1:minimum);
IOI3_Peaks=IOI3_Peaks(1:minimum);
IOI3_Peaks_Time=IOI3_Peaks_Time(1:minimum);
IOI5_Peaks=IOI5_Peaks(1:minimum);
IOI5_Peaks_Time=IOI5_Peaks_Time(1:minimum);

%% Criteria X1 - check the coinciding peaks of DCR with IOI3+4 or IOI5
% X1 - Correlation check
for i=1:length(IOI3_Peaks)
     
    
    if DCR_Peaks_Time(i)== IOI3_Peaks_Time(i) && DCR_Peaks_Time(i) > 0
        C3(i)=1;
    
    else 
        C3(i)=0;
        
    end    
end
for i=1:length(IOI5_Peaks)
    
    if i >  (length(IOI5_Peaks))
        break;
        
    end
    
    if DCR_Peaks_Time(i)== IOI5_Peaks_Time(i) && DCR_Peaks_Time(i) > 0
        C5(i)=1;
    
    else 
        C5(i)=0;
        
    end    
end
% Number of simultanous peaks detected between DCR and IOI3+4
C3=transpose(C3);
% Number of simultanous peaks detected between DCR and IOI5
C5=transpose(C5);

% X1 - Correlation check
X13=[]; % Correlation for IOI3
X15=[]; % Correlation for IOI5
temp=0;
tempc=0;
check_point=1;
for i=1:length(CellsUnique)
    
    if  check_point > length(C3) 
      break;
    end
    
    for j=1:it(i)
        
         if  check_point > length(C3) 
      break;
          end
       if C3(check_point) ==1
       temp=temp+1;    
       end
        
       if check_point > length(C5)
        continue;
        
        else
            if C5(check_point) == 1 
            tempc=tempc+1;
            end
         end
       
       check_point=check_point+1;   
    end
   X13(i)=temp;
   X15(i)=tempc;
   temp=0;
   tempc=0;
  
end


%% Criteria X2 - Checking if IOI3+4 and IOI5  are above the Threshholds

% IOI3+4 Peaks must be higher than 30 
for i=1:length(IOI3_Peaks)
    
    if  IOI3_Peaks(i) >= 30
        TH3(i)=1;
    
    else 
        TH3(i)=0;
        
    end    
end
% X3 - Checking Threshholds

% IOI5 Peaks must be higher than 30 
for i=1:length(IOI5_Peaks)
    
    if  IOI5_Peaks(i) >= 3
        TH5(i)=1;
    
    else 
        TH5(i)=0;
        
    end    
end
% X4 - Checking Threshholds

% DCR Peaks must be higher than the Hurdle 
for i=1:length(DCR_Peaks)
    
    if  DCR_Peaks(i) >= hurdle
        DCR_TH(i)=1;
    
    else 
        DCR_TH(i)=0;
        
    end    
end
TH3=transpose(TH3);
TH5=transpose(TH5);
DCR_TH=transpose(DCR_TH);



check_point=1; % Cursor for not repeating cell check again
X2=[];
X3=[];
X4=[];
temp2=0;
temp3=0;
temp4=0;
for i=1:length(CellsUnique)
    
    if check_point > length(TH3)
        break;
    end
    
    for j=1:it(i)
        
        if check_point > length(TH3)
        break;
        end
    
        if TH3(check_point) == 1
            temp2=temp2+1;
        end
         if check_point > length(TH5)
        continue;
        
        else
            if TH5(check_point) == 1 
            temp3=temp3+1;
            end
         end
         
         if DCR_TH(check_point) == 1
            temp4=temp4+1;
         end
         check_point=check_point+1;   
    end
   X2(i)=temp2;
   X3(i)=temp3;
   X4(i)=temp4;
   temp2=0;
   temp3=0;
   temp4=0;
       
end
%% Criteria X5 - check if the Intereference trend is continuous 
% X5 - continuous IOI
check_point=1;
temp5=0;
for i=1: length(CellsUnique)
    
    
    if (check_point+1) > length(IOI3) 
     break;
     end
     
    for j=1:it(i)-1
        
    if (check_point+1) > length(IOI3) 
     break;
     end
       
      
     if abs(IOI3(check_point)- IOI3(check_point+1)) <= 2 && IOI3(check_point) > 30 
         temp5=temp5+1;
     end
     if j == it(i)-1
     check_point=check_point+2;
     
     else
        check_point=check_point+1;
          
     end
    end
    X5(i)=temp5;
    temp5=0;
    
    if (check_point+1) > length(IOI3) 
   break;
     end
      
end
%% Criteria X6 - check if the DCR trend is continuous 
% X6 - Continuous DCR
X6=[];
check_point=1;
temp6=0;
for i=1: length(CellsUnique)
    
    if check_point+1 > length(DCR) 
    break;
     end
    for j=1:it(i)-1
     if abs(DCR(check_point)- DCR(check_point+1)) <= 0.05 && DCR(check_point) > hurdle 
         temp6=temp6+1;
     end
     if j == it(i)-1
     check_point=check_point+2;
     else
        check_point=check_point+1; 
     end
     
     if check_point+1 > length(DCR) 
    break;
     end
     
    end
    X6(i)=temp6;
    temp6=0;
    if check_point+1 > length(DCR) 
    break;
     end

end


%% Criteria X7 - check if the DCR trend is correlated with IOI3+4 or IOI5
% X7 - Utter correlation without thresholds

sum1=0;
sum2=0;
sum3=0;
dum1=0;
dum2=0;
dum3=0;
fum1=0;
fum2=0;
fum3=0;
span=0;
check_point=1;
I3=[];
I5=[];
D=[];
c=1;
for i=1: length(CellsUnique)

    sum1=0;
    sum2=0;
    sum3=0;
    dum1=0;
    dum2=0;
    dum3=0;
    fum1=0;
    fum2=0;
    fum3=0;
    span= fix(it(i)/3);
    
    for j=1:span
       
    sum1=sum1+IOI3(check_point);
    sum2=sum2+IOI3(check_point+span);
    sum3=sum3+IOI3(check_point+(2*span));
    
    fum1=fum1+IOI5(check_point);
    fum2=fum2+IOI5(check_point+span);
    fum3=fum3+IOI5(check_point+(2*span));
    
    dum1=dum1+DCR(check_point);
    dum2=dum2+DCR(check_point+span);
    dum3=dum3+DCR(check_point+(2*span));
    
    check_point = check_point +1;
    end
    check_point= check_point+(2*span);
    sum1=sum1/span;
    sum2=sum2/span;
    sum3=sum3/span;
    dum1=dum1/span;
    dum2=dum2/span;
    dum3=dum3/span;
    fum1=fum1/span;
    fum2=fum2/span;
    fum3=fum3/span;
    
    
    I3(c)=sum1;
    I3(c+1)=sum2;
    I3(c+2)=sum3;
    
    I5(c)=fum1;
    I5(c+1)=fum2;
    I5(c+2)=fum3;
    
    D(c)=dum1;
    D(c+1)=dum2;
    D(c+2)=dum3;
    c=c+3;
   
      
   
end

I3_Peaks=[];
I3_Peaks_Time=[];
I5_Peaks=[];
I5_Peaks_Time=[];
D_Peaks=[];
D_Peaks_Time=[];


% X7 peaks' detection 
for i=2:length(I3)-1
    
    if I3(i-1) < I3(i) && I3(i+1) <I3(i) 
        I3_Peaks(i)=I3(i);
        I3_Peaks_Time(i)=i;
    end  
    
    if I3(i-1) > I3(i) && I3(i+1) > I3(i) 
        I3_Peaks(i)=I3(i);
        I3_Peaks_Time(i)=-i;
    end  
end
for i=2:length(I5)-1
    
    
    
    if I5(i-1) < I5(i) && I5(i+1) <I5(i) 
        I5_Peaks(i)=I5(i);
        I5_Peaks_Time(i)=i;
    end  
    
    if I5(i-1) > I5(i) && I5(i+1) > I5(i) 
        I5_Peaks(i)=I5(i);
        I5_Peaks_Time(i)=-i;
    end  
end
for i=2:length(D)-1
    
    if D(i-1) < D(i) && D(i+1) <D(i) 
        D_Peaks(i)=I3(i);
        D_Peaks_Time(i)=i;
    end  
    
    if D(i-1) > D(i) && D(i+1) > D(i) 
        D_Peaks(i)=I3(i);
        D_Peaks_Time(i)=-i;
    end  
end

 % matching lengths of the arrays
delta= length(D_Peaks)- length(I5_Peaks);
length1=length(I5_Peaks);
length2=length(I5_Peaks_Time);

% Working here I5 not same length as I3 and DCR
if delta ~=0    
    for i=1:length(delta)+1
       I5_Peaks(length1+i)=0;
       I5_Peaks_Time(length2+i)=0;
     
    end
end
 
delta= length(D_Peaks)- length(I3_Peaks);
length1=length(I3_Peaks);
length2=length(I3_Peaks_Time);

if delta ~=0    
    for i=1:length(delta)+1
       I3_Peaks(length1+i)=0;
       I3_Peaks_Time(length2+i)=0;
      
    end
 end

X7=[];
check_point=1;
for i=1:length(CellsUnique)
    
    if check_point+2 >  min(length(I3_Peaks_Time),length(I5_Peaks_Time))
        break;
        
    end
    

      if check_point+2 > length(D_Peaks_Time)
          break;
      end
      
        if D_Peaks_Time(check_point)+D_Peaks_Time(check_point+1)+D_Peaks_Time(check_point+2) == I3_Peaks_Time(check_point)+I3_Peaks_Time(check_point+1)+I3_Peaks_Time(check_point+2)
           X7(i)=1;   
        
        
        elseif D_Peaks_Time(check_point)+D_Peaks_Time(check_point+1)+D_Peaks_Time(check_point+2) == I5_Peaks_Time(check_point)+I5_Peaks_Time(check_point+1)+I5_Peaks_Time(check_point+2)
           X7(i)=1; 
           
        else
            X7(i)=0;
        end
        
            
    check_point=check_point+3;    
   
end

%% Criterion check for each cell 
 Final=[];
% X13: DCR & IOI3
% X15: DCR & IOI5
% X2  : IOI 3 > 30
% X3  : IOI 5 > 3
% X4  : DCR > hurdle

for i=1:length(CellsUnique)
    
    
        
      if ((X13(i) >= peaks_number || X15(i) >= peaks_number) && ((X2(i) >= peaks_number || X3(i) >= peaks_number) && (X4(i) >= peaks_number)))
          Final(i)= 1;
      
      elseif  ((X5(i) >= 5) && ((X15(i) >= 5) && (X4(i) >= 5) ))
           Final(i)= 1;
      
      elseif ((X5(i) >= peaks_number) && ((X15(i) < peaks_number) && (X6(i) >= peaks_number)))
          Final(i)= 1; 
    
      else  
         Final(i)= 0;
    end
    if i > length(X7) 
        continue;
    if ((X7(i) == 1) && ((X2(i) >= peaks_number || X3(i) >= peaks_number) && (X4(i) >= peaks_number)))
        Final(i)=1;
    end
    end
    
    
end

Final=transpose(Final);

ok=0;
NOK=0;

for i=1:length(Final)
    
    if Final(i) ==1
        ok=ok+1;
        
    else 
        NOK=NOK+1;
        
    end
    
    
end

%% Saving the KPIs Benchmark 
Dim1 = size(CellsUnique);
Dim2 = size(Final);
Range1 = ['A1:',strrep([char(64+floor(Dim1(2)/26)),char(64+rem(Dim1(2),26))],'@',''),num2str(Dim1(1))]; % Range required for data1
Range2= ['B1:',strrep([char(64+floor(Dim2(2)/26)),char(64+rem(Dim2(2),26))],'@',''),num2str(Dim2(1))];

xlswrite( 'Cell and IOI correlation', Final, 'sheet1', Range2);

xlswrite( 'Cell and IOI correlation', CellsUnique, 'sheet1', Range1);

OK=[' OK Cases: ',num2str(ok),' / ',num2str(ok+NOK)];
disp(OK);
NOKK=[' NOK Cases: ',num2str(NOK),' / ',num2str(ok+NOK)];
disp(NOKK);

disp(' -------Done By Yasir Shihab, Thank you---------');
