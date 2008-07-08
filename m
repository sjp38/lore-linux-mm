Date: Tue, 8 Jul 2008 07:36:37 +0100
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [bug?] tg3: Failed to load firmware "tigon/tg3_tso.bin"
Message-ID: <20080708073637.32037c76@the-village.bc.nu>
In-Reply-To: <20080707.145819.209342070.davem@davemloft.net>
References: <20080707214218.055bcb35@the-village.bc.nu>
	<20080707.144505.67398603.davem@davemloft.net>
	<20080707221427.163c4a30@the-village.bc.nu>
	<20080707.145819.209342070.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Miller <davem@davemloft.net>
Cc: jeff@garzik.org, dwmw2@infradead.org, andi@firstfloor.org, tytso@mit.edu, hugh@veritas.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, mchan@broadcom.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> That's pure bullox as far as I can see.  Why provide the means to
> do something nobody has had a need for in 6+ years?  Who needs
> to load different firmware for the tg3 driver?

Who needs modules, nobody needed it for years ... you are repeating
historically failed arguments still.

> Who needs that capability? Distribution vendors?  What for?
> In what case will they need to load different firmware from
> what the driver maintainer tested as a unit?

For some drivers yes. Maybe not tg3.

> And, btw, who has the right to enforce this new burdon upon driver
> maintainers when they have had a working and maintainable system for
> so long?

The module argument again - see my comment about the sound driver history.

> I can only see it being about separation, pure and simple.

Separation - of firmware that can be paged from code that cannot. Of
stuff that doesn't change from stuff that does. That happens to be good
engineering.

Alan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
