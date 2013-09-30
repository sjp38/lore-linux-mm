Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 2E8A26B003B
	for <linux-mm@kvack.org>; Mon, 30 Sep 2013 06:30:44 -0400 (EDT)
Received: by mail-pd0-f177.google.com with SMTP id y10so5426697pdj.8
        for <linux-mm@kvack.org>; Mon, 30 Sep 2013 03:30:43 -0700 (PDT)
Date: Mon, 30 Sep 2013 11:30:37 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 0/50] Basic scheduler support for automatic NUMA
 balancing V7
Message-ID: <20130930103037.GE2425@suse.de>
References: <1378805550-29949-1-git-send-email-mgorman@suse.de>
 <5233D09F.6040307@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <5233D09F.6040307@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <bob.liu@oracle.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Sat, Sep 14, 2013 at 10:57:35AM +0800, Bob Liu wrote:
> Hi Mel,
> 
> On 09/10/2013 05:31 PM, Mel Gorman wrote:
> > It has been a long time since V6 of this series and time for an update. Much
> > of this is now stabilised with the most important addition being the inclusion
> > of Peter and Rik's work on grouping tasks that share pages together.
> > 
> > This series has a number of goals. It reduces overhead of automatic balancing
> > through scan rate reduction and the avoidance of TLB flushes. It selects a
> > preferred node and moves tasks towards their memory as well as moving memory
> > toward their task. It handles shared pages and groups related tasks together.
> > 
> 
> I found sometimes numa balancing will be broken after khugepaged
> started, because khugepaged always allocate huge page from the node of
> the first scanned normal page during collapsing.
> 

This is a real, but separate problem.

> I think this may related with this topic, I don't know whether this
> series can also fix the issue I mentioned.
> 

This series does not aim to fix that particular problem. There will be
some interactions between the problems as automatic NUMA balancing deals
with THP migration but they are only indirectly related. If khugepaged
does not collapse to huge pages inappropriately then automatic NUMA
balancing will never encounter them.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
