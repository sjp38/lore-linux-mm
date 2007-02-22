Received: from sd0208e0.au.ibm.com (d23rh904.au.ibm.com [202.81.18.202])
	by ausmtp04.au.ibm.com (8.13.8/8.13.8) with ESMTP id l1MFpwgI287650
	for <linux-mm@kvack.org>; Fri, 23 Feb 2007 02:51:58 +1100
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.250.242])
	by sd0208e0.au.ibm.com (8.13.8/8.13.8/NCO v8.2) with ESMTP id l1MFdTg6185352
	for <linux-mm@kvack.org>; Fri, 23 Feb 2007 02:39:30 +1100
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l1MFa0SK029193
	for <linux-mm@kvack.org>; Fri, 23 Feb 2007 02:36:00 +1100
Message-ID: <45DDB85D.209@in.ibm.com>
Date: Thu, 22 Feb 2007 21:05:57 +0530
From: Balbir Singh <balbir@in.ibm.com>
Reply-To: balbir@in.ibm.com
MIME-Version: 1.0
Subject: Re: [PATCH] Take anonymous pages off the LRU if we have no swap
References: <Pine.LNX.4.64.0702211409001.27422@schroedinger.engr.sgi.com> <45DCD309.5010109@redhat.com> <Pine.LNX.4.64.0702211600430.28364@schroedinger.engr.sgi.com> <45DCFD22.2020300@redhat.com> <Pine.LNX.4.64.0702211900340.29703@schroedinger.engr.sgi.com> <45DD88E3.2@redhat.com>
In-Reply-To: <45DD88E3.2@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Christoph Lameter <clameter@sgi.com>, akpm@linux-foundation.org, linux-mm@kvack.org, Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

Rik van Riel wrote:
> Christoph Lameter wrote:
>> On Wed, 21 Feb 2007, Rik van Riel wrote:
>>
> Absolutely.  I am convinced that the whole "swappiness" thing
> of scanning past the anonymous pages in order to find the page
> cache pages will fall apart on 256GB systems even with somewhat
> friendly workloads.
> 

That should probably make a good case for splitting the LRU
into unmapped and mapped page LRU's :-) I hope to get to it,
implement it and get some results.

A big global LRU is like a big piece of software that is requesting
to be broken up. Scanning through uninteresting pages (in my case
searching for pages belonging to particular container for my
memory controller) is a big overhead.


-- 
	Warm Regards,
	Balbir Singh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
