Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id 4D71A6B004D
	for <linux-mm@kvack.org>; Mon,  7 Jan 2013 10:37:28 -0500 (EST)
Date: Mon, 7 Jan 2013 15:37:23 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 44/49] mm: numa: Add THP migration for the NUMA working
 set scanning fault case.
Message-ID: <20130107153723.GN3885@suse.de>
References: <1354875832-9700-1-git-send-email-mgorman@suse.de>
 <1354875832-9700-45-git-send-email-mgorman@suse.de>
 <20130105084229.GA3208@hacker.(null)>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20130105084229.GA3208@hacker.(null)>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Ingo Molnar <mingo@kernel.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Thomas Gleixner <tglx@linutronix.de>, Paul Turner <pjt@google.com>, Hillf Danton <dhillf@gmail.com>, David Rientjes <rientjes@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Alex Shi <lkml.alex@gmail.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Sat, Jan 05, 2013 at 04:42:29PM +0800, Wanpeng Li wrote:
> >+int numamigrate_isolate_page(pg_data_t *pgdat, struct page *page)
> >+{
> >+	int ret = 0;
> >
> > 	/* Avoid migrating to a node that is nearly full */
> > 	if (migrate_balanced_pgdat(pgdat, 1)) {
> 
> Hi Mel Gorman,
> 
> This parameter nr_migrate_pags = 1 is not correct, since balancenuma also 
> support THP in this patchset, the parameter should be 1 <= compound_order(page) 
> instead of 1. I'd rather change to something like:
> 

True. The impact is marginal because it only applies when a node is almost
full but it does mean that we do some unnecessary work before migration
fails anyway. I've added a TODO item to fix it when I next revisit NUMA
balancing. Thanks.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
