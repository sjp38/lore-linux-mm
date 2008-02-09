Date: Fri, 8 Feb 2008 16:16:34 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [ofa-general] Re: [patch 0/6] MMU Notifiers V6
In-Reply-To: <adaprv70yyt.fsf@cisco.com>
Message-ID: <Pine.LNX.4.64.0802081614030.5115@schroedinger.engr.sgi.com>
References: <20080208220616.089936205@sgi.com> <20080208142315.7fe4b95e.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0802081528070.4036@schroedinger.engr.sgi.com>
 <20080208233636.GG26564@sgi.com> <Pine.LNX.4.64.0802081540180.4291@schroedinger.engr.sgi.com>
 <20080208234302.GH26564@sgi.com> <20080208155641.2258ad2c.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0802081603430.4543@schroedinger.engr.sgi.com>
 <adaprv70yyt.fsf@cisco.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Roland Dreier <rdreier@cisco.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, andrea@qumranet.com, a.p.zijlstra@chello.nl, linux-mm@kvack.org, izike@qumranet.com, steiner@sgi.com, linux-kernel@vger.kernel.org, avi@qumranet.com, kvm-devel@lists.sourceforge.net, daniel.blueman@quadrics.com, Robin Holt <holt@sgi.com>, general@lists.openfabrics.org
List-ID: <linux-mm.kvack.org>

On Fri, 8 Feb 2008, Roland Dreier wrote:

> In general, this MMU notifier stuff will only be useful to a subset of
> InfiniBand/RDMA hardware.  Some adapters are smart enough to handle
> changing the IO virtual -> bus/physical mapping on the fly, but some
> aren't.  For the dumb adapters, I think the current ib_umem_get() is
> pretty close to as good as we can get: we have to keep the physical
> pages pinned for as long as the adapter is allowed to DMA into the
> memory region.

I thought the adaptor can always remove the mapping by renegotiating 
with the remote side? Even if its dumb then a callback could notify the 
driver that it may be required to tear down the mapping. We then hold the 
pages until we get okay by the driver that the mapping has been removed.

We could also let the unmapping fail if the driver indicates that the 
mapping must stay.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
