Date: Fri, 04 Jul 2008 13:43:29 -0700 (PDT)
Message-Id: <20080704.134329.209642254.davem@davemloft.net>
Subject: Re: [bug?] tg3: Failed to load firmware "tigon/tg3_tso.bin"
From: David Miller <davem@davemloft.net>
In-Reply-To: <20080704142753.27848ff8@lxorguk.ukuu.org.uk>
References: <1215178035.10393.763.camel@pmac.infradead.org>
	<486E2818.1060003@garzik.org>
	<20080704142753.27848ff8@lxorguk.ukuu.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Date: Fri, 4 Jul 2008 14:27:53 +0100
Return-Path: <owner-linux-mm@kvack.org>
To: alan@lxorguk.ukuu.org.uk
Cc: jeff@garzik.org, dwmw2@infradead.org, andi@firstfloor.org, tytso@mit.edu, hugh@veritas.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, mchan@broadcom.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> There are good sound reasons for having a firmware tree, the fact tg3 is
> a bit of dinosaur in this area doesn't make it wrong.

And bnx2, and bnx2x, and e100's ucode (hope David caught that one!).

It isn't just tg3.

External firmware is by design an error prone system, even with
versioning.  But by being built and linked into the driver, it
is fool proof.

On a technical basis alone, we would never disconnect a crucial
component such as firmware, from the driver.  The only thing
charging these transoformations, from day one, is legal concerns.

I've been against request_firmware() from the beginning, because
they make life unnecessarily difficult, and it is error prone no
matter how well you design the validation step.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
