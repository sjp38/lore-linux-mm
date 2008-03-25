Message-Id: <47E88129.1010705@mxp.nes.nec.co.jp>
Date: Tue, 25 Mar 2008 13:35:53 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH] another swap controller for cgroup
References: <47E79A26.3070401@mxp.nes.nec.co.jp> <20080325031039.549831E9292@siro.lan>
In-Reply-To: <20080325031039.549831E9292@siro.lan>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: YAMAMOTO Takashi <yamamoto@valinux.co.jp>
Cc: hugh@veritas.com, balbir@linux.vnet.ibm.com, kamezawa.hiroyu@jp.fujitsu.com, minoura@valinux.co.jp, containers@lists.osdl.org, linux-mm@kvack.org, "IKEDA, Munehiro" <m-ikeda@ds.jp.nec.com>
List-ID: <linux-mm.kvack.org>

YAMAMOTO Takashi wrote:
> hi,
> 
>> Daisuke Nishimura wrote:
>>> Hi, Yamamoto-san.
>>>
>>> I'm reviewing and testing your patch now.
>>>
>> In building kernel infinitely(in a cgroup of
>> memory.limit=64M and swap.limit=128M, with swappiness=100),
>> almost all of the swap (1GB) is consumed as swap cache
>> after a day or so.
>> As a result, processes are occasionally OOM-killed even when
>> the swap.usage of the group doesn't exceed the limit.
>>
>> I don't know why the swap cache uses up swap space.
>> I will test whether a similar issue happens without your patch.
>> Do you have any thoughts?
> 
> my patch tends to yield more swap cache because it makes try_to_unmap
> fail and shrink_page_list leaves swap cache in that case.
> i'm not sure how it causes 1GB swap cache, tho.
> 

Agree.

I suspected that the cause of this problem was the behavior
of shrink_page_list as you said, so I thought one of Rik's
split-lru patchset:

  http://lkml.org/lkml/2008/3/4/492
  [patch 04/20] free swap space on swap-in/activation

would reduce the usage of swap cache to half of the total swap.
But it didn't help, so I think there may be some other causes.


Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
