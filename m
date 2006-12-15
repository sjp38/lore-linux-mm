Received: from sd0208e0.au.ibm.com (d23rh904.au.ibm.com [202.81.18.202])
	by ausmtp04.au.ibm.com (8.13.8/8.13.5) with ESMTP id kBFAr0pi162646
	for <linux-mm@kvack.org>; Fri, 15 Dec 2006 21:53:05 +1100
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.250.244])
	by sd0208e0.au.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id kBFAhphi167254
	for <linux-mm@kvack.org>; Fri, 15 Dec 2006 21:43:56 +1100
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id kBFAeNre024325
	for <linux-mm@kvack.org>; Fri, 15 Dec 2006 21:40:23 +1100
Message-ID: <45827B8F.7080808@in.ibm.com>
Date: Fri, 15 Dec 2006 16:10:15 +0530
From: Balbir Singh <balbir@in.ibm.com>
Reply-To: balbir@in.ibm.com
MIME-Version: 1.0
Subject: Re: [ckrm-tech] [RFC][PATCH 5/5] RSS accounting at the page level
References: <20061215075751.AD3F41B6A7@openx4.frec.bull.fr>
In-Reply-To: <20061215075751.AD3F41B6A7@openx4.frec.bull.fr>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Patrick.Le-Dot" <Patrick.Le-Dot@bull.net>
Cc: ckrm-tech@lists.sourceforge.net, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Patrick.Le-Dot wrote:
>> ...
>> This would limit the numbers to groups to the word size on the machine.
> 
> yes, this should be the bigger disadvantage of this implementation...
> But may be acceptable for a prototype, at least to explain the concept ?
> 

I think we need to find a more efficient mechanism to track shared pages

> 
>> It would be interesting if we can support shared pages without any
>> changes to struct page.
> 
> I suppose that means you are on a system without kswapd...
> 
> Is everybody OK with that ?
> This is a question for the linux-mm list...
> 


No, I have kswapd, like I said earlier, I have a patch that uses rmap
information for detecting and accounting shared pages. I hope to
post a patch soon.

> 
>> Any particular reason for not implementing migration in this patch.
> 
> Nothing special, only incremental code, step by step.
> So first try to have a sane shared pages accounting...

Aah, ok

> 
>> Do you have any test results with this patch? Showing the effect of
>> tracking shared pages
> 
> Only the RSS counter after reboot (same hw/software config) :
> 
> with your patch :
> # mount -t container none /dev/container
> # cat /dev/container/memctlr.stats
> RSS Pages 10571
> 
> and with my shared pages accounting patch :
> # mount -t container none /dev/container
> # cat /dev/container/memctlr.stats
> RSS Pages 7329
> 
> 

Is there any way to print out the shared pages, I think it should
easy to track shared pages per container as an accountable parameter.

-- 

	Balbir Singh,
	Linux Technology Center,
	IBM Software Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
