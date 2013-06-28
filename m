Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id 497466B0032
	for <linux-mm@kvack.org>; Fri, 28 Jun 2013 11:10:57 -0400 (EDT)
Date: Fri, 28 Jun 2013 17:10:48 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 5/8] sched: Favour moving tasks towards the preferred node
Message-ID: <20130628151048.GB6626@twins.programming.kicks-ass.net>
References: <1372257487-9749-1-git-send-email-mgorman@suse.de>
 <1372257487-9749-6-git-send-email-mgorman@suse.de>
 <20130627161127.GZ28407@twins.programming.kicks-ass.net>
 <20130628134535.GX1875@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130628134535.GX1875@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, Jun 28, 2013 at 02:45:35PM +0100, Mel Gorman wrote:

> > Also, until I just actually _read_ that function; I assumed it would
> > compare p->numa_faults[src_nid] and p->numa_faults[dst_nid]. Because
> > even when the dst_nid isn't the preferred nid; it might still have more
> > pages than where we currently are.
> > 
> 
> I tested something like this and also tested it when only taking shared
> accesses into account but it performed badly in some cases.  I've included
> the last patch I tested below for reference but dropped it until I figured
> out why it performed badly. I guessed it was due to increased bouncing
> due to shared faults but didn't prove it.

Oh, interesting. Yeah it would be good to figure out why that gave
funnies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
