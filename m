Received: from midway.site ([71.117.233.155]) by xenotime.net for <linux-mm@kvack.org>; Mon, 28 Aug 2006 20:59:25 -0700
Date: Mon, 28 Aug 2006 21:02:46 -0700
From: "Randy.Dunlap" <rdunlap@xenotime.net>
Subject: Re: [RFC][PATCH 1/7] generic PAGE_SIZE infrastructure (v2)
Message-Id: <20060828210246.2d3381dc.rdunlap@xenotime.net>
In-Reply-To: <20060829035529.GB8910@localhost.hsdv.com>
References: <20060828154413.E05721BD@localhost.localdomain>
	<20060828154417.D9D3FB1F@localhost.localdomain>
	<20060828154413.E05721BD@localhost.localdomain>
	<20060828154416.09E64946@localhost.localdomain>
	<20060828154413.E05721BD@localhost.localdomain>
	<20060828154414.38AEDAA2@localhost.localdomain>
	<20060828154413.E05721BD@localhost.localdomain>
	<20060829024618.GA8660@localhost.hsdv.com>
	<20060828205129.cfdfad49.rdunlap@xenotime.net>
	<20060829035529.GB8910@localhost.hsdv.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Mundt <lethal@linux-sh.org>
Cc: Dave Hansen <haveblue@us.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 29 Aug 2006 12:55:29 +0900 Paul Mundt wrote:

> On Mon, Aug 28, 2006 at 08:51:29PM -0700, Randy.Dunlap wrote:
> > On Tue, 29 Aug 2006 11:46:18 +0900 Paul Mundt wrote:
> > > You may wish to consider the HAVE_ARCH_GET_ORDER patch I sent to
> > > linux-arch, it was intended to handle this.
> > 
> > Is Linus taking that kind of config stuff now?
> > He said it "must DIE," so why take any more of it?
> > 
> The alternative is shoving the PAGE_SIZE definitions in a new header,
> which is even uglier.

That seems to match what he wanted to see (AFAICT),
but I agree with you.

---
~Randy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
