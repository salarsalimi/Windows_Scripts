:: Seting new PEER
w32tm /config /update /manualpeerlist:10.170.47.253 /reliable:YES /syncfromflags:manual
w32tm /resync /rediscover

:: Get Peer and configuretion 
w32tm /query /source
w32tm /query /configuration
