Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id 9E5FB6B0032
	for <linux-mm@kvack.org>; Fri,  2 Aug 2013 15:56:53 -0400 (EDT)
Date: Fri, 2 Aug 2013 21:56:39 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH] mm, numa: Do not group on RO pages
Message-ID: <20130802195639.GU27162@twins.programming.kicks-ass.net>
References: <1373901620-2021-1-git-send-email-mgorman@suse.de>
 <20130730113857.GR3008@twins.programming.kicks-ass.net>
 <20130731150751.GA15144@twins.programming.kicks-ass.net>
 <51F93105.8020503@hp.com>
 <20130802164715.GP27162@twins.programming.kicks-ass.net>
 <20130802165032.GQ27162@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130802165032.GQ27162@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Don Morris <don.morris@hp.com>
Cc: Mel Gorman <mgorman@suse.de>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, riel@redhat.com

> +	/*
> +	 * Avoid grouping on DSO/COW pages in specific and RO pages
> +	 * in general, RO pages shouldn't hurt as much anyway since
> +	 * they can be in shared cache state.
> +	 */

OK, so that comment is crap. Its that you cannot work into RO pages and
this RO pages don't establish a collaboration.

> +	if (page_mapcount(page) != 1 && !pmd_write(pmd))
> +		flags |= TNF_NO_GROUP;

Rik also noted that mapcount == 1 will trivially not form groups. This
should indeed be so but I didn't test it without that clause.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
