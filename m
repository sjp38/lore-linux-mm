From: Russell King <rmk@arm.linux.org.uk>
Subject: Re: [RESEND:PATCH] [ARM] clearpage: provide our own clear_user_highpage()
Date: Thu, 27 Nov 2008 11:21:24 +0000
Message-ID: <20081127112124.GA9233__19452.2109617994$1227785076$gmane$org@flint.arm.linux.org.uk>
References: <20081126171321.GA4719@dyn-67.arm.linux.org.uk> <1227719999.3387.0.camel@localhost.localdomain> <20081127102920.660303a5.sfr@canb.auug.org.au> <20081127010755.GA30854@linux-sh.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <owner-linux-mm@kvack.org>
Content-Disposition: inline
In-Reply-To: <20081127010755.GA30854@linux-sh.org>
Sender: owner-linux-mm@kvack.org
To: Paul Mundt <lethal@linux-sh.org>, Stephen Rothwell <sfr@canb.auug.org.au>, James Bottomley <James.Bottomley@HansenPartnership.com>, linux-arch@vger.kernel.orgLinux Kernel List <lin>
List-Id: linux-mm.kvack.org

On Thu, Nov 27, 2008 at 10:07:55AM +0900, Paul Mundt wrote:
> On Thu, Nov 27, 2008 at 10:29:20AM +1100, Stephen Rothwell wrote:
> > Hi Russell,
> > 
> > On Wed, 26 Nov 2008 11:19:59 -0600 James Bottomley <James.Bottomley@HansenPartnership.com> wrote:
> > >
> > > We'd like to pull this trick on parisc as well (another VIPT
> > > architecture), so you can add my ack.
> > 
> > If this is going to be used by more than one architecture during the next
> > merge window, then maybe the change to include/linux/highmem.h could be
> > extracted to its own patch and sent to Linus for inclusion in 2.6.28.
> > This way we avoid some conflicts and the architectures can do their
> > updates independently.
> 
> I plan to use it on VIPT SH also, so getting the higmem.h change in by
> itself sooner rather than later would certainly be welcome.

I'll queue the change to linux/highmem.h for when Linus gets back then.
Can I assume that Hugh and James are happy for their ack to apply to
both parts of the split patch?  And do I have your ack as well?

Thanks.

-- 
Russell King
 Linux kernel    2.6 ARM Linux   - http://www.arm.linux.org.uk/
 maintainer of:

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
