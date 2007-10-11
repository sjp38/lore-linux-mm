Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by e23smtp02.au.ibm.com (8.13.1/8.13.1) with ESMTP id l9B6XmMd027651
	for <linux-mm@kvack.org>; Thu, 11 Oct 2007 16:33:48 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9B6XluF4559040
	for <linux-mm@kvack.org>; Thu, 11 Oct 2007 16:33:47 +1000
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9B6UsLZ023828
	for <linux-mm@kvack.org>; Thu, 11 Oct 2007 16:30:54 +1000
Message-ID: <470DC3A4.1000703@linux.vnet.ibm.com>
Date: Thu, 11 Oct 2007 12:03:08 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: Memory controller merge (was Re: -mm merge plans for 2.6.24)
References: <20071001142222.fcaa8d57.akpm@linux-foundation.org> <4701C737.8070906@linux.vnet.ibm.com> <20071010170702.34fb3eee@cuia.boston.redhat.com>
In-Reply-To: <20071010170702.34fb3eee@cuia.boston.redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Rik van Riel wrote:
> On Tue, 02 Oct 2007 09:51:11 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
>> I was hopeful of getting the bare minimal infrastructure for memory
>> control in mainline, so that review is easy and additional changes
>> can be well reviewed as well.
> 
> I am not yet convinced that the way the memory controller code and
> lumpy reclaim have been merged is correct.  I am combing through the
> code now and will send in a patch when I figure out if/what is wrong.
> 

Hi, Rik,

Do you mean the way the memory controller and lumpy reclaim work
together? The reclaim in memory controller (on hitting the limit) is not
lumpy. Would you like to see that change?

Please do share your findings in the form of comments or patches.

> I ran into this because I'm trying to merge the split VM code up to
> the latest -mm...
> 

Interesting, I'll see if I can find some spare test cycles to help test
this code.


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
