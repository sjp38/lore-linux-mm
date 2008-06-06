From: kamezawa.hiroyu@jp.fujitsu.com
Message-ID: <2827301.1212764335427.kamezawa.hiroyu@jp.fujitsu.com>
Date: Fri, 6 Jun 2008 23:58:55 +0900 (JST)
Subject: Re: Re: memcg: bad page at page migration
In-Reply-To: <10499358.1212763411935.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
References: <10499358.1212763411935.kamezawa.hiroyu@jp.fujitsu.com>
 <20080606221124.623847aa.nishimura@mxp.nes.nec.co.jp>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: kamezawa.hiroyu@jp.fujitsu.com
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, akpm@linux-foundation.org, balbir@linux.vnet.ibm.com, xemul@openvz.org, lizf@cn.fujitsu.com, yamamoto@valinux.co.jp, hugh@veritas.com, minchan.kim@gmail.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>----- Original Message -----
>>Date: Fri, 6 Jun 2008 22:11:24 +0900
>>From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
>>To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>>Cc: akpm@linux-foundation.org, balbir@linux.vnet.ibm.com, xemul@openvz.org,
>>   lizf@cn.fujitsu.com, yamamoto@valinux.co.jp, hugh@veritas.com,
>>   minchan.kim@gmail.com, linux-mm@kvack.org
>>Subject: memcg: bad page at page migration
>>
>>
>>Hi, Kamezawa-san.
>>
>>I found a bad page problem with your performance improvement
>>patch set v4(*1), which have been already in -mm queue.
>>This problem doesn't happen on original 2.6.26-rc2-mm1.
>>
>Could you try this one ?
>http://marc.info/?l=linux-mm-commits&m=121126615605729&w=2
>Sorry for very easy bug.
>
Sorry again, you seems to use the patch. I'll dig it....

-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
