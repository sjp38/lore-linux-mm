Date: Mon, 07 Jul 2008 14:58:19 -0700 (PDT)
Message-Id: <20080707.145819.209342070.davem@davemloft.net>
Subject: Re: [bug?] tg3: Failed to load firmware "tigon/tg3_tso.bin"
From: David Miller <davem@davemloft.net>
In-Reply-To: <20080707221427.163c4a30@the-village.bc.nu>
References: <20080707214218.055bcb35@the-village.bc.nu>
	<20080707.144505.67398603.davem@davemloft.net>
	<20080707221427.163c4a30@the-village.bc.nu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Date: Mon, 7 Jul 2008 22:14:27 +0100
Return-Path: <owner-linux-mm@kvack.org>
To: alan@lxorguk.ukuu.org.uk
Cc: jeff@garzik.org, dwmw2@infradead.org, andi@firstfloor.org, tytso@mit.edu, hugh@veritas.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, mchan@broadcom.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> > > You seem to be trying to conflate legal and technical issues here.
> > 
> > Exactly like the patches we are current discussing.
> > 
> > Thanks for walking right into that. :-)
> 
> No - the patches are for technical reasons, 

Which are?  Consistent use of request_firmware()?

That's pure bullox as far as I can see.  Why provide the means to
do something nobody has had a need for in 6+ years?  Who needs
to load different firmware for the tg3 driver?

Who needs that capability? Distribution vendors?  What for?
In what case will they need to load different firmware from
what the driver maintainer tested as a unit?

Rather, they want separation.  I can see no other real impetus.

And, btw, who has the right to enforce this new burdon upon driver
maintainers when they have had a working and maintainable system for
so long?

I can only see it being about separation, pure and simple.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
