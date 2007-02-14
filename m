Received: from sd0208e0.au.ibm.com (d23rh904.au.ibm.com [202.81.18.202])
	by ausmtp04.au.ibm.com (8.13.8/8.13.8) with ESMTP id l1EH84OM274752
	for <linux-mm@kvack.org>; Thu, 15 Feb 2007 04:08:04 +1100
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.250.242])
	by sd0208e0.au.ibm.com (8.13.8/8.13.8/NCO v8.2) with ESMTP id l1EGtxDL155722
	for <linux-mm@kvack.org>; Thu, 15 Feb 2007 03:56:00 +1100
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l1EGqTFx028037
	for <linux-mm@kvack.org>; Thu, 15 Feb 2007 03:52:29 +1100
Message-ID: <45D33E49.8070909@in.ibm.com>
Date: Wed, 14 Feb 2007 22:22:25 +0530
From: Balbir Singh <balbir@in.ibm.com>
Reply-To: balbir@in.ibm.com
MIME-Version: 1.0
Subject: Re: [rfc][patch] rmap: more sanity checks
References: <20070214090425.GA14932@wotan.suse.de>
In-Reply-To: <20070214090425.GA14932@wotan.suse.de>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Andrea Arcangeli <andrea@suse.de>, Petr Tesarik <ptesarik@suse.cz>, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

Nick Piggin wrote:
> We have seen a bug in SLES9 that only gets picked up with Andrea's extra
> rmap checks that were removed from mainline.
> 
> Petr Tesarik has got a fix for the problem, which he is planning to send
> upstream. The issue is a specific condition that causes an anon page to be
> incorrectly inserted into the pagetables, outside a valid vma.
> 
> It would be nice to get some of these checks back into mainline, IMO. I
> wonder if I'm correct in thinking that checking the page index and mapping
> is not actually racy?
> 

I hope so, if that is indeed the case my patches for tracking and accounting
shared rss pages at

http://marc.theaimsgroup.com/?l=linux-mm&m=116738715329816&w=2

will get much simpler.

There used to be a rmap lock (PG_maplock bit) earlier to protect
rmap information

Please see

http://marc.theaimsgroup.com/?l=linux-mm&m=116738715302690&w=2

and

http://lkml.org/lkml/2004/7/12/241


	Regards,
	Balbir Singh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
