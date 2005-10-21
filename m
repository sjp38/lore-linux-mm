Date: Fri, 21 Oct 2005 08:54:52 -0700 (PDT)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: [PATCH 0/4] Swap migration V3: Overview
In-Reply-To: <20051020160638.58b4d08d.akpm@osdl.org>
Message-ID: <Pine.LNX.4.62.0510210850520.23212@schroedinger.engr.sgi.com>
References: <20051020225935.19761.57434.sendpatchset@schroedinger.engr.sgi.com>
 <20051020160638.58b4d08d.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: kravetz@us.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, magnus.damm@gmail.com, marcelo.tosatti@cyclades.com
List-ID: <linux-mm.kvack.org>

On Thu, 20 Oct 2005, Andrew Morton wrote:

> Christoph Lameter <clameter@sgi.com> wrote:
> >
> > Page migration is also useful for other purposes:
> > 
> >  1. Memory hotplug. Migrating processes off a memory node that is going
> >     to be disconnected.
> > 
> >  2. Remapping of bad pages. These could be detected through soft ECC errors
> >     and other mechanisms.
> 
> It's only useful for these things if it works with close-to-100% reliability.

I think we need to gradually get there. There are other measures 
implemented by the hotplug that can work in conjunction with these patches 
to increase the likelyhood of successful migration.

Pages that are not on the LRU are very difficult to move and the hotplug 
project addresses that by not allowing allocation in areas that may be 
removed etc.

> And there are are all sorts of things which will prevent that - mlock,
> ongoing direct-io, hugepages, whatever.

Right. But these are not a problem for the page migration of processes in 
order to optimize performance. The hotplug and the remapping of bad pages 
will require additional effort to get done right. Nevertheless, the 
material presented here can be used as a basis.
 
> So before we can commit ourselves to the initial parts of this path we'd
> need some reassurance that the overall scheme addresses these things and
> that the end result has a high probability of supporting hot unplug and
> remapping sufficiently well.

I think we have that assurance. The hotplug project has worked on these 
patches for a long time and what we need is a way to gradually put these 
things into the kernel. We are trying to facilitate that with these 
patches.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
