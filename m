Date: Fri, 4 Jul 2008 22:04:44 +0100
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [bug?] tg3: Failed to load firmware "tigon/tg3_tso.bin"
Message-ID: <20080704220444.011e7e61@lxorguk.ukuu.org.uk>
In-Reply-To: <20080704.134329.209642254.davem@davemloft.net>
References: <1215178035.10393.763.camel@pmac.infradead.org>
	<486E2818.1060003@garzik.org>
	<20080704142753.27848ff8@lxorguk.ukuu.org.uk>
	<20080704.134329.209642254.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Miller <davem@davemloft.net>
Cc: jeff@garzik.org, dwmw2@infradead.org, andi@firstfloor.org, tytso@mit.edu, hugh@veritas.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, mchan@broadcom.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> External firmware is by design an error prone system, even with
> versioning.  But by being built and linked into the driver, it
> is fool proof.
> 
> On a technical basis alone, we would never disconnect a crucial
> component such as firmware, from the driver.  The only thing
> charging these transoformations, from day one, is legal concerns.

As I said: We had this argument ten years ago (more than that now
actually). People said the same thing about modules.

Alan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
