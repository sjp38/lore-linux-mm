Date: Thu, 13 Dec 2007 14:29:35 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: QUEUE_FLAG_CLUSTER: not working in 2.6.24 ?
Message-Id: <20071213142935.47ff19d9.akpm@linux-foundation.org>
In-Reply-To: <1197584106.3154.55.camel@localhost.localdomain>
References: <20071213185326.GQ26334@parisc-linux.org>
	<4761821F.3050602@rtr.ca>
	<20071213192633.GD10104@kernel.dk>
	<4761883A.7050908@rtr.ca>
	<476188C4.9030802@rtr.ca>
	<20071213193937.GG10104@kernel.dk>
	<47618B0B.8020203@rtr.ca>
	<20071213195350.GH10104@kernel.dk>
	<20071213200219.GI10104@kernel.dk>
	<476190BE.9010405@rtr.ca>
	<20071213200958.GK10104@kernel.dk>
	<20071213140207.111f94e2.akpm@linux-foundation.org>
	<1197584106.3154.55.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: James Bottomley <James.Bottomley@HansenPartnership.com>
Cc: jens.axboe@oracle.com, liml@rtr.ca, lkml@rtr.ca, matthew@wil.cx, linux-ide@vger.kernel.org, linux-kernel@vger.kernel.org, linux-scsi@vger.kernel.org, linux-mm@kvack.org, mel@csn.ul.ie
List-ID: <linux-mm.kvack.org>

On Thu, 13 Dec 2007 17:15:06 -0500
James Bottomley <James.Bottomley@HansenPartnership.com> wrote:

> 
> On Thu, 2007-12-13 at 14:02 -0800, Andrew Morton wrote:
> > On Thu, 13 Dec 2007 21:09:59 +0100
> > Jens Axboe <jens.axboe@oracle.com> wrote:
> > 
> > >
> > > OK, it's a vm issue,
> > 
> > cc linux-mm and probable culprit.
> > 
> > >  I have tens of thousand "backward" pages after a
> > > boot - IOW, bvec->bv_page is the page before bvprv->bv_page, not
> > > reverse. So it looks like that bug got reintroduced.
> > 
> > Bill Irwin fixed this a couple of years back: changed the page allocator so
> > that it mostly hands out pages in ascending physical-address order.
> > 
> > I guess we broke that, quite possibly in Mel's page allocator rework.
> > 
> > It would help if you could provide us with a simple recipe for
> > demonstrating this problem, please.
> 
> The simple way seems to be to malloc a large area, touch every page and
> then look at the physical pages assigned ... they now mostly seem to be
> descending in physical address.
> 

OIC.  -mm's /proc/pid/pagemap can be used to get the pfn's...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
