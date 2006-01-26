Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e35.co.us.ibm.com (8.12.11/8.12.11) with ESMTP id k0QMvCci006772
	for <linux-mm@kvack.org>; Thu, 26 Jan 2006 17:57:12 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.12.10/NCO/VERS6.8) with ESMTP id k0QMxSUO113518
	for <linux-mm@kvack.org>; Thu, 26 Jan 2006 15:59:28 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id k0QMvB0S000417
	for <linux-mm@kvack.org>; Thu, 26 Jan 2006 15:57:11 -0700
Message-ID: <43D953C4.5020205@us.ibm.com>
Date: Thu, 26 Jan 2006 14:57:08 -0800
From: Matthew Dobson <colpatch@us.ibm.com>
MIME-Version: 1.0
Subject: Re: [patch 3/9] mempool - Make mempools NUMA aware
References: <20060125161321.647368000@localhost.localdomain> <1138233093.27293.1.camel@localhost.localdomain> <Pine.LNX.4.62.0601260953200.15128@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.62.0601260953200.15128@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: linux-kernel@vger.kernel.org, sri@us.ibm.com, andrea@suse.de, pavel@suse.cz, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> On Wed, 25 Jan 2006, Matthew Dobson wrote:
> 
> 
>>plain text document attachment (critical_mempools)
>>Add NUMA-awareness to the mempool code.  This involves several changes:
> 
> 
> I am not quite sure why you would need numa awareness in an emergency 
> memory pool. Presumably the effectiveness of the accesses do not matter. 
> You only want to be sure that there is some memory available right?

Not all requests for memory from a specific node are performance
enhancements, some are for correctness.  With large machines, especially as
those large machines' workloads are more and more likely to be partitioned
with something like cpusets, you want to be able to specify where you want
your reserve pool to come from.  As it was not incredibly difficult to
offer this option, I added it.  I was unwilling to completely ignore
callers' NUMA requests, assuming that they are all purely performance
motivated.


> You do not need this.... 

I do not agree...


Thanks!

-Matt

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
