clear all

%% Preamble

% Define color palette
color_base = {[0 190 30]./255       %green
              [245 145 0]./255      %orange
              [0 100 200]./255      %blue
              [225 35 35]./255      %red
              [215 0 255]./255      %magenta
              [205 80 0]./255       %dark orange
              [120 0 245]./255      %purple
              [135 240 0]./255      %lime
              [255 210 0]./255      %yellow
              [0 0 0]./255          %black
              [237 133 255]./255  }; %violet;

pick_col = @(perc,idx) color_base{idx};

% loading the simulation data
load('workspace_reduced.mat');
N=10^7;

%% Picture generation

% axes scalings
xmod1=@(x) x./7;
ymod1=@(y) y;
xmod2=@(x) x./7;
ymod2=@(y) y./7;


% Duty cycle ranges
D = [[.1 .15];[.15 .2];[.2 .25];[.25 .3];[.3 .35];[.35 .4];[.4 .45];[.45 .5];[.5 .55];[.55 .6];[.6 .65]];

% Duty cycle markers
Markers = {'o','v','d','^','s','h','>','<','p','x','*','+','.'};



% creating the main figure
figure1=figure(1);

% creating the left, right and centre axes
axesL=subplot(1,2,1,'XTick',xmod1(7:7:133));
axesR=subplot(1,2,2,'YAxisLocation','right','XTick',xmod2(7:7:133),'YTick',ymod2(49:35:259));
axesC=axes('Parent',figure1,'Position',[0.39+.0954 0.22 0.08 0.3],'YAxisLocation','left','XTick',xmod1([14,21,28]));

box(axesL,'on');
box(axesR,'on');


% drawing the colored regions
 
% colors
RightCol =  [1 1 .9];     % yellow
LeftCol =  [.98 .89 .98]; % purple

% drawing the yellow region
patchX=xmod1([3.5 3.5 38.7 73.7 73.7 66.7 66.7 59.7 59.7 53.7 53.7 45.7 45.7 38.7 38.7 119+7/2 119+7/2 3.5]);
patchY=ymod1([0.1 1.0 01.0 3.58 14.5 14.5 18.2 18.2 22.7 22.7 27.2 27.2 32.3 32.3 59.8 59.8 000.1 0.1]);
patch(axesL,patchX,patchY,RightCol,'EdgeColor',.7*RightCol);

patchX=xmod2([03.5 7*7 119+7/2 119+7/2 03.5]);
patchY=ymod2([49.5 93 093 49.5 49.5]);
patch(axesR,patchX,patchY,RightCol,'EdgeColor',.7*RightCol);

% drawing the purple region
eps=1e-3;
patchX=xmod1([3.5 38.7-eps 73.7-eps 73.7-eps 66.7-eps 66.7-eps 59.7-eps 59.7-eps 53.7-eps 53.7-eps 45.7-eps 45.7-eps... 
              38.7-eps 38.7-eps 3.5 3.5]);
patchY=ymod1([1.0 1+eps 03.58+eps 14.5-eps 14.5-eps 18.2-eps 18.2-eps 22.7-eps 22.7-eps 27.2-eps 27.2-eps...
        32.3-eps 32.3-eps 47.8 47.8 1.2]);
patch(axesL,patchX,patchY,LeftCol,'EdgeColor',.7*LeftCol);

patchX=xmod2([03.5 90 035 003.5 03.5]);
patchY=ymod2([49.5 7*18 258.5 258.5 49.5]);
patch(axesR,patchX,patchY,LeftCol,'EdgeColor',.7*LeftCol);

 
% plotting the red circles on the centre image
hold(axesC,'on'); 
             plot(axesC,xmod1([14 21 28]),100/N*[peak(4,12) peak(7,16) peak(7,23)],'o',...
            'MarkerEdgeColor',[1 0 0],...
            'MarkerSize',14);


% auxiliary variables needed for the image legend        
LabV = zeros(size(D,1),1);
LabW = {[],{},[]};
ss = 0;        
        

% policies plot
for i = Interval_i1
    for j = Interval_i2
        
         
       
        %incrementing legend counter 
        ss=ss+1;       
        
        % policy's duty cycle and period
        dc = (i-1)/(i+j-2); 
        period = (i-1)*DayStep+(j-1)*DayStep;
        
        %skip if the period is not a multiple of 7 days
        if (period==0) || (mod(period,7)~=0)
            continue; 
        end
       
        
        % selecting the duty cycle range
        idx=[];
        for k=1:size(D,1) 
           
            if dc>= D(k,1) && dc<D(k,2) 
                idx=k; 
                break;
            end
            
        end 
         
        if isempty(idx)
            continue;
        end
        
        % pick policy color
        Col = pick_col(idx/size(D,1),idx); 
        
        
        % plot policy on the left image
        hold(axesL,'on'); 
        PP=plot(axesL,xmod1(period),ymod1(100/N*peak(i,j)),...
            'Marker',Markers{idx},...
            'MarkerFaceColor',Col,...
            'MarkerEdgeColor',0.6*Col,...
            'MarkerSize',7);  
        set(PP,'LineStyle','none');
        
        % plot policy on the right image
        hold(axesR,'on');
        NN=plot(axesR,xmod2(period),ymod2(peakTime(i,j)),...
            'Marker',Markers{idx},...
            'MarkerFaceColor',Col,...
            'MarkerEdgeColor',0.6*Col,...
            'MarkerSize',7);%,...
        set(NN,'LineStyle','none');
        
        %plot policies on the central exis
        if idx<=5
            hold(axesC,'on'); 
            plot(axesC,xmod1(period),100/N*peak(i,j),...
                'Marker',Markers{idx},...
                'MarkerFaceColor',Col,...
                'MarkerEdgeColor',0.6*Col,...
                'MarkerSize',7); 
        end
        
        % adding the label to the legend
        if LabV(idx,1)==0
            LabV(idx,1)=ss;
            LabW{1}=[LabW{1};PP]; 
            LabW{2}{length(LabW{2})+1}=sprintf('[%d%%, %d%%]',round(100*D(idx,1)),round(100*D(idx,2)));
            LabW{3}=[LabW{3};idx]; 
        end
        
    end
end
 


% axes labels
xlabel(axesL,'Period (weeks)');
ylabel(axesL,'Peak Value (percentage of 10 million)');
xlabel(axesR,'Period (weeks)');
ylabel(axesR,'Peak Time (weeks)');

% setting axes limits
ylim(axesC,[0.7 0.82])
xlim(axesC,xmod1([10 31.5]));
xlim(axesL,xmod1([3 119+7/2+.5]))
ylim(axesL,ymod1([0 60]));
xlim(axesR,xmod2([3 119+7/2+.52])) 
ylim(axesR,ymod2([49 259]));
 
box(axesC,'on');
box(axesL,'on');
box(axesR,'on');

% sort legend
LabV(LabV==0)=[];
[idx,idxidx] = sort(LabW{3});
idxidx=fliplr(idxidx')';
legend(axesR,LabW{1}(idxidx),LabW{2}{idxidx});

  
% draw zoom annotation
annotation(figure1,'arrow',[0.2076 0.4693],[0.1361 0.2934],'color','k','linewidth',1);
annotation(figure1,'rectangle',[0.153 0.1 0.0556 0.0361],'linewidth',1,'color','k');
annotation(figure1,'textbox',[0.4942 0.5292 0.0724 0.059],'String','Outer loop steady state','linestyle','none','linewidth',1);


 



