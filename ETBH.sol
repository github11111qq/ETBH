struct betHistory {
    uint256 pID;
    uint256 betTime;
    uint256 eth;
    uint256 gen;
  
     
}
struct affHistory {
    uint256 fromid;
    uint256 getid;
    uint256 eth;
    uint256 status;
    
}

 
uint256 ethWei = 1 ether;
uint256[40] affRate = [320,160,120,80,50,30,30,30,30,30,15,15,15,15,15,15,15,15,15,15,5,5,5,5,5,5,5,5,5,5,3,3,3,3,3,3,3,3,3,3];
uint256[10] zyPotRate = [35,20,10,8,7,6,5,4,3,2];
uint256[10] ztPotRate = [35,20,10,8,7,6,5,4,3,2];
uint256 public luckyPot_ = 0;
uint256 public openLuckycc_ = 100;
uint256  public  luckyRound_ = 1;
uint256 public zhuoyuePot_ = 0;
uint256 public zuoyuePotDaoshuTime_ = 720 hours;
uint256 public zuoyuePotDaoshuStartTime_ = 0;
uint256  public  zhuoyueRound_ = 1;
uint256 public bxTotalCoin = 0;
uint256 public bxStartTime_ = 0; 
uint256 public bxTime_ = 48 hours;
uint256 public orderId_;
uint256 public outtimeAff_ = 120 hours;
function buyCore(uint256 _pID,uint256 _eth)
    isWithinLimits(msg.value)
    private
{
    

    gBet_ = gBet_.add(_eth);
    gBetcc_= gBetcc_ + 1; 

    if(now - bxStartTime_ >= bxTime_){
        
        bxStartTime_ = now;
        bxTotalCoin = 0;
    }


    
    plyr_[_pID].totalBet = _eth.add(plyr_[_pID].totalBet);
    plyr_[_pID].lastBet  = _eth;
    plyrReward_[_pID].reward =plyrReward_[_pID].reward.add(_eth.mul(levelReward_[getLevel(_eth)].leverage)/10);
    uint256 _curBaseGen = _eth.mul(levelReward_[getLevel(_eth)].genRate) /1000;
    plyr_[_pID].baseGen = plyr_[_pID].baseGen.add(_curBaseGen);

    uint256 _orderId = setBetHistory(_pID,_eth,_curBaseGen);
    plyrReward_[_pID].onlineId = _orderId;
    plyrReward_[_pID].level = getLevel(plyr_[_pID].totalBet);
    plyr_[_pID].lastReleaseTime = now;



   
}

function getLevel (uint256 _betEth) 
public
view
returns(uint8 level) 
{
    uint8 _level = 0;
    if(_betEth>=51 * ethWei){
        _level = 4;

    }else if(_betEth>=31 * ethWei){
        _level = 3;

    }else if(_betEth>=11 * ethWei){
        _level = 2;

    }else if(_betEth>=1 * ethWei){
        _level = 1;

    }
    return _level;
}



function getDeepForUser(uint256 _pID,uint256 _level)
view
public
returns(uint256 deep){
    
    deep = 0;
    
    if(_level ==4 || _level == 3){
        
            deep = 40;
         
    }else if(_level ==2 ){

        if(plyr_[_pID].invites >=3){
            deep = 40;

        }else if(plyr_[_pID].invites >=2){

             deep = 3;

        }else if(plyr_[_pID].invites >=1){

             deep = 1;

        }
        
    }else if(_level ==1 ){
        
        if(plyr_[_pID].invites >=13){
             deep = 40;
        }else if(plyr_[_pID].invites >=11){
             deep = 25;
        }else if(plyr_[_pID].invites >=9){
             deep = 20;
        }else if(plyr_[_pID].invites >=7){
             deep = 15;
        }else if(plyr_[_pID].invites >=5){
             deep = 10;
        }else if(plyr_[_pID].invites >=4){
             deep = 7;
        }else if(plyr_[_pID].invites >=3){
             deep = 5;
        }else if(plyr_[_pID].invites >=2){
             deep = 3;
        }else if(plyr_[_pID].invites >=1){
             deep = 1;
        }
        
    }
}


