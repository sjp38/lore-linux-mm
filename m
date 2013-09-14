Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id 641B36B0031
	for <linux-mm@kvack.org>; Fri, 13 Sep 2013 22:57:54 -0400 (EDT)
Message-ID: <5233D09F.6040307@oracle.com>
Date: Sat, 14 Sep 2013 10:57:35 +0800
From: Bob Liu <bob.liu@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/50] Basic scheduler support for automatic NUMA balancing
 V7
References: <1378805550-29949-1-git-send-email-mgorman@suse.de>
In-Reply-To: <1378805550-29949-1-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

Hi Mel,

On 09/10/2013 05:31 PM, Mel Gorman wrote:
> It has been a long time since V6 of this series and time for an update. Much
> of this is now stabilised with the most important addition being the inclusion
> of Peter and Rik's work on grouping tasks that share pages together.
> 
> This series has a number of goals. It reduces overhead of automatic balancing
> through scan rate reduction and the avoidance of TLB flushes. It selects a
> preferred node and moves tasks towards their memory as well as moving memory
> toward their task. It handles shared pages and groups related tasks together.
> 

I found sometimes numa balancing will be broken after khugepaged
started, because khugepaged always allocate huge page from the node of
the first scanned normal page during collapsing.

A simple use case is when a user run his application interleaving all
nodes using "numactl --interleave=all xxxx".
But after khugepaged started most pages of his application will be
located to only one specific node.

I have a simple patch fix this issue in thread:
[PATCH 2/2] mm: thp: khugepaged: add policy for finding target node

I think this may related with this topic, I don't know whether this
series can also fix the issue I mentioned.

-- 
Regards,
-Bob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
