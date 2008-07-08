Date: Tue, 08 Jul 2008 01:57:01 -0700 (PDT)
Message-Id: <20080708.015701.249196626.davem@davemloft.net>
Subject: Re: [bug?] tg3: Failed to load firmware "tigon/tg3_tso.bin"
From: David Miller <davem@davemloft.net>
In-Reply-To: <20080708073637.32037c76@the-village.bc.nu>
References: <20080707221427.163c4a30@the-village.bc.nu>
	<20080707.145819.209342070.davem@davemloft.net>
	<20080708073637.32037c76@the-village.bc.nu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Date: Tue, 8 Jul 2008 07:36:37 +0100
Return-Path: <owner-linux-mm@kvack.org>
To: alan@lxorguk.ukuu.org.uk
Cc: jeff@garzik.org, dwmw2@infradead.org, andi@firstfloor.org, tytso@mit.edu, hugh@veritas.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, mchan@broadcom.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> > I can only see it being about separation, pure and simple.
> 
> Separation - of firmware that can be paged from code that cannot.

It can't be paged from the drivers we're talking about,
no matter how hard you try.

Every chip reset needs the firmware around so it can be
reloaded into the card.

This applies to tg3, bnx2, bnx2x, etc. etc. etc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
