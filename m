Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by e23smtp04.au.ibm.com (8.13.1/8.13.1) with ESMTP id l8DKORrq001213
	for <linux-mm@kvack.org>; Fri, 14 Sep 2007 06:24:27 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l8DKLv3U1814754
	for <linux-mm@kvack.org>; Fri, 14 Sep 2007 06:21:57 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l8DKLu2E019888
	for <linux-mm@kvack.org>; Fri, 14 Sep 2007 06:21:56 +1000
Message-ID: <46E99BDE.9000602@linux.vnet.ibm.com>
Date: Fri, 14 Sep 2007 01:51:50 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: 2.6.23-rc4-mm1 memory controller BUG_ON()
References: <1189712083.17236.1626.camel@localhost>
In-Reply-To: <1189712083.17236.1626.camel@localhost>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: Balbir Singh <balbir@in.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Dave Hansen wrote:
> Looks like somebody is holding a lock while trying to do a
> mem_container_charge(), and the mem_container_charge() call is doing an
> allocation.  Naughty.
> 
> I'm digging into it a bit more, but thought I'd report it, first.
> 

Hi, Dave,

Thanks for reporting this. I sent out a patch to fix this problem
(suggested by Nick Piggin). The patch is available at

http://lkml.org/lkml/2007/9/12/113

Could you try the patch and check if the problem goes away?

Any pointers on how to reproduce the problem would be extremely useful.


-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
