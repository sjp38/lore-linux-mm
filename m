Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by e23smtp04.au.ibm.com (8.13.1/8.13.1) with ESMTP id l8DKPLa8001571
	for <linux-mm@kvack.org>; Fri, 14 Sep 2007 06:25:21 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l8DKPMgl4173902
	for <linux-mm@kvack.org>; Fri, 14 Sep 2007 06:25:22 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l8DKP5fZ022951
	for <linux-mm@kvack.org>; Fri, 14 Sep 2007 06:25:06 +1000
Message-ID: <46E99C92.9060800@linux.vnet.ibm.com>
Date: Fri, 14 Sep 2007 01:54:50 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: 2.6.23-rc4-mm1 memory controller BUG_ON()
References: <1189712083.17236.1626.camel@localhost> <1189713102.17236.1647.camel@localhost>
In-Reply-To: <1189713102.17236.1647.camel@localhost>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: Balbir Singh <balbir@in.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Dave Hansen wrote:
> On Thu, 2007-09-13 at 12:34 -0700, Dave Hansen wrote:
>> Looks like somebody is holding a lock while trying to do a
>> mem_container_charge(), and the mem_container_charge() call is doing an
>> allocation.  Naughty.
>>
>> I'm digging into it a bit more, but thought I'd report it, first.
>>
>> .config: http://sr71.net/~dave/linux/memory-controller-bug.config
> 
> I'm now thinking this is because the add_to_page_cache() functions have
> a gfp_mask passed in, and the mem_container_charge() functions don't
> take that mask.  So, even if the add_to_page_cache() user specified !
> __GFP_WAIT, the mem_container_charge() function can sleep on its
> kmalloc.
> 
> I'll try passing gfp_flags through to it and see what happens.
> 

Please see my patch at

http://lkml.org/lkml/2007/9/12/113 and some more details as a reply
to your earlier email.


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
