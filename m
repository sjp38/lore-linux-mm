Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id C49586B0034
	for <linux-mm@kvack.org>; Thu,  4 Jul 2013 05:32:14 -0400 (EDT)
Date: Thu, 4 Jul 2013 10:32:11 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 12/13] mm: numa: Scan pages with elevated page_mapcount
Message-ID: <20130704093211.GN1875@suse.de>
References: <1372861300-9973-1-git-send-email-mgorman@suse.de>
 <1372861300-9973-13-git-send-email-mgorman@suse.de>
 <20130703184124.GD18898@dyad.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20130703184124.GD18898@dyad.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Jul 03, 2013 at 08:41:24PM +0200, Peter Zijlstra wrote:
> On Wed, Jul 03, 2013 at 03:21:39PM +0100, Mel Gorman wrote:
> 
> > Note that the patch still leaves shared, file-backed in VM_EXEC vmas in
> > place guessing that these are shared library pages. Migrating them are
> > likely to be of major benefit as generally the expectation would be that
> > these are read-shared between caches and that iTLB and iCache pressure is
> > generally low.
> 
> I'm failing to grasp.. we don't migrate them because migrating them would
> likely be beneficial?
> 
> Missing a negative somewhere?

Yes.

Note that the patch does not migrate shared, file-backed within vmas marked
VM_EXEC as these are generally shared library pages. Migrating such pages
is not beneficial as there is an expectation they are read-shared between
caches and iTLB and iCache pressure is generally low.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
