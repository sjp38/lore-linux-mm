Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id 5B3756B005C
	for <linux-mm@kvack.org>; Thu, 31 May 2012 15:28:31 -0400 (EDT)
Date: Thu, 31 May 2012 12:28:29 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2] tmpfs not interleaving properly
Message-Id: <20120531122829.8c478372.akpm@linux-foundation.org>
In-Reply-To: <20120531143916.GA16162@gulag1.americas.sgi.com>
References: <20120531143916.GA16162@gulag1.americas.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nathan Zimmer <nzimmer@sgi.com>
Cc: hughd@google.com, npiggin@gmail.com, cl@linux.com, lee.schermerhorn@hp.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, stable@vger.kernel.org, riel@redhat.com

On Thu, 31 May 2012 09:39:17 -0500
Nathan Zimmer <nzimmer@sgi.com> wrote:

> When tmpfs has the memory policy interleaved it always starts allocating at each
> file at node 0.  When there are many small files the lower nodes fill up
> disproportionately.
> This patch attempts to spread out node usage by starting files at nodes other
> then 0.  I disturbed the addr parameter since alloc_pages_vma will only use it
> when the policy is MPOL_INTERLEAVE.  Random was picked over using another
> variable which would require some sort of contention management.

The patch title is a bit scummy ;) It describes a kernel problem, not
the patch.  I renamed it to "tmpfs: implement NUMA node interleaving".

It looks nice and simple

> Cc: stable@vger.kernel.org

We could probably sneak this past Greg, but should we?  It's a feature
and a performance enhancement.  Such things are not normally added to
-stable.  If there were some nice performance improvements in workloads
which our users care about then I guess we could backport it.

But you've provided us with no measurements at all, hence no reason to
backport it.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
