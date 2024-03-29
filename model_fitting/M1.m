%% Code adapted from Sam Gershman (https://github.com/sjgershm)
% uses the mfit package (https://github.com/sjgershm/mfit)

function [llk, probchoice] = M1(param, data)



% Create placeholders
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

% run the model 
for i = 1:N
    % need to compute probchoice for the context 
    % param set used relies on it being a give or receive trial

    % give first
    if data.context(i) == 1
        x = data.ambiguity(i);
        
        z1 = x^eta;
        z4 = x^gamma;

        % C1 = C2 = advice
        Rs_c = 2*x;
        Ro_c = 2*x*z1+x*(1-z1)+(1-x)*(1-z4);

        U_c = (Rs_c - alpha_g*max(Ro_c-Rs_c,0)-beta_g*max(Rs_c-Ro_c, 0));
        
        % C1 = C2 != advice
        Rs_d = 2*x;
        Ro_d = 2*x*z4+x*(1-z4)+(1-x)*(1-z1);
       
        U_d = (Rs_d - alpha_g*max(Ro_d-Rs_d,0)-beta_g*max(Rs_d-Ro_d, 0));


        % C1 = advice, C1 != C2
        Rs_i = 1;
        Ro_i = Ro_c;
   
        U_i = (Rs_i- alpha_g*max(Ro_i-Rs_i,0)-beta_g*max(Rs_i-Ro_i, 0));

        
        % C1 != advice, C1 != C2
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

        z1 = x^eta;
        z4 = x^gamma; 

        % C1 = C2 != advice
        Rs_h =2*x;
        Ro_h = 2*x*z4 + x*(1-z4) + (1-x)*(1-z1);

        U_h = Rs_h - alpha_g*max(Ro_h-Rs_h,0)-beta_g*max(Rs_h-Ro_h, 0);

        % C1 != C2, C1 != advice
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

        % store log-likelihood
        llk = llk + log(probchoice(i));

        else

        % distrust or consistent
        x = data.ambiguity(i);

        z1 = x^eta; 
        z4 = .5;
        
        % C1 = C2 = advice
        Rs_c = 2*x; 
      
        Ro_c = 2*x*z1+x*(1-z1)+(1-x)*(1-z4); 

        U_c = Rs_c- alpha_g*max(Ro_c-Rs_c,0)-beta_g*max(Rs_c-Ro_c, 0);

        % C1 != C2, C1 = advice
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
