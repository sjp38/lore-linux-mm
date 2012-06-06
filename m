Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id 82CA18D0001
	for <linux-mm@kvack.org>; Wed,  6 Jun 2012 09:14:52 -0400 (EDT)
Date: Wed, 6 Jun 2012 15:14:42 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] powerpc: Fix assmption of end_of_DRAM() returns end
 address
Message-ID: <20120606131442.GN21339@redhat.com>
References: <1338904504-2750-1-git-send-email-bharat.bhushan@freescale.com>
 <1338934659.7150.113.camel@pasglop>
 <20120605.152058.828742127223799137.davem@davemloft.net>
 <6A3DF150A5B70D4F9B66A25E3F7C888D03D68F08@039-SN2MPN1-022.039d.mgd.msft.net>
 <1338960617.7150.163.camel@pasglop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1338960617.7150.163.camel@pasglop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Bhushan Bharat-R65777 <R65777@freescale.com>, David Miller <davem@davemloft.net>, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "galak@kernel.crashing.org" <galak@kernel.crashing.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

Hi,

On Wed, Jun 06, 2012 at 03:30:17PM +1000, Benjamin Herrenschmidt wrote:
> On Wed, 2012-06-06 at 00:46 +0000, Bhushan Bharat-R65777 wrote:
> 
> > > >> memblock_end_of_DRAM() returns end_address + 1, not end address.
> > > >> While some code assumes that it returns end address.
> > > >
> > > > Shouldn't we instead fix it the other way around ? IE, make
> > > > memblock_end_of_DRAM() does what the name implies, which is to
> > return
> > > > the last byte of DRAM, and fix the -other- callers not to make bad
> > > > assumptions ?
> > > 
> > > That was my impression too when I saw this patch.
> > 
> > Initially I also intended to do so. I initiated a email on linux-mm@
> > subject "memblock_end_of_DRAM()  return end address + 1" and the only
> > response I received from Andrea was:
> > 
> > "
> > It's normal that "end" means "first byte offset out of the range". End
> > = not ok.
> > end = start+size.
> > This is true for vm_end too. So it's better to keep it that way.
> > My suggestion is to just fix point 1 below and audit the rest :)
> > "
> 
> Oh well, I don't care enough to fight this battle in my current state so

I wish you to get well soon Ben!

> unless Dave has more stamina than I have today, I'm ok with the patch.

Well it doesn't really matter in the end what is decided as long as
something is decided :). I was asked through a forward so I only
expressed my preference...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
