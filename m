Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx174.postini.com [74.125.245.174])
	by kanga.kvack.org (Postfix) with SMTP id 5C8A26B002B
	for <linux-mm@kvack.org>; Fri, 16 Nov 2012 17:03:48 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id fa10so2336095pad.14
        for <linux-mm@kvack.org>; Fri, 16 Nov 2012 14:03:47 -0800 (PST)
Date: Fri, 16 Nov 2012 14:03:45 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] mm: introduce a common interface for balloon pages
 mobility fix
In-Reply-To: <20121116201035.GA18145@t510.redhat.com>
Message-ID: <alpine.DEB.2.00.1211161402550.17853@chino.kir.corp.google.com>
References: <50a6581a.V3MmP/x4DXU9jUhJ%fengguang.wu@intel.com> <alpine.DEB.2.00.1211161147580.2788@chino.kir.corp.google.com> <20121116201035.GA18145@t510.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rafael Aquini <aquini@redhat.com>
Cc: kbuild test robot <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Michal Hocko <mhocko@suse.cz>

On Fri, 16 Nov 2012, Rafael Aquini wrote:

> > > tree:   git://git.kernel.org/pub/scm/linux/kernel/git/mhocko/mm.git since-3.6
> > > head:   12dfb061e5fd15be23451418da01281625c0eeae
> > > commit: 86929cfa5f751de3d8be5a846535282730865d8a [365/437] mm: introduce a common interface for balloon pages mobility
> > > config: make ARCH=sh allyesconfig
> > > 
> > > All warnings:
> > > 
> > > warning: (BALLOON_COMPACTION && TRANSPARENT_HUGEPAGE) selects COMPACTION which has unmet direct dependencies (MMU)
> > > warning: (BALLOON_COMPACTION && TRANSPARENT_HUGEPAGE) selects COMPACTION which has unmet direct dependencies (MMU)
> > > --
> > > warning: (BALLOON_COMPACTION && TRANSPARENT_HUGEPAGE) selects COMPACTION which has unmet direct dependencies (MMU)
> > > 
> > 
> > mm: introduce a common interface for balloon pages mobility fix
> > 
> > CONFIG_BALLOON_COMPACTION shouldn't be selecting options that may not be 
> > supported, so make it depend on memory compaction rather than selecting 
> > it.  CONFIG_COMPACTION is enabled by default for all configs that support 
> > it.
> >     
> 
> This is already addressed at v12 revision which is on mmtom queue already.
> 

Ah, it was merged yesterday but it depends on TRANSPARENT_HUGEPAGE rather 
than COMPACTION.  Why?  Surely thp is not the only thing that benefits 
from keeping memory defragmented for high-order allocs.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
