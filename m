Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id ABF266B00B0
	for <linux-mm@kvack.org>; Tue, 27 Nov 2012 18:50:10 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id bj3so5458436pad.14
        for <linux-mm@kvack.org>; Tue, 27 Nov 2012 15:50:10 -0800 (PST)
Date: Tue, 27 Nov 2012 15:50:07 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] mm: introduce a common interface for balloon pages
 mobility fix
In-Reply-To: <alpine.DEB.2.00.1211161402550.17853@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1211271549140.21752@chino.kir.corp.google.com>
References: <50a6581a.V3MmP/x4DXU9jUhJ%fengguang.wu@intel.com> <alpine.DEB.2.00.1211161147580.2788@chino.kir.corp.google.com> <20121116201035.GA18145@t510.redhat.com> <alpine.DEB.2.00.1211161402550.17853@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rafael Aquini <aquini@redhat.com>
Cc: kbuild test robot <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Michal Hocko <mhocko@suse.cz>

On Fri, 16 Nov 2012, David Rientjes wrote:

> > This is already addressed at v12 revision which is on mmtom queue already.
> > 
> 
> Ah, it was merged yesterday but it depends on TRANSPARENT_HUGEPAGE rather 
> than COMPACTION.  Why?  Surely thp is not the only thing that benefits 
> from keeping memory defragmented for high-order allocs.
> 

Ping on this?  The direct question was why depend on TRANSPARENT_HUGEPAGE 
rather than COMPACTION, i.e. why do only order-9 allocations benefit from 
defragmented memory rather than all high order allocations?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
