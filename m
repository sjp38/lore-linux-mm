Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 3DA968D0040
	for <linux-mm@kvack.org>; Thu, 31 Mar 2011 14:14:30 -0400 (EDT)
Received: from kpbe14.cbf.corp.google.com (kpbe14.cbf.corp.google.com [172.25.105.78])
	by smtp-out.google.com with ESMTP id p2VIER8C027507
	for <linux-mm@kvack.org>; Thu, 31 Mar 2011 11:14:27 -0700
Received: from qyk30 (qyk30.prod.google.com [10.241.83.158])
	by kpbe14.cbf.corp.google.com with ESMTP id p2VIEAfC015161
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 31 Mar 2011 11:14:26 -0700
Received: by qyk30 with SMTP id 30so2343016qyk.14
        for <linux-mm@kvack.org>; Thu, 31 Mar 2011 11:14:26 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110331162050.GI12265@random.random>
References: <20110331110113.a01f7b8b.kamezawa.hiroyu@jp.fujitsu.com>
	<4D944801.3020404@parallels.com>
	<20110331162050.GI12265@random.random>
Date: Thu, 31 Mar 2011 11:14:25 -0700
Message-ID: <BANLkTin4Zj9HLWy5xobBcP6WQFY1um1JzA@mail.gmail.com>
Subject: Re: [Lsf] [LSF][MM] rough agenda for memcg.
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Pavel Emelyanov <xemul@parallels.com>, lsf@lists.linux-foundation.org, Linux MM <linux-mm@kvack.org>

On Thu, Mar 31, 2011 at 9:20 AM, Andrea Arcangeli <aarcange@redhat.com> wro=
te:
> On Thu, Mar 31, 2011 at 01:23:13PM +0400, Pavel Emelyanov wrote:
>> > =A0b) single LRU and per memcg zone->lru_lock.
>> > =A0 =A0 I hear zone->lru_lock contention caused by memcg is a problem =
on Google servers.
>> > =A0 =A0 Okay, please show data. (I've never seen it.)
>> > =A0 =A0 Then, we need to discuss Pros. and Cons. of current design and=
 need to consinder
>> > =A0 =A0 how to improve it. I think Google and Michal have their own im=
plementation.
>> >
>> > =A0 =A0 Current design of double-LRU is from the 1st inclusion of memc=
g to the kernel.
>> > =A0 =A0 But I don't know that discussion was there. Balbir, could you =
explain the reason
>> > =A0 =A0 of this design ? Then, we can go ahead, somewhere.
>>
>> I would like to take part in that and describe what we've done with LRU
>> in OpenVZ in details.
>
> Sounds good.
>
>>
>> > =A0 a) Kernel memory accounting.
>>
>> This one is very interesting to me.
>
> I expected someone would have been interested into that...

We are definitely interested in that. We are testing the patch
internally now on kernel slab accounting. The author won't be in LSF,
but I can help to present our approach in the session w/ Pavel. Also,
I would like to talk a bit on the kernel memory reclaim for few
minutes.

--Ying

>
>> > =A0 f) vm_overcommit_memory should be supproted with memcg ?
>> > =A0 =A0 =A0(I remember there was a trial. But I think it should be don=
e in other cgroup
>> > =A0 =A0 =A0 as vmemory cgroup.)
>>
>> And this one too - I have an implementation of overcommit management
>> in OpenVZ, I can describe one and discuss pros-n-cons.
>
> Ok, so I've added you to the second half of "what's next".
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org. =A0For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter=
.ca/
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
