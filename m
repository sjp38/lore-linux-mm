Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e35.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id lBMKRf1m017210
	for <linux-mm@kvack.org>; Sat, 22 Dec 2007 15:27:41 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id lBMKRZ8F104000
	for <linux-mm@kvack.org>; Sat, 22 Dec 2007 13:27:40 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lBMKRZhv014696
	for <linux-mm@kvack.org>; Sat, 22 Dec 2007 13:27:35 -0700
Message-ID: <476D7334.4010301@linux.vnet.ibm.com>
Date: Sun, 23 Dec 2007 01:57:32 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [patch 00/20] VM pageout scalability improvements
References: <20071218211539.250334036@redhat.com>
In-Reply-To: <20071218211539.250334036@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, lee.shermerhorn@hp.com
List-ID: <linux-mm.kvack.org>

Rik van Riel wrote:
> On large memory systems, the VM can spend way too much time scanning
> through pages that it cannot (or should not) evict from memory. Not
> only does it use up CPU time, but it also provokes lock contention
> and can leave large systems under memory presure in a catatonic state.
> 

Hi, Rik,

I remember you mentioning that by large memory systems you mean systems
with at-least 128GB, does this definition still hold?

> This patch series improves VM scalability by:
> 
> 1) making the locking a little more scalable
> 
> 2) putting filesystem backed, swap backed and non-reclaimable pages
>    onto their own LRUs, so the system only scans the pages that it
>    can/should evict from memory
> 
> 3) switching to SEQ replacement for the anonymous LRUs, so the
>    number of pages that need to be scanned when the system
>    starts swapping is bound to a reasonable number
> 
> The noreclaim patches come verbatim from Lee Schermerhorn and
> Nick Piggin.  I have not taken a detailed look at them yet and
> all I have done is fix the rejects against the latest -mm kernel.
> 

Is there a consolidate patch available, it makes it easier to test.

> I am posting this series now because I would like to get more
> feedback, while I am studying and improving the noreclaim patches
> myself.
> 

What kind of tests show the problem? I'll try and review and test the code.

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
