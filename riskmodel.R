# riskmodel --------------------------------------------------------------------

library("data.table")

# generate data
v_customers <- 
  c(
    10001,
    10002,
    10003,
    20001,
    20002,
    20003,
    20004,
    30001,
    30002,
    30003,
    40001,
    40002
  )

v_default <- as.numeric()
v_var1 <- as.numeric()
v_var2 <- as.numeric()
v_var3 <- as.numeric()
v_var4 <- as.numeric()

while( sum(v_default) <3 ){
  for( cust in v_customers){
    v_default <- c(v_default,rbinom(n=1, size=1, p=0.25)) 
  }
  if( length(v_default) > length(v_customers) ) {
    v_default <- as.numeric()
  }
}

for(cust in v_customers){
  if( v_default[which(v_customers == cust)] == 1 || cust %in% c( 20001, 20002, 40001) ){
    v_var1 <- c(v_var1,rnorm(1, mean=-3, sd=4))
    v_var2 <- c(v_var2,rnorm(1, mean=1, sd=2))
    v_var3 <- c(v_var3,rnorm(1, mean=5, sd=2))
    v_var4 <- c(v_var4,rnorm(1, mean=-4, sd=1))
  }
  else{
    v_var1 <- c(v_var1,rnorm(1, mean=-2, sd=2))
    v_var2 <- c(v_var2,rnorm(1, mean=-1, sd=3))
    v_var3 <- c(v_var3,rnorm(1, mean=5, sd=2))
    v_var4 <- c(v_var4,rnorm(1, mean=-4, sd=1))
  }
}

dt_model_data <-
  data.table(
    customer_id = v_customers,
    default = v_default,
    var1 = v_var1,
    var2 = v_var2,
    var3 = v_var3,
    var4 = v_var4
  )

# logistic regression
v_y <- dt_model_data[, default]
m_log <- glm( formula=v_y ~ v_var1 + v_var2 + v_var3 + v_var4, family=binomial("logit") )
summary(m_log)
