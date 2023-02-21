%% Code adapted from Sam Gershman (https://github.com/sjgershm)

function [llk, probchoice] = M6(param, data)

% initialize placeholders
N = data.Ntrial(1);
data.N = data.Ntrial(1);
llk = 0; 
probchoice = zeros(N,1);

% init params
lambda = param(1);
alpha_g = param(2);
beta_g = param(3);
eta = param(4);
gamma = param(5); 


% ambiguity parameter for sensory uncertainity


% run the model 
for i = 1:N
    % need to compute probchoice for the context 
    % param set used relies on it being a give or receive trial

    % give first
    if data.context(i) == 1
        x = data.ambiguity(i);
        y = x;
        
        z1 = eta;
        z4 = gamma;

        Rs_c = 2*x;
        Ro_c = 2*y*z1+y*(1-z1)+(1-y)*(1-z4);

        U_c = (Rs_c - alpha_g*max(Ro_c-Rs_c,0)-beta_g*max(Rs_c-Ro_c, 0));
        
        Rs_d = 2*x;
        Ro_d = 2*y*z4+y*(1-z4)+(1-y)*(1-z1);
       
        U_d = (Rs_d - alpha_g*max(Ro_d-Rs_d,0)-beta_g*max(Rs_d-Ro_d, 0));


        Rs_i = 1;
        Ro_i = Ro_c;
   
        U_i = (Rs_i- alpha_g*max(Ro_i-Rs_i,0)-beta_g*max(Rs_i-Ro_i, 0));

        
        Rs_g = 1;
        Ro_g = Ro_d;
        U_g = (Rs_g- alpha_g*max(Ro_g-Rs_g,0)-beta_g*max(Rs_g-Ro_g, 0));

     
        U_change = [U_i U_g];
        U_no_change =[U_c U_d];

        U_all = [U_change U_no_change];
        

        % run through softmax
        prob_vec = exp(lambda.*U_all)./sum(exp(lambda.*U_all));

        % take probability of actual choice
        probchoice(i) = prob_vec(data.choice(i));
                probchoice(probchoice == 0) = eps;
        probchoice(probchoice == 1) = eps; 
        llk = llk + log(probchoice(i));
        
        
    else
        % split into two possibilities
        if data.choice(i) == 2 || data.choice(i) == 4
        x = data.ambiguity(i);

        y = x;

        z1 = eta;
        z4 = gamma; 


        Rs_h =2*x;
        Ro_h = 2*y*z4 + y*(1-z4) + (1-y)*(1-.5);

        U_h = Rs_h - alpha_g*max(Ro_h-Rs_h,0)-beta_g*max(Rs_h-Ro_h, 0);

        % guilty
        Rs_sd = 1;
        Ro_sd = Ro_h;

        U_sd = Rs_sd- alpha_g*max(Ro_sd-Rs_sd,0)-beta_g*max(Rs_sd-Ro_sd, 0);

        % combine with ambiguity for softmax function 
      
        U_change = [U_sd];
        U_no_change = [U_h];

        U_all = [U_change U_no_change];

        % run through softmax
        prob_vec = exp(lambda.*U_all)./sum(exp(lambda.*U_all));

        if data.choice(i) == 2
            transform_choice = 1;
        else
             transform_choice = 2;
        end

        % take probability of actual choice
        probchoice(i) = prob_vec(transform_choice);
        probchoice(probchoice == 0) = eps;
        probchoice(probchoice == 1) = eps; 
        llk = llk + log(probchoice(i));
        else

        % distrust or consistent
        x = data.ambiguity(i);
        y = x;

        z1 = eta; 
        z4 = gamma;
        
        Rs_c = 2*x; 
       
        Ro_c = 2*y*.5+y*(1-.5)+(1-y)*(1-z4); 
        

        
        U_c = Rs_c- alpha_g*max(Ro_c-Rs_c,0)-beta_g*max(Rs_c-Ro_c, 0);

        % inconsistency
        Rs_di = 1;
        Ro_di = Ro_c; 

        U_di = Rs_di- alpha_g*max(Ro_di-Rs_di,0)-beta_g*max(Rs_di-Ro_di, 0);

        % combine with ambiguity for softmax function 
      
        U_change = [U_di];
        U_no_change = [U_c];

        U_all = [U_change U_no_change];

        % run through softmax
        prob_vec = exp(lambda.*U_all)./sum(exp(lambda.*U_all));

        % take probability of actual choice
        % DI C = 1 3 should map to 1/2
        if data.choice(i) == 3
            transform_choice = 2;
        else
             transform_choice = 1;
        end

        probchoice(i) = prob_vec(transform_choice);
        probchoice(probchoice == 0) = eps;
        probchoice(probchoice == 1) = eps; 
        llk = llk + log(probchoice(i));

        end
    end

end

end
