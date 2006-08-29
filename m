Date: Tue, 29 Aug 2006 12:55:29 +0900
From: Paul Mundt <lethal@linux-sh.org>
Subject: Re: [RFC][PATCH 1/7] generic PAGE_SIZE infrastructure (v2)
Message-ID: <20060829035529.GB8910@localhost.hsdv.com>
References: <20060828154413.E05721BD@localhost.localdomain> <20060828154417.D9D3FB1F@localhost.localdomain> <20060828154413.E05721BD@localhost.localdomain> <20060828154416.09E64946@localhost.localdomain> <20060828154413.E05721BD@localhost.localdomain> <20060828154414.38AEDAA2@localhost.localdomain> <20060828154413.E05721BD@localhost.localdomain> <20060829024618.GA8660@localhost.hsdv.com> <20060828205129.cfdfad49.rdunlap@xenotime.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20060828205129.cfdfad49.rdunlap@xenotime.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Randy.Dunlap" <rdunlap@xenotime.net>
Cc: Dave Hansen <haveblue@us.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Aug 28, 2006 at 08:51:29PM -0700, Randy.Dunlap wrote:
> On Tue, 29 Aug 2006 11:46:18 +0900 Paul Mundt wrote:
> > You may wish to consider the HAVE_ARCH_GET_ORDER patch I sent to
> > linux-arch, it was intended to handle this.
> 
> Is Linus taking that kind of config stuff now?
> He said it "must DIE," so why take any more of it?
> 
The alternative is shoving the PAGE_SIZE definitions in a new header,
which is even uglier.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
