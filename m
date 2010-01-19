Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 045506B006A
	for <linux-mm@kvack.org>; Tue, 19 Jan 2010 08:01:08 -0500 (EST)
Date: Tue, 19 Jan 2010 13:00:55 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 1/7] Allow CONFIG_MIGRATION to be set without
	CONFIG_NUMA
Message-ID: <20100119130055.GC23881@csn.ul.ie>
References: <1262795169-9095-1-git-send-email-mel@csn.ul.ie> <1262795169-9095-2-git-send-email-mel@csn.ul.ie> <alpine.DEB.2.00.1001071331520.23894@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1001071331520.23894@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jan 07, 2010 at 01:46:03PM -0800, David Rientjes wrote:
> On Wed, 6 Jan 2010, Mel Gorman wrote:
> 
> > CONFIG_MIGRATION currently depends on CONFIG_NUMA. The current users of
> > page migration such as sys_move_pages(), sys_migrate_pages() and cpuset
> > process migration are ordinarily only beneficial on NUMA.
> > 
> > As memory compaction will operate within a zone and is useful on both NUMA
> > and non-NUMA systems, this patch allows CONFIG_MIGRATION to be set if the
> > user selects CONFIG_COMPACTION as an option.
> > 
> > TODO
> >   o After this patch is applied, the migration core is available but it
> >     also makes NUMA-specific features available. This is too much
> >     exposure so revisit this.
> > 
> 
> CONFIG_MIGRATION is no longer strictly dependent on CONFIG_NUMA since 
> ARCH_ENABLE_MEMORY_HOTREMOVE has allowed it to be configured for UMA 
> machines.  All strictly NUMA features in the migration core should be 
> isolated under its #ifdef CONFIG_NUMA (sys_move_pages()) in mm/migrate.c 
> or by simply not compiling mm/mempolicy.c (sys_migrate_pages()), so this 
> patch looks fine as is (although the "help" text for CONFIG_MIGRATION 
> could be updated to reflect that it's useful for both memory hot-remove 
> and now compaction).
> 

That does appear to be the case, thanks. I had not double-checked
closely and it was somewhat of a problem when the series was first
developed.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
