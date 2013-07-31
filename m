Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx174.postini.com [74.125.245.174])
	by kanga.kvack.org (Postfix) with SMTP id 5A5596B0032
	for <linux-mm@kvack.org>; Wed, 31 Jul 2013 05:08:33 -0400 (EDT)
Date: Wed, 31 Jul 2013 10:08:29 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 09/18] sched: Add infrastructure for split shared/private
 accounting of NUMA hinting faults
Message-ID: <20130731090829.GJ2296@suse.de>
References: <1373901620-2021-1-git-send-email-mgorman@suse.de>
 <1373901620-2021-10-git-send-email-mgorman@suse.de>
 <CAJd=RBDhYMifi8hp7dX5TQrAegNwmaU9wYPtHCjBv5Dhp1E4BQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <CAJd=RBDhYMifi8hp7dX5TQrAegNwmaU9wYPtHCjBv5Dhp1E4BQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Jul 17, 2013 at 10:17:29AM +0800, Hillf Danton wrote:
> On Mon, Jul 15, 2013 at 11:20 PM, Mel Gorman <mgorman@suse.de> wrote:
> >  /*
> >   * Got a PROT_NONE fault for a page on @node.
> >   */
> > -void task_numa_fault(int node, int pages, bool migrated)
> > +void task_numa_fault(int last_nid, int node, int pages, bool migrated)
> 
> For what is the new parameter?
> 

To weight the fault heavier if the page was migrated due to being
improperly placed at fault time.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
