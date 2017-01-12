From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: mmotm 2017-01-11-17-14 uploaded
Date: Thu, 12 Jan 2017 13:05:54 +1100
Message-ID: <20170112130554.3ef6fc64@canb.auug.org.au>
References: <5876d891.KO+lq262YUFdAzyd%akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5876d891.KO+lq262YUFdAzyd%akpm@linux-foundation.org>
Sender: linux-kernel-owner@vger.kernel.org
To: akpm@linux-foundation.org
Cc: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, mhocko@suse.cz, broonie@kernel.org, "David S. Miller" <davem@davemloft.net>
List-Id: linux-mm.kvack.org

Hi Andrew,

On Wed, 11 Jan 2017 17:14:57 -0800 akpm@linux-foundation.org wrote:
>
> The mm-of-the-moment snapshot 2017-01-11-17-14 has been uploaded to
> 
>    http://www.ozlabs.org/~akpm/mmotm/

Imported mostly fine ...

>   linux-next-git-rejects.patch

That is not correct :-(

I used (more or less) the resolution in DaveM's tree today:

2d6567d103301509f941d5e565a8cce78ded1456
diff --cc net/core/sock.c
index 4eca27dc5c94,31f72f3a3559..9e07ab81a144
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@@ -222,7 -222,7 +222,7 @@@ static const char *const af_family_key_
    "sk_lock-AF_RXRPC" , "sk_lock-AF_ISDN"     , "sk_lock-AF_PHONET"   ,
    "sk_lock-AF_IEEE802154", "sk_lock-AF_CAIF" , "sk_lock-AF_ALG"      ,
    "sk_lock-AF_NFC"   , "sk_lock-AF_VSOCK"    , "sk_lock-AF_KCM"      ,
-   "sk_lock-AF_QIPCRTR", "sk_lock-AF_MAX"
 -  "sk_lock-AF_SMC"   , "sk_lock-AF_MAX"
++  "sk_lock-AF_QIPCRTR", "sk_lock-AF_SMC"   , "sk_lock-AF_MAX"
  };
  static const char *const af_family_slock_key_strings[AF_MAX+1] = {
    "slock-AF_UNSPEC", "slock-AF_UNIX"     , "slock-AF_INET"     ,
@@@ -239,7 -239,7 +239,7 @@@
    "slock-AF_RXRPC" , "slock-AF_ISDN"     , "slock-AF_PHONET"   ,
    "slock-AF_IEEE802154", "slock-AF_CAIF" , "slock-AF_ALG"      ,
    "slock-AF_NFC"   , "slock-AF_VSOCK"    ,"slock-AF_KCM"       ,
-   "slock-AF_QIPCRTR", "slock-AF_MAX"
 -  "slock-AF_SMC"   , "slock-AF_MAX"
++  "slock-AF_QIPCRTR", "slock-AF_SMC"   , "slock-AF_MAX"
  };
  static const char *const af_family_clock_key_strings[AF_MAX+1] = {
    "clock-AF_UNSPEC", "clock-AF_UNIX"     , "clock-AF_INET"     ,
@@@ -256,7 -256,7 +256,7 @@@
    "clock-AF_RXRPC" , "clock-AF_ISDN"     , "clock-AF_PHONET"   ,
    "clock-AF_IEEE802154", "clock-AF_CAIF" , "clock-AF_ALG"      ,
    "clock-AF_NFC"   , "clock-AF_VSOCK"    , "clock-AF_KCM"      ,
-   "clock-AF_QIPCRTR", "clock-AF_MAX"
 -  "closck-AF_smc"  , "clock-AF_MAX"
++  "clock-AF_QIPCRTR", "closck-AF_smc"  , "clock-AF_MAX"
  };
  
  /*


And just noticed the typo in the last two lines (which is also in DaveM's
tree) :-(
-- 
Cheers,
Stephen Rothwell
