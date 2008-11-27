Date: Thu, 27 Nov 2008 12:02:30 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [RESEND:PATCH] [ARM] clearpage: provide our own clear_user_highpage()
In-Reply-To: <20081127112124.GA9233@flint.arm.linux.org.uk>
Message-ID: <Pine.LNX.4.64.0811271158120.28319@blonde.site>
References: <20081126171321.GA4719@dyn-67.arm.linux.org.uk>
 <1227719999.3387.0.camel@localhost.localdomain> <20081127102920.660303a5.sfr@canb.auug.org.au>
 <20081127010755.GA30854@linux-sh.org> <20081127112124.GA9233@flint.arm.linux.org.uk>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Russell King <rmk@arm.linux.org.uk>
Cc: Paul Mundt <lethal@linux-sh.org>, Stephen Rothwell <sfr@canb.auug.org.au>, James Bottomley <James.Bottomley@HansenPartnership.com>, linux-arch@vger.kernel.org, Linux Kernel List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 27 Nov 2008, Russell King wrote:
> On Thu, Nov 27, 2008 at 10:07:55AM +0900, Paul Mundt wrote:
> > On Thu, Nov 27, 2008 at 10:29:20AM +1100, Stephen Rothwell wrote:
> > > On Wed, 26 Nov 2008 11:19:59 -0600 James Bottomley <James.Bottomley@HansenPartnership.com> wrote:
> > > >
> > > > We'd like to pull this trick on parisc as well (another VIPT
> > > > architecture), so you can add my ack.
> > > 
> > > If this is going to be used by more than one architecture during the next
> > > merge window, then maybe the change to include/linux/highmem.h could be
> > > extracted to its own patch and sent to Linus for inclusion in 2.6.28.
> > > This way we avoid some conflicts and the architectures can do their
> > > updates independently.
> > 
> > I plan to use it on VIPT SH also, so getting the higmem.h change in by
> > itself sooner rather than later would certainly be welcome.
> 
> I'll queue the change to linux/highmem.h for when Linus gets back then.
> Can I assume that Hugh and James are happy for their ack to apply to
> both parts of the split patch?  And do I have your ack as well?

I rather trusted you on the ARM end of it: I won't be kicking up a
fuss if my Acked-by ends up appearing on that part too, but really,
it was for the linux/highmem.h end of it.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
