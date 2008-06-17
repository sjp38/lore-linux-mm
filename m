From: kamezawa.hiroyu@jp.fujitsu.com
Message-ID: <18509098.1213704200391.kamezawa.hiroyu@jp.fujitsu.com>
Date: Tue, 17 Jun 2008 21:03:20 +0900 (JST)
Subject: Re: Re: [PATCH 2/2] memcg: reduce usage at change limit
In-Reply-To: <48578E9D.4050903@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
References: <48578E9D.4050903@linux.vnet.ibm.com>
 <20080617123144.ce5a74fa.kamezawa.hiroyu@jp.fujitsu.com> <20080617123604.c8cb1bd5.kamezawa.hiroyu@jp.fujitsu.com> <48573397.608@linux.vnet.ibm.com> <20080617130656.bcd3ca85.kamezawa.hiroyu@jp.fujitsu.com> <20080617190055.2b55ba0b.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, xemul@openvz.org, menage@google.com, lizf@cn.fujitsu.com, yamamoto@valinux.co.jp, nishimura@mxp.nes.nec.co.jp, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

----- Original Message -----
>Date: 	Tue, 17 Jun 2008 15:44:53 +0530
>From: Balbir Singh <balbir@linux.vnet.ibm.com>
>KAMEZAWA Hiroyuki wrote:
>
>>> I'll repost later, today.
>>>
>> I'll postpone this until -mm is settled ;)
>> 
>
>Sure, by -mm is settled you mean scalable page reclaim, fast GUP and lockless
>read size for pagecache? Is there something else I am unaware of?
>
Ah, some panics are added ;)
It's my main concern.  And I have to study new VM LRU management
scheme and check whether there are something to be fixed(updated)
around memcg. 

Anyway, I'd like to push this patch before too late. I just stop
for a while (because -mm has trouble).

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
