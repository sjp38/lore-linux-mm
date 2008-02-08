Date: Fri, 8 Feb 2008 17:36:37 -0600
From: Robin Holt <holt@sgi.com>
Subject: Re: [patch 0/6] MMU Notifiers V6
Message-ID: <20080208233636.GG26564@sgi.com>
References: <20080208220616.089936205@sgi.com> <20080208142315.7fe4b95e.akpm@linux-foundation.org> <Pine.LNX.4.64.0802081528070.4036@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0802081528070.4036@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, andrea@qumranet.com, holt@sgi.com, avi@qumranet.com, izike@qumranet.com, kvm-devel@lists.sourceforge.net, a.p.zijlstra@chello.nl, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com, general@lists.openfabrics.org
List-ID: <linux-mm.kvack.org>

On Fri, Feb 08, 2008 at 03:32:19PM -0800, Christoph Lameter wrote:
> On Fri, 8 Feb 2008, Andrew Morton wrote:
> 
> > What about ib_umem_get()?
> 
> Ok. It pins using an elevated refcount. Same as XPmem right now. With that 
> we effectively pin a page (page migration will fail) but we will 
> continually be reclaiming the page and may repeatedly try to move it. We 
> have issues with XPmem causing too many pages to be pinned and thus the 
> OOM getting into weird behavior modes (OOM or stop lru scanning due to 
> all_reclaimable set).
> 
> An elevated refcount will also not be noticed by any of the schemes under 
> consideration to improve LRU scanning performance.

Christoph, I am not sure what you are saying here.  With v4 and later,
I thought we were able to use the rmap invalidation to remove the ref
count that XPMEM was holding and therefore be able to swapout.  Did I miss
something?  I agree the existing XPMEM does pin.  I hope we are not saying
the XPMEM based upon these patches will not be able to swap/migrate.

Thanks,
Robin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
