Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by e23smtp05.au.ibm.com (8.13.1/8.13.1) with ESMTP id l8P6I9Zw013372
	for <linux-mm@kvack.org>; Tue, 25 Sep 2007 16:18:09 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l8P6LfCj260850
	for <linux-mm@kvack.org>; Tue, 25 Sep 2007 16:21:42 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l8P6Hp8Y011130
	for <linux-mm@kvack.org>; Tue, 25 Sep 2007 16:17:52 +1000
Message-ID: <46F8A7FE.7000907@linux.vnet.ibm.com>
Date: Tue, 25 Sep 2007 11:47:34 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [patch -mm 4/5] mm: test and set zone reclaim lock before starting
 reclaim
References: <alpine.DEB.0.9999.0709212311130.13727@chino.kir.corp.google.com> <alpine.DEB.0.9999.0709212312160.13727@chino.kir.corp.google.com> <alpine.DEB.0.9999.0709212312400.13727@chino.kir.corp.google.com> <alpine.DEB.0.9999.0709212312560.13727@chino.kir.corp.google.com> <46F88DFB.3020307@linux.vnet.ibm.com> <alpine.DEB.0.9999.0709242129420.31515@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.0.9999.0709242129420.31515@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <andrea@suse.de>, Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

David Rientjes wrote:
> On Tue, 25 Sep 2007, Balbir Singh wrote:
> 
>>> +
>>> +	if (zone_test_and_set_flag(zone, ZONE_RECLAIM_LOCKED))
>>> +		return 0;
>> What's the consequence of this on the caller of zone_reclaim()?
>> I see that the zone is marked as full and will not be re-examined
>> again.
>>
> 
> It's only marked as full in the zonelist cache for the zonelist that 
> __alloc_pages() was called with, which is an optimization.  The zone is 
> already flagged as being in __zone_reclaim() so there's no need to 
> reinvoke it for this allocation attempt; that behavior is unchanged from 
> current behavior.
> 

OK

> One thing that has been changed in -mm with regard to my last patchset is 
> that kswapd and try_to_free_pages() are allowed to call shrink_zone() 
> concurrently.
> 

Aah.. interesting. Could you define concurrently more precisely,
concurrently as in the same zone or for different zones concurrently?

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
