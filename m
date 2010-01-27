Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 682096B0071
	for <linux-mm@kvack.org>; Wed, 27 Jan 2010 06:27:07 -0500 (EST)
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by e28smtp03.in.ibm.com (8.14.3/8.13.1) with ESMTP id o0RBR2Ce014710
	for <linux-mm@kvack.org>; Wed, 27 Jan 2010 16:57:02 +0530
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o0RBR25Z606414
	for <linux-mm@kvack.org>; Wed, 27 Jan 2010 16:57:02 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o0RBR1ZE031457
	for <linux-mm@kvack.org>; Wed, 27 Jan 2010 22:27:01 +1100
Message-ID: <4B602304.9000709@linux.vnet.ibm.com>
Date: Wed, 27 Jan 2010 16:57:00 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [PATCH 28 of 30] memcg huge memory
References: <patchbomb.1264054824@v2.random> <4c405faf58cfe5d1aa6e.1264054852@v2.random> <20100121161601.6612fd79.kamezawa.hiroyu@jp.fujitsu.com> <20100121160807.GB5598@random.random> <20100122091317.39db5546.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100122091317.39db5546.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Friday 22 January 2010 05:43 AM, KAMEZAWA Hiroyuki wrote:
> 
>> Now the only real pain remains in the LRU list accounting, I tried to
>> solve it but found no clean way that didn't require mess all over
>> vmscan.c. So for now hugepages in lru are accounted as 4k pages
>> ;). Nothing breaks just stats won't be as useful to the admin...
>>
> Hmm, interesting/important problem...I keep it in my mind.

I hope the memcg accounting is not broken, I see you do the right thing
while charging pages. The patch overall seems alright. Could you please
update the Documentation/cgroups/memory.txt file as well with what these
changes mean and memcg_tests.txt to indicate how to test the changes?

-- 
Three Cheers,
Balbir Singh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
