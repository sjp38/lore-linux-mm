Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id B71F56B00B2
	for <linux-mm@kvack.org>; Tue, 27 Nov 2012 19:04:08 -0500 (EST)
Date: Tue, 27 Nov 2012 22:03:56 -0200
From: Rafael Aquini <aquini@redhat.com>
Subject: Re: [patch] mm: introduce a common interface for balloon pages
 mobility fix
Message-ID: <20121128000355.GA7401@t510.redhat.com>
References: <50a6581a.V3MmP/x4DXU9jUhJ%fengguang.wu@intel.com>
 <alpine.DEB.2.00.1211161147580.2788@chino.kir.corp.google.com>
 <20121116201035.GA18145@t510.redhat.com>
 <alpine.DEB.2.00.1211161402550.17853@chino.kir.corp.google.com>
 <alpine.DEB.2.00.1211271549140.21752@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1211271549140.21752@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: kbuild test robot <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Michal Hocko <mhocko@suse.cz>

On Tue, Nov 27, 2012 at 03:50:07PM -0800, David Rientjes wrote:
> On Fri, 16 Nov 2012, David Rientjes wrote:
> 
> > > This is already addressed at v12 revision which is on mmtom queue already.
> > > 
> > 
> > Ah, it was merged yesterday but it depends on TRANSPARENT_HUGEPAGE rather 
> > than COMPACTION.  Why?  Surely thp is not the only thing that benefits 
> > from keeping memory defragmented for high-order allocs.
> > 
> 
> Ping on this?  The direct question was why depend on TRANSPARENT_HUGEPAGE 
> rather than COMPACTION, i.e. why do only order-9 allocations benefit from 
> defragmented memory rather than all high order allocations?
> 
> Thanks.

Ugh, I missed this one on the mail pile.

That's a nice feature for all system, indeed. I'd say you're 100% right. Would
you mind in submitting the change?

Thanks David, and sorry sorry for the late reply.

Rafael

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
