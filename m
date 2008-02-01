Date: Thu, 31 Jan 2008 20:43:58 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 2/3] mmu_notifier: Callbacks to invalidate address ranges
In-Reply-To: <20080201042408.GG26420@sgi.com>
Message-ID: <Pine.LNX.4.64.0801312042500.20675@schroedinger.engr.sgi.com>
References: <20080131045750.855008281@sgi.com> <20080131045812.785269387@sgi.com>
 <20080201042408.GG26420@sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Robin Holt <holt@sgi.com>
Cc: Andrea Arcangeli <andrea@qumranet.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, kvm-devel@lists.sourceforge.net, Peter Zijlstra <a.p.zijlstra@chello.nl>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com
List-ID: <linux-mm.kvack.org>

On Thu, 31 Jan 2008, Robin Holt wrote:

> > Index: linux-2.6/mm/memory.c
> ...
> > @@ -1668,6 +1678,7 @@ gotten:
> >  		page_cache_release(old_page);
> >  unlock:
> >  	pte_unmap_unlock(page_table, ptl);
> > +	mmu_notifier(invalidate_range_end, mm, 0);
> 
> I think we can get an _end call without the _begin call before it.

If that would be true then also the pte would have been left locked.

We always hit unlock. Maybe I just do not see it?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
