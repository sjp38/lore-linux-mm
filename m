Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id 90E086B0033
	for <linux-mm@kvack.org>; Mon, 26 Aug 2013 12:15:02 -0400 (EDT)
Date: Mon, 26 Aug 2013 18:14:57 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH] mm, sched, numa: Create a per-task MPOL_INTERLEAVE policy
Message-ID: <20130826161457.GB10002@twins.programming.kicks-ass.net>
References: <1373901620-2021-1-git-send-email-mgorman@suse.de>
 <20130725104633.GQ27075@twins.programming.kicks-ass.net>
 <20130726095528.GB20909@twins.programming.kicks-ass.net>
 <20130826161027.GA10002@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130826161027.GA10002@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, Aug 26, 2013 at 06:10:27PM +0200, Peter Zijlstra wrote:
> +	if (pol == new) {
> +		/*
> +		 * XXX 'borrowed' from do_set_mempolicy()

This should probably also say something like:

 /*
  * This is safe without holding mm->mmap_sem for show_numa_map()
  * because this is only used for a NULL->pol transition, not
  * pol1->pol2 transitions.
  */

> +		 */
> +		pol->v.nodes = nodes;
> +		p->mempolicy = pol;
> +		p->flags |= PF_MEMPOLICY;
> +		p->il_next = first_node(nodes);
> +		new = NULL;
> +	} else {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
