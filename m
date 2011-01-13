Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 4E2B66B0092
	for <linux-mm@kvack.org>; Wed, 12 Jan 2011 22:30:36 -0500 (EST)
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by e28smtp09.in.ibm.com (8.14.4/8.13.1) with ESMTP id p0D2lGKi004457
	for <linux-mm@kvack.org>; Thu, 13 Jan 2011 08:17:16 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p0D3UTmS4395228
	for <linux-mm@kvack.org>; Thu, 13 Jan 2011 09:00:29 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p0D3USOc020574
	for <linux-mm@kvack.org>; Thu, 13 Jan 2011 09:00:29 +0530
Date: Thu, 13 Jan 2011 08:34:15 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: cgroups and overcommit question
Message-ID: <20110113030415.GF2897@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <AANLkTin_-bH09WK43DS9p0Kpp=7y6iHbLnUrCtOc6Qy5@mail.gmail.com>
 <20110113105741.dd38d58e.nishimura@mxp.nes.nec.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20110113105741.dd38d58e.nishimura@mxp.nes.nec.co.jp>
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: Evgeniy Ivanov <lolkaantimat@gmail.com>, linux-mm <linux-mm@kvack.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

* nishimura@mxp.nes.nec.co.jp <nishimura@mxp.nes.nec.co.jp> [2011-01-13 10:57:41]:

> Hi.
> 
> On Wed, 12 Jan 2011 18:40:37 +0300
> Evgeniy Ivanov <lolkaantimat@gmail.com> wrote:
> 
> > Hello,
> > 
> > When I forbid memory overcommiting, malloc() returns 0 if can't
> > reserve memory, but in a cgroup it will always succeed, when it can
> > succeed when not in the group.
> > E.g. I've set 2 to overcommit_memory, limit is 10M: I can ask malloc
> > 100M and it will not return any error (kernel is 2.6.32).
> > Is it expected behavior?
> > 
> Yes. Because memory cgroup can be used for limiting the memory(and swap) size
> which is physically used, not the malloc'ed size.
>

I had rlimit based cgroup to limit virtual memory size, but the
patches were never merged due to lack of use cases :( 

See http://lwn.net/Articles/283287/

I did advocate as use case the ability to prevent overcommit. I
suspect another way of solving this problem is to have overcommit
control. The problem today is that OOM is our backup to overcommit,
not a very comfortable feeling.

-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
