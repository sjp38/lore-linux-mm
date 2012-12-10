Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id 16F296B0062
	for <linux-mm@kvack.org>; Mon, 10 Dec 2012 03:44:14 -0500 (EST)
Date: Mon, 10 Dec 2012 08:44:06 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 00/49] Automatic NUMA Balancing v10
Message-ID: <20121210084406.GD1009@suse.de>
References: <1354875832-9700-1-git-send-email-mgorman@suse.de>
 <20121207110113.GB21482@gmail.com>
 <20121209203630.GC1009@suse.de>
 <20121209211708.GA29607@shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20121209211708.GA29607@shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Thomas Gleixner <tglx@linutronix.de>, Paul Turner <pjt@google.com>, Hillf Danton <dhillf@gmail.com>, David Rientjes <rientjes@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Alex Shi <lkml.alex@gmail.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Sun, Dec 09, 2012 at 11:17:09PM +0200, Kirill A. Shutemov wrote:
> On Sun, Dec 09, 2012 at 08:36:31PM +0000, Mel Gorman wrote:
> > Either way, last night I applied a patch on top of latest tip/master to
> > remove the nr_cpus_allowed check so that numacore would be enabled again
> > and tested that. In some places it has indeed much improved. In others
> > it is still regressing badly and in two case, it's corrupting memory --
> > specjbb when THP is enabled crashes when running for single or multiple
> > JVMs. It is likely that a zero page is being inserted due to a race with
> > migration and causes the JVM to throw a null pointer exception. Here is
> > the comparison on the rough off-chance you actually read it this time.
> 
> Are you talking about huge zero page, right?
> 

No, this is happening in tip/master which does not include the huge zero
page work yet. AFAIK, that's still queued in Andrew's tree for the next
merge window. It is possible that there will be collisions between numa
balancing and the huge zero page work but it hasn't happened yet.

> I've fixed a race in huge zero page implementation recently[1]. Symptoms
> were similar -- SIGSEGV in JVM. The patch is in mmotm-2012-12-05-16-56 and
> later.
> 

It might be a similar class of bug.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
