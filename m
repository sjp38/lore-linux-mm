Received: from sd0208e0.au.ibm.com (d23rh904.au.ibm.com [202.81.18.202])
	by ausmtp05.au.ibm.com (8.13.8/8.13.6) with ESMTP id kALN8ueL540734
	for <linux-mm@kvack.org>; Tue, 21 Nov 2006 22:09:12 -0100
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.250.237])
	by sd0208e0.au.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id kALBADnO133388
	for <linux-mm@kvack.org>; Tue, 21 Nov 2006 22:10:24 +1100
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id kALB6kam021555
	for <linux-mm@kvack.org>; Tue, 21 Nov 2006 22:06:46 +1100
Message-ID: <4562DDBE.5070706@in.ibm.com>
Date: Tue, 21 Nov 2006 16:36:38 +0530
From: Balbir Singh <balbir@in.ibm.com>
Reply-To: balbir@in.ibm.com
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 5/8] RSS controller task migration support
References: <20061121100150.9ECCF1B6AC@openx4.frec.bull.fr>
In-Reply-To: <20061121100150.9ECCF1B6AC@openx4.frec.bull.fr>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Patrick.Le-Dot" <Patrick.Le-Dot@bull.net>
Cc: ckrm-tech@lists.sourceforge.net, dev@openvz.org, haveblue@us.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, rohitseth@google.com
List-ID: <linux-mm.kvack.org>

Patrick.Le-Dot wrote:
> On Fri, 17 Nov 2006 22:04:08 +0530
>> ...
>> I am not against guarantees, but
>>
>> Consider the following scenario, let's say we implement guarantees
>>
>> 1. If we account for kernel resources, how do you provide guarantees
>>    when you have non-reclaimable resources?
> 
> First, the current patch is based only on pages available in the
> struct mm.
> I doubt that these pages are "non-reclaimable"...

I am speaking of a scenario when we start supporting kernel accounting
and of-course the swapless case.

> 
> And guarantee should be ignored just because some kernel resources
> are marked "non-reclaimable" ?
> 

Ok.. but can you have a consistent guarantee definition with un-reclaimable
kernel resources? How do you define a guarantee in a consistent manner?
In my discussions earlier on lkml, I had suggested that we define guarantee
only for reclaimable resources and provide support only for them.

> 
>> 2. If a customer runs a system with swap turned off (which is quite
>>    common),
> 
> quite common, really ?

Yep, I was listening to a talk from a customer service expert and he
mentioned that it's used to boost performance.

> 
>>             then anonymous memory becomes irreclaimable. If a group
>>    takes more than it's fair share (exceeds its guarantee), you
>>    have scenario similar to 1 above.
> 
> That seems to be just a subset of the "guarantee+limit" model : if
> guarantee is not useful for you, don't use it.
> 
> I'm not saying that guarantee should be a magic piece of code working
> for everybody.
> 
> But we have to propose something for the customers who ask for a
> guarantee (ie using a system with swap turned on like me and this is
> quite common:-)
> 

Like I said I am not against guarantees, but do we have to implement
them in our first iteration?


> Patrick
>


-- 

	Balbir Singh,
	Linux Technology Center,
	IBM Software Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
