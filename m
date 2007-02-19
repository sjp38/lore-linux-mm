Received: from sd0208e0.au.ibm.com (d23rh904.au.ibm.com [202.81.18.202])
	by ausmtp04.au.ibm.com (8.13.8/8.13.8) with ESMTP id l1JB0srs098880
	for <linux-mm@kvack.org>; Mon, 19 Feb 2007 22:00:54 +1100
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.250.237])
	by sd0208e0.au.ibm.com (8.13.8/8.13.8/NCO v8.2) with ESMTP id l1JAmZtd163010
	for <linux-mm@kvack.org>; Mon, 19 Feb 2007 21:48:35 +1100
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l1JAj5VT025509
	for <linux-mm@kvack.org>; Mon, 19 Feb 2007 21:45:05 +1100
Message-ID: <45D97FAD.9070009@in.ibm.com>
Date: Mon, 19 Feb 2007 16:15:01 +0530
From: Balbir Singh <balbir@in.ibm.com>
Reply-To: balbir@in.ibm.com
MIME-Version: 1.0
Subject: Re: [RFC][PATCH][0/4] Memory controller (RSS Control)
References: <20070219065019.3626.33947.sendpatchset@balbir-laptop> <20070219005441.7fa0eccc.akpm@linux-foundation.org> <aec7e5c30702190116j26efcba3oe5223584f99ac25a@mail.gmail.com>
In-Reply-To: <aec7e5c30702190116j26efcba3oe5223584f99ac25a@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Magnus Damm <magnus.damm@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, vatsa@in.ibm.com, ckrm-tech@lists.sourceforge.net, xemul@sw.ru, linux-mm@kvack.org, menage@google.com, svaidy@linux.vnet.ibm.com, devel@openvz.org
List-ID: <linux-mm.kvack.org>

Magnus Damm wrote:
> On 2/19/07, Andrew Morton <akpm@linux-foundation.org> wrote:
>> On Mon, 19 Feb 2007 12:20:19 +0530 Balbir Singh <balbir@in.ibm.com> 
>> wrote:
>>
>> > This patch applies on top of Paul Menage's container patches (V7) 
>> posted at
>> >
>> >       http://lkml.org/lkml/2007/2/12/88
>> >
>> > It implements a controller within the containers framework for limiting
>> > memory usage (RSS usage).
> 
>> The key part of this patchset is the reclaim algorithm:
>>
>> Alas, I fear this might have quite bad worst-case behaviour.  One small
>> container which is under constant memory pressure will churn the
>> system-wide LRUs like mad, and will consume rather a lot of system time.
>> So it's a point at which container A can deleteriously affect things 
>> which
>> are running in other containers, which is exactly what we're supposed to
>> not do.
> 
> Nice with a simple memory controller. The downside seems to be that it
> doesn't scale very well when it comes to reclaim, but maybe that just
> comes with being simple. Step by step, and maybe this is a good first
> step?
> 

Thanks, I totally agree.

> Ideally I'd like to see unmapped pages handled on a per-container LRU
> with a fallback to the system-wide LRUs. Shared/mapped pages could be
> handled using PTE ageing/unmapping instead of page ageing, but that
> may consume too much resources to be practical.
> 
> / magnus

Keeping unmapped pages per container sounds interesting. I am not quite
sure what PTE ageing, will it look it up.


-- 
	Warm Regards,
	Balbir Singh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
