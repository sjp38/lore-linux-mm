Date: Wed, 4 Jul 2001 08:16:12 -0300 (BRT)
From: Marcelo Tosatti <marcelo@conectiva.com.br>
Subject: Re: [PATCH] initial detailed VM statistics code
In-Reply-To: <3B42D689.97809E5@earthlink.net>
Message-ID: <Pine.LNX.4.21.0107040814230.4010-100000@freak.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Joseph A. Knapka" <jknapka@earthlink.net>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Wed, 4 Jul 2001, Joseph A. Knapka wrote:

> Marcelo Tosatti wrote:
> > 
> > On Wed, 4 Jul 2001, Joseph A. Knapka wrote:
> > 
> > > Marcelo Tosatti wrote:
> > > >
> > > > Hi,
> > > >
> > > > Well, I've started working on VM stats code for 2.4.
> > > >
> > >
> > > Thanks.
> > >
> > > It might be useful to have a count of the number of PTEs scanned
> > > by swap_out(), and the number of those that were unmapped. (I'm
> > > interested in the scan rate of swap_out() vs refill_inactive_scan()).
> > 
> > Hum,
> > 
> > The number of pages with age 0 which have mapped PTEs (thus cannot be
> > freed) is what you're looking for ?
> 
> Well, I'm just not sure :-)  I'm looking for anything practical that
> would give insight into the VM system. Maybe if I looked at PTE
> scan rates and page frame scan rates for a while I'd conclude that
> in fact, age-zero-but-unfreeable-page-count is a critical number (it
> seems like it would be). But maybe I'd conclude something else.
> 
> I guess from a purely pedagogical standpoint, I'm interested in
> knowing the general shape of the mapping from VM onto physical
> memory at a given time - how much total virtual space is being
> mapped into RAM, and how it's shared, and whether VM is
> scanned at approximately the same relative rate as physical
> RAM. That information may be utterly useless from a VM
> tuning standpoint, I don't know.
> 
> It would, IMO, be nice to have as much VM state as possible
> exported for use by modules (if requested by the user at
> configuration time), so that we can gather whatever statistics
> we want without patching the kernel a lot.

Well, I'll add the nr of scanned/deactivated pte's anyway.

The information is needed. 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
