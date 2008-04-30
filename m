Message-Id: <4817F108.40806@mxp.nes.nec.co.jp>
Date: Wed, 30 Apr 2008 13:09:44 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH] another swap controller for cgroup
References: <20080317085003.EA4511E7A77@siro.lan> <20080429225047.EC4645A04@siro.lan>
In-Reply-To: <20080429225047.EC4645A04@siro.lan>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: YAMAMOTO Takashi <yamamoto@valinux.co.jp>
Cc: containers@lists.osdl.org, minoura@valinux.co.jp, hugh@veritas.com, balbir@linux.vnet.ibm.com, linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, "IKEDA, Munehiro" <m-ikeda@ds.jp.nec.com>
List-ID: <linux-mm.kvack.org>

YAMAMOTO Takashi wrote:
>>>> - anonymous objects (shmem) are not accounted.
>>> IMHO, shmem should be accounted.
>>> I agree it's difficult in your implementation,
>>> but are you going to support it?
>> it should be trivial to track how much swap an anonymous object is using.
>> i'm not sure how it should be associated with cgroups, tho.
>>
>> YAMAMOTO Takashi
> 
> i implemented shmem swap accounting.  see below.
> 
> YAMAMOTO Takashi
> 
Hi, YAMAMOTO san.

Thank you for implementing this feature.
I will review it.

BTW, I'm just trying to make my swapcontroller patch
that is rebased on recent kernel and implemented
as part of memory controller.
I'm going to submit it by the middle of May.


Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
