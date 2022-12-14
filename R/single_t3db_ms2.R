#查询单个或多个物质信息，通过输入T3Did
#多个请以c("T3D0001","T3D0002","T3D0003")形式输入
single_t3db <- function(id=c("T3D0001"),sleep_time=c("2")){
  library(tidyverse)
  library(rvest)
  library(curl)
  library(RCurl)
  #pb <- txtProgressBar(0, length(t3dbid), style = 3)
  message("正在测试可查询的T3DB_ID网页")
  t3dbid <- lapply(1:length(id), function(x){
    url_0 <- "http://www.t3db.ca/toxins/"
    info_0 <- paste0(id[x],"#spectra")
    new_url_0 <- paste0(url_0,info_0)
    if(url.exists(new_url_0)==TRUE){
      url <- id[x]
    }
  }) %>% unlist()
  message("测试可查询的T3DB_ID网页结束")
  #获取二级数据的url
  #t3dbid <- t3db_data$t3dbid
  #pb <- txtProgressBar(0, length(t3dbid), style = 3)
  t3d_info <- lapply(1:length(t3dbid), function(x){
    #setTxtProgressBar(pb, x)
    Sys.sleep(sleep_time)
    message(paste0("正在获取T3DB_ID为：",t3dbid[x]," 的二级数据"))
    url_1 <- "http://www.t3db.ca/toxins/"
    info_1 <- paste0(t3dbid[x],"#spectra")
    new_url_1 <- paste0(url_1,info_1)
    ##获取html网页
    #System.time()  #中间放进去的时间单位为秒
    
    web <- read_html(curl(new_url_1,handle = curl::new_handle("useragent" = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/105.0.0.0 Safari/537.36 Edg/105.0.1343.33")))
    
    # web <- read_html(new_url_1)
    ##提取文档中指定元素,提取二级谱图对应的序列号
    news <- web %>% html_nodes("tr td tbody tr td")
    index <- grep("/spectra/ms_ms",news,value = TRUE)
    ##存在二级谱图
    if(length(index)>0){
      ms2_num <- lapply(1:length(index), FUN = function(i){
        str_num <- strsplit(index[i],"ms/")[[1]][2] %>% strsplit(.,"\"")
        id_num <- str_num[[1]][1]
        #先测试T3BD000001的二级序列号URL是否可用，去除不可用的url
        if(url.exists(paste0("http://www.t3db.ca/spectra/ms_ms/",id_num))==FALSE){
          id_num <- NULL
        }else{
          id_num <- id_num
        }
      }) %>% unlist()
      ##去除ms2_num中为NA的项
      #   if(length(which(ms2_num=="NULL"))>0){
      #            ms2_num <- ms2_num[-which(ms2_num=="NULL")]  ##500问题所在 因为网页确实无法打开
      #            }else{
      #             ms2_num <- ms2_num
      #        } 
      #获取T3BD000001的二级序列号成功，为ms2_num
      #获取二级碎片的URL
      ms2_url <- lapply(1:length(ms2_num), FUN = function(j){
        #setTxtProgressBar(pb, x)
        #Sys.sleep(3)
        url_2 <- "http://www.t3db.ca/spectra/ms_ms/"
        num <- ms2_num[j]#改
        new_url_2 <- paste0(url_2,num)
        #获取HTML网页
        web <- read_html(curl(new_url_2,handle = curl::new_handle("useragent" = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/105.0.0.0 Safari/537.36 Edg/105.0.1343.33")))
        #提取文档中指定元素
        news <- web %>% html_nodes("tbody tr td")
        index <- grep("http",news,value = TRUE)[1]
        str_ms <- strsplit(index,"\">Download")[[1]][1]
        ms_url <- strsplit(str_ms,"href=\"")[[1]][2]
      })
      #获取T3BD000001的二级url成功，为ms2_url
      ###################获取Experimental Conditions#############################
      #把所有有二级数据的T3DB号找出来，最终id号作为媒介与物质信息表进行合并
      ##数量过大 网站容易拒绝访问
      ms2_info <- lapply(1:length(ms2_num), FUN = function(k){
        
        url_2 <- "http://www.t3db.ca/spectra/ms_ms/"
        num <- ms2_num[k]#改
        new_url_2 <- paste0(url_2,num)
        #获取HTML网页
        #web <- read_html(new_url_2)
        
        web <- read_html(curl(new_url_2,handle = curl::new_handle("useragent" = "Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/86.0.4240.198 Safari/537.36")))
        #提取文档中指定元素
        news <- web %>% html_nodes("div table tr")
        titles <- news %>% html_text()
        
        T3DB_ID <- t3dbid[x]
        
        str_name <- grep("Compound name",titles,value = TRUE)
        if(length(str_name)>0){
          Compound_name <- strsplit(str_name,":")[[1]][2]
        }else{
          Compound_name <- "NA"
        }
        
        str_mode <- grep("Ionization Mode",titles,value = TRUE)
        if(length(str_mode)>0){
          Ionization_Mode <- strsplit(str_mode,":")[[1]][2]
        }else{
          Ionization_Mode <- "NA"
        }
        
        str_Energy <- grep("Collision",titles,value = TRUE)
        if(length(str_Energy)>0){
          Collision_Energy <- strsplit(str_Energy,":")[[1]][2]
        }else{
          Collision_Energy <- "NA"
        }
        
        str_Formula <- grep("Molecular Formula",titles,value = TRUE)
        if(length(str_Formula)>0){
          Molecular_Formula <- strsplit(str_Formula,":")[[1]][2]
        }else{
          Molecular_Formula <- "NA"
        }
        
        str_mass <- grep("Monoisotopic Mass",titles,value = TRUE)
        if(length(str_mass)>0){
          Monoisotopic_Mass <- strsplit(str_mass,":")[[1]][2]
        }else{
          Monoisotopic_Mass <- "NA"
        }
        
        str_type <- grep("Instrument Type",titles,value = TRUE)
        if(length(str_type)>0){
          Instrument_Type <- strsplit(str_type,":")[[1]][2]
        }else{
          Instrument_Type <- "NA"
        }
        data.frame(T3DB_ID=T3DB_ID,Compound_name=Compound_name,Ionization_Mode=Ionization_Mode,
                   Collision_Energy=Collision_Energy,Molecular_Formula=Molecular_Formula,
                   Monoisotopic_Mass=Monoisotopic_Mass,Instrument_Type=Instrument_Type)
      }) %>% do.call(rbind,.)
      ##获取信息成功
      #获取二级数据text
      ################下载二级碎片离子信息(mz，intensity)
      ##################最终结果为一个csv列表，并保存到默认路径
      msms <- lapply(1:length(ms2_url), function(s){
        num <- ms2_url[[s]]
        if(is.na(num)==TRUE){    ######出现NA是因为网页中文档不可用
          new_ms2 <- "Web page documents are not available"
        }else{
          web_ms2 <- read_html(num)
          new_ms2 <- web_ms2 %>% html_nodes("body") %>% html_text()
        }
        data.frame(ms2=new_ms2)
      }) %>% do.call(rbind,.)
      info_final<- cbind(ms2_info,msms) 
    }else{
      #如果不存在二级谱图
      info_finla <- NULL
      message(paste0(t3dbid[x]),"没有二级谱图,跳过")
      
    }
  }) %>% do.call(rbind,.)
  message("全部数据获取完成")
  if(dir.exists("./T3DB")==FALSE){
    dir.create("./T3DB")
  }
  write.csv(t3d_info,"./T3DB/file.name.csv")
  save(t3d_info,file = "./T3DB/file.name.Rdata")
  t3d_info
}