function  getUserinfo (uint256 _pID) public view returns(uint256 _basegen,uint256 _baseaff,uint256 _zyEth,uint256 _ztEth,uint256 _onlineEth,uint256 _createtime,uint256 _totalToken)  {
    
    _basegen = plyr_[_pID].baseGen;
    _baseaff = plyr_[_pID].baseAff;
    _zyEth = affBijiao_[zhuoyueRound_][_pID];
    _ztEth = bdResults_[bdRound_][_pID];
    _onlineEth = plyr_[_pID].lastBet;
    _createtime = plyr_[_pID].createTime;
    _totalToken = plyrReward_[_pID].totalToken;
}

function getPlayerlaByAddr (address _addr)
public
view
returns(uint256,uint256,uint256,uint256,uint256,uint256,uint256)
{
    uint256 _pID = pIDxAddr_[_addr];
    
    (uint256 _gen,uint256 _aff,,uint256 _token) = getUserRewardByBase(_pID);
    
    uint256 totalGenH =  plyrReward_[_pID].totalGen - plyrReward_[_pID].wdGen + _gen;
    uint256 totalAffH =  plyrReward_[_pID].totalAff - plyrReward_[_pID].wdAff + _aff;
    uint256 token = plyrReward_[_pID].token + _token + plyrReward_[_pID].utoken;
    uint256 _curReward = plyr_[_pID].curGen + plyr_[_pID].curAff+_gen+_aff + (plyrReward_[_pID].token + _token)/10;
    
    return(
        _pID,
        plyrReward_[_pID].reward.sub(_curReward)>0?plyrReward_[_pID].reward.sub(_curReward):0,
        plyrReward_[_pID].totalGen + _gen,
        plyrReward_[_pID].totalAff + _aff,
        totalGenH,
        totalAffH,
        token
        
        );


}


function getPlayerlaById (uint256 _pID)
public
view
returns(uint256 affid,address addr,uint256 totalBet,uint256 level,uint256 _zypot,uint256 _bdpot,uint256 _luckpot,
    string memory inviteCode,string memory affInviteCode)
{
   require(_pID>0 && _pID < nextId_, "Now cannot withDraw!");
   
    affid =  plyr_[_pID].affId;
    addr  = plyr_[_pID].addr;
    totalBet = plyr_[_pID].totalBet;
    level = plyrReward_[_pID].level;
    _zypot = playerPot_[_pID].zhuoyuepot;
    _bdpot = playerPot_[_pID].bdpot;
    _luckpot = playerPot_[_pID].luckpot;
    inviteCode = plyr_[_pID].inviteCode;
    affInviteCode =plyr_[plyr_[_pID].affId].inviteCode;
      


}


function somethingmsg () 
public
view
returns(uint256 _minbeteth,uint256 _genReleTime)
{
    return(

        minbeteth_,
        genReleTime_
        );

}

function getsystemMsg()
public
view
returns(uint256 _gbet,uint256 _gcc,uint256 _luckpot,uint256 _zypot,uint256 _zytime,uint256 _bxTotalCoin,uint256 _luckround,uint256 _zyround,uint256 _bdround,uint256 _bdPot,uint256 _bdtime,uint256 _bxTime)
{
    return
    (
        gBet_,
        gBetcc_,
        luckyPot_,
        zhuoyuePot_,
        zuoyuePotDaoshuTime_+zuoyuePotDaoshuStartTime_,
        bxTotalCoin,
        luckyRound_,
        zhuoyueRound_,
        bdRound_,
        bdPot_,
        bdPotDaoshuStartTime_ + bdePotDaoshuTime_,
        bxStartTime_ + bxTime_
        
        
    );
}


function getbestDongtaiBaseUser (uint256 _rid,uint256 _weizhi) 
public
view
returns(uint256 _pID,uint256 _totalBet,uint256 _baseAff,string memory _inviteCode) 
{
     if(bestDongtaiBaseUser_[_rid].length<=_weizhi){
        _pID = 0;
        _totalBet = 0;
        _baseAff = 0;
        _inviteCode = "0";
     }else{
        _pID = bestDongtaiBaseUser_[_rid][_weizhi];
        _totalBet = plyr_[_pID].totalBet;
        _baseAff = affBijiao_[_rid][_pID];
        _inviteCode = plyr_[_pID].inviteCode;
    }
    
}
