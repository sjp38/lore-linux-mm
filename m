Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 2CCD26B0092
	for <linux-mm@kvack.org>; Thu, 13 Jan 2011 07:24:11 -0500 (EST)
Received: by iyj17 with SMTP id 17so1508465iyj.14
        for <linux-mm@kvack.org>; Thu, 13 Jan 2011 04:24:09 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20110113030415.GF2897@balbir.in.ibm.com>
References: <AANLkTin_-bH09WK43DS9p0Kpp=7y6iHbLnUrCtOc6Qy5@mail.gmail.com>
	<20110113105741.dd38d58e.nishimura@mxp.nes.nec.co.jp>
	<20110113030415.GF2897@balbir.in.ibm.com>
Date: Thu, 13 Jan 2011 15:24:09 +0300
Message-ID: <AANLkTi=2p1QAdkbZkgy1PJrKT-zYpZ8i3twBXoCaQk21@mail.gmail.com>
Subject: Re: cgroups and overcommit question
From: Evgeniy Ivanov <lolkaantimat@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-mm <linux-mm@kvack.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Thu, Jan 13, 2011 at 6:04 AM, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> * nishimura@mxp.nes.nec.co.jp <nishimura@mxp.nes.nec.co.jp> [2011-01-13 10:57:41]:
>
>> Hi.
>>
>> On Wed, 12 Jan 2011 18:40:37 +0300
>> Evgeniy Ivanov <lolkaantimat@gmail.com> wrote:
>>
>> > Hello,
>> >
>> > When I forbid memory overcommiting, malloc() returns 0 if can't
>> > reserve memory, but in a cgroup it will always succeed, when it can
>> > succeed when not in the group.
>> > E.g. I've set 2 to overcommit_memory, limit is 10M: I can ask malloc
>> > 100M and it will not return any error (kernel is 2.6.32).
>> > Is it expected behavior?
>> >
>> Yes. Because memory cgroup can be used for limiting the memory(and swap) size
>> which is physically used, not the malloc'ed size.

Yeah, I see. But it doesn't seem complicated/expensive to check
(already_charged + malloc_requested) and charge new pages if
overcommit disabled.
man 5 proc says about vm/overcommit_memory "2: always check, never
overcommit". So there should be either a note or malloc within cgroup
should be consistent with other part of the system.


> I had rlimit based cgroup to limit virtual memory size, but the
> patches were never merged due to lack of use cases :(
>
> See http://lwn.net/Articles/283287/
>
> I did advocate as use case the ability to prevent overcommit. I
> suspect another way of solving this problem is to have overcommit
> control. The problem today is that OOM is our backup to overcommit,
> not a very comfortable feeling.

I fully agree with you.



-- 
Evgeniy Ivanov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
