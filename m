From: Daniel Phillips <phillips@phunq.net>
Subject: Re: [PATCH 00/10] foundations for reserve-based allocation
Date: Mon, 6 Aug 2007 17:09:54 -0700
References: <20070806102922.907530000@chello.nl> <20070806202323.GH11115@waste.org>
In-Reply-To: <20070806202323.GH11115@waste.org>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200708061709.54924.phillips@phunq.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matt Mackall <mpm@selenic.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, Daniel Phillips <phillips@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Christoph Lameter <clameter@sgi.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Steve Dickson <SteveD@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi Matt,

On Monday 06 August 2007 13:23, Matt Mackall wrote:
> On Mon, Aug 06, 2007 at 12:29:22PM +0200, Peter Zijlstra wrote:
> > In the interrest of getting swap over network working and posting
> > in smaller series, here is the first series.
> >
> > This series lays the foundations needed to do reserve based
> > allocation. Traditionally we have used mempools (and others like
> > radix_tree_preload) to handle the problem.
> >
> > However this does not fit the network stack. It is built around
> > variable sized allocations using kmalloc().
> >
> > This calls for a different approach.
>
> One wonders if containers are a possible solution. I can already
> solve this problem with virtualization: have one VM manage all the
> network I/O and export the device as a simpler virtual block device
> to other VMs. Provided this VM isn't doing any "real" work and is
> sized appropriately, it won't get wedged. Since the other VMs now
> submit I/O through the simpler block interface, they can avoid
> getting wedged with the standard mempool approach.

The patch set posted today amounts to hardly any new bytes of code at 
all, and the other necessary bits coming down the pipe are not much 
heavier.  Compare to dedicating a whole VM to supressing just one of 
the symptoms.  Much better just to cure the disease and save your VM 
for a more noble purpose.

> If we can run nbd and friends inside their own container that can
> give similar isolation, we might not need to add this other
> complexity.

This patch set fixes a severe problem that is so far unfixed in spite of 
a number of attempts, and does it in a simple way that translates into 
a small amount of code.  If it comes across as complex, that is a 
matter of presentation and tweaking.  Subtle, yes, but not complex.

> Just food for thought. I haven't looked closely enough at the
> containers implementations yet to determine whether this is possible
> or if the overhead in performance or complexity is acceptable.

Immensely more overhead than Peter's patches.

Regards,

Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
