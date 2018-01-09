# qipaiskynet
qipai   with  skynet




- git 

  1. submodule  
     git submodule add https://github.com/cloudwu/skynet.git
  2. update 
    git submodule init 
    git submodule update  
    
    submodule远程分支发生变更后，直接使用git submodule update是不会进行更新操作的  
    git submodule foreach git checkout master  
    git submodule foreach git pull  





- skynet
  1. cloud 下  
     make   macosx   

  2. 
     killall skynet  

