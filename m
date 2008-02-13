Date: Tue, 12 Feb 2008 16:57:19 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: RE: [ofa-general] Re: Demand paging for memory regions
In-Reply-To: <8A71B368A89016469F72CD08050AD334026D5C23@maui.asicdesigners.com>
Message-ID: <Pine.LNX.4.64.0802121656550.11628@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0802081540180.4291@schroedinger.engr.sgi.com><20080208234302.GH26564@sgi.com><20080208155641.2258ad2c.akpm@linux-foundation.org><Pine.LNX.4.64.0802081603430.4543@schroedinger.engr.sgi.com><adaprv70yyt.fsf@cisco.com><Pine.LNX.4.64.0802081614030.5115@schroedinger.engr.sgi.com><adalk5v0yi6.fsf@cisco.com><Pine.LNX.4.64.0802081634070.5298@schroedinger.engr.sgi.com><20080209012446.GB7051@v2.random><Pine.LNX.4.64.0802081725200.5445@schroedinger.engr.sgi.com><20080209015659.GC7051@v2.random><Pine.LNX.4.64.0802081813300.5602@schroedinger.engr.sgi.com><20080209075556.63062452@bree.surriel.com><Pine.LNX.4.64.0802091345490.12965@schroedinger.engr.sgi.com><ada3arzxgkz.fsf_-_@cisco.com><47B2174E.5000708@opengridcomputing.com><Pine.LNX.4.64.0802121408150.9591@schroedinger.engr.sgi.com>
 <adazlu5vlub.fsf@cisco.com> <8A71B368A89016469F72CD08050AD334026D5C23@maui.asicdesigners.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Felix Marti <felix@chelsio.com>
Cc: Roland Dreier <rdreier@cisco.com>, Rik van Riel <riel@redhat.com>, steiner@sgi.com, Andrea Arcangeli <andrea@qumranet.com>, a.p.zijlstra@chello.nl, izike@qumranet.com, linux-kernel@vger.kernel.org, avi@qumranet.com, linux-mm@kvack.org, daniel.blueman@quadrics.com, Robin Holt <holt@sgi.com>, general@lists.openfabrics.org, Andrew Morton <akpm@linux-foundation.org>, kvm-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

On Tue, 12 Feb 2008, Felix Marti wrote:

> > I don't know anything about the T3 internals, but it's not clear that
> > you could do this without a new chip design in general.  Lot's of RDMA
> > devices were designed expecting that when a packet arrives, the HW can
> > look up the bus address for a given memory region/offset and place the
> > packet immediately.  It seems like a major change to be able to
> > generate a "page fault" interrupt when a page isn't present, or even
> > just wait to scatter some data until the host finishes updating page
> > tables when the HW needs the translation.
> 
> That is correct, not a change we can make for T3. We could, in theory,
> deal with changing mappings though. The change would need to be
> synchronized though: the VM would need to tell us which mapping were
> about to change and the driver would then need to disable DMA to/from
> it, do the change and resume DMA.

Right. That is the intend of the patchset.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
