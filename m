Date: Thu, 31 Jan 2008 18:41:57 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: mmu_notifier: invalidate_range for move_page_tables
In-Reply-To: <20080201023815.GC26420@sgi.com>
Message-ID: <Pine.LNX.4.64.0801311840100.26594@schroedinger.engr.sgi.com>
References: <20080131045750.855008281@sgi.com> <20080131045812.785269387@sgi.com>
 <20080131123118.GK7185@v2.random> <Pine.LNX.4.64.0801311355260.27804@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0801311421110.22290@schroedinger.engr.sgi.com>
 <20080201001355.GU7185@v2.random> <Pine.LNX.4.64.0801311752200.24427@schroedinger.engr.sgi.com>
 <20080201023815.GC26420@sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Robin Holt <holt@sgi.com>
Cc: Andrea Arcangeli <andrea@qumranet.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, kvm-devel@lists.sourceforge.net, Peter Zijlstra <a.p.zijlstra@chello.nl>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com
List-ID: <linux-mm.kvack.org>

On Thu, 31 Jan 2008, Robin Holt wrote:

> On Thu, Jan 31, 2008 at 05:57:25PM -0800, Christoph Lameter wrote:
> > Move page tables also needs to invalidate the external references
> > and hold new references off while moving page table entries.
> 
> I must admit to not having spent any time thinking about this, but aren't
> we moving the entries from one set of page tables to the other, leaving
> the pte_t entries unchanged.  I guess I should go look, but could you
> provide a quick pointer in the proper direction as to why we need to
> recall externals when the before and after look of these page tables
> will have the same information for the TLBs.

remap changes the address of pages in a process. The pages appear at 
another address. Thus the external pte will have the wrong information if 
not invalidated.

Do a

man mremap


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
