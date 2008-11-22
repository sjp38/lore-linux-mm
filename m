Message-ID: <49276B79.9060002@cn.fujitsu.com>
Date: Sat, 22 Nov 2008 10:16:25 +0800
From: Li Zefan <lizf@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/2] memcg: fix oom handling
References: <20081114191246.4f69ff31.kamezawa.hiroyu@jp.fujitsu.com>	<20081114191949.926bf99d.kamezawa.hiroyu@jp.fujitsu.com>	<49261F87.50209@cn.fujitsu.com> <20081121185829.e04c8116.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081121185829.e04c8116.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, pbadari@us.ibm.com, jblunck@suse.de, taka@valinux.co.jp, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, npiggin@suse.de
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> Li Zefan reported
> 
> (a) This goes dead lock:
> ==
>    #echo 0 >  (...)/01/memory.limit_in_bytes   #set memcg's limit to 0,
>    #echo $$ > (...)/01/memory.tasks            #move task
>    # do something...
> ==
> 
> (b) seems to be dead lock
> ==
>    #echo 40k >  (...)/01/memory.limit_in_bytes   #set memcg's limit to 0,
>    #echo $$ > (...)/01/memory.tasks            #move task
>    # do something...
> ==
> 
> 
> I think (a) is BUG. (b) is just slow down.
> (you can see pgpgin/pgpgout count is increasing in (B).)
> 
> This patch set is for handling (a). Li-san, could you check ?

Yes, it works for me now. :)

> This works well in my environment.(means OOM-Killer is called in proper way.)
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
