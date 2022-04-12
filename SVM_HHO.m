
function [model,Rabbit_Location,CNVG]=SVM_HHO(N,T,lb,ub,dim,fobj)

disp('HHO is now tackling your problem')
tic
% initialize the location and Energy of the rabbit
Rabbit_Location=zeros(1,dim);
Rabbit_Energy=inf;

%Initialize the locations of Harris' hawks
X=initialization(N,dim,ub,lb);

CNVG=zeros(1,T);
model=[];
t=0; % Loop counter

while t<T
    for i=1:size(X,1)
        % Check boundries
        FU=X(i,:)>ub;
        FL=X(i,:)<lb;
        X(i,:)=(X(i,:).*(~(FU+FL)))+ub.*FU+lb.*FL;

        % fitness of locations
        [fitness,svm_model]=fobj(X(i,:));
        % Update the location of Rabbit
        if fitness<Rabbit_Energy
            Rabbit_Energy=fitness;
            Rabbit_Location=X(i,:);
            model=svm_model;
        end
    end
    
    E1=2*(1-(t/T)); % factor to show the decreaing energy of rabbit
    % Update the location of Harris' hawks
    for i=1:size(X,1)
        E0=2*rand()-1; %-1<E0<1
        Escaping_Energy=E1*(E0);  % escaping energy of rabbit
        
        if abs(Escaping_Energy)>=1
            %% Exploration:
            % Harris' hawks perch randomly based on 2 strategy:
            
            q=rand();
            rand_Hawk_index = floor(N*rand()+1);
            X_rand = X(rand_Hawk_index, :);
            if q<0.5
                % perch based on other family members
                X(i,:)=X_rand-rand()*abs(X_rand-2*rand()*X(i,:));
            elseif q>=0.5
                % perch on a random tall tree (random site inside group's home range)
                X(i,:)=(Rabbit_Location(1,:)-mean(X))-rand()*((ub-lb)*rand+lb);
            end
            
        elseif abs(Escaping_Energy)<1
            %% Exploitation:
            % Attacking the rabbit using 4 strategies regarding the behavior of the rabbit
            
            %% phase 1: surprise pounce (seven kills)
            % surprise pounce (seven kills): multiple, short rapid dives by different hawks
            
            r=rand(); % probablity of each event
            
            if r>=0.5 && abs(Escaping_Energy)<0.5 % Hard besiege
                X(i,:)=(Rabbit_Location)-Escaping_Energy*abs(Rabbit_Location-X(i,:));
            end
            
            if r>=0.5 && abs(Escaping_Energy)>=0.5  % Soft besiege
                Jump_strength=2*(1-rand()); % random jump strength of the rabbit
                X(i,:)=(Rabbit_Location-X(i,:))-Escaping_Energy*abs(Jump_strength*Rabbit_Location-X(i,:));
                  FU=X(i,:)>ub;
                     FL=X(i,:)<lb;
                    X(i,:)=(X(i,:).*(~(FU+FL)))+ub.*FU+lb.*FL;

            end
            X=abs(X);
            %% phase 2: performing team rapid dives (leapfrog movements)
            if r<0.5 && abs(Escaping_Energy)>=0.5, % Soft besiege % rabbit try to escape by many zigzag deceptive motions
                
                Jump_strength=2*(1-rand());
                X1=(Rabbit_Location-Escaping_Energy*abs(Jump_strength*Rabbit_Location-X(i,:)));
                  FU=X1>ub;
        FL=X1<lb;
        X1=(X1.*(~(FU+FL)))+ub.*FU+lb.*FL;

                X1=abs(X1);
                if fobj(X1)<fobj(X(i,:)) % improved move?
                    X(i,:)=X1;
                else % hawks perform levy-based short rapid dives around the rabbit
                    X2=Rabbit_Location-Escaping_Energy*abs(Jump_strength*Rabbit_Location-X(i,:))+rand(1,dim).*Levy(dim);
                    FU=X2>ub;
        FL=X2<lb;
        X2=(X2.*(~(FU+FL)))+ub.*FU+lb.*FL;

                    X2=abs(X2);
                    if (fobj(X2)<fobj(X(i,:))), % improved move?
                        X(i,:)=X2;
                    end
                end
            end
            
            if r<0.5 && abs(Escaping_Energy)<0.5, % Hard besiege % rabbit try to escape by many zigzag deceptive motions
                % hawks try to decrease their average location with the rabbit
                Jump_strength=2*(1-rand());
                X1=Rabbit_Location-Escaping_Energy*abs(Jump_strength*Rabbit_Location-mean(X));
                  FU=X1>ub;
        FL=X1<lb;
        X1=(X1.*(~(FU+FL)))+ub.*FU+lb.*FL;

                X1=abs(X1);
                X=abs(X);
                if fobj(X1)<fobj(X(i,:)) % improved move?
                    X(i,:)=X1;
                else % Perform levy-based short rapid dives around the rabbit
                    X2=Rabbit_Location-Escaping_Energy*abs(Jump_strength*Rabbit_Location-mean(X))+rand(1,dim).*Levy(dim);
                      FU=X2>ub;
        FL=X2<lb;
        X2=(X2.*(~(FU+FL)))+ub.*FU+lb.*FL;

                    X2=abs(X2);
                    if (fobj(X2)<fobj(X(i,:))), % improved move?
                        X(i,:)=X2;
                    end
                end
            end
            %%
        end
        
    end
                t=t+1;

    CNVG(t)=Rabbit_Energy;
    fprintf('iteration = %d, best fitness = %d\n',t,CNVG(t))

end
toc
end

% ___________________________________
function o=Levy(d)
beta=1.5;
sigma=(gamma(1+beta)*sin(pi*beta/2)/(gamma((1+beta)/2)*beta*2^((beta-1)/2)))^(1/beta);
u=randn(1,d)*sigma;v=randn(1,d);step=u./abs(v).^(1/beta);
o=step;
end

