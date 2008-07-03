Date: Fri, 4 Jul 2008 00:02:06 +0100
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [bug?] tg3: Failed to load firmware "tigon/tg3_tso.bin"
Message-ID: <20080704000206.259475a0@lxorguk.ukuu.org.uk>
In-Reply-To: <486D5D4F.9060000@garzik.org>
References: <20080703020236.adaa51fa.akpm@linux-foundation.org>
	<20080703205548.D6E5.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	<486CC440.9030909@garzik.org>
	<Pine.LNX.4.64.0807031353030.11033@blonde.site>
	<486CCFED.7010308@garzik.org>
	<1215091999.10393.556.camel@pmac.infradead.org>
	<486CD654.4020605@garzik.org>
	<1215093175.10393.567.camel@pmac.infradead.org>
	<20080703173040.GB30506@mit.edu>
	<1215111362.10393.651.camel@pmac.infradead.org>
	<486D3E88.9090900@garzik.org>
	<486D4596.60005@infradead.org>
	<486D511A.9020405@garzik.org>
	<20080703232554.7271d645@lxorguk.ukuu.org.uk>
	<486D5D4F.9060000@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jeff Garzik <jeff@garzik.org>
Cc: David Woodhouse <dwmw2@infradead.org>, Theodore Tso <tytso@mit.edu>, Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, mchan@broadcom.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> Actually, I was tossing that about in my head:
> 
> Is it a better idea to eliminate 'make firmware_install' completely, and 
> instead implement it silently via 'make install'?
> 
> 'make install' is already a big fat distro hook...

make firmware_install can encapsulate a lot of kernel specific knowledge
so I think it belongs in the kernel tree to avoid problems in future. The
use of make firmware_install belongs in the distro make install hooks.

Otherwise we will mess up the distro stuff if we have to change the
innards of make firmware_install in future, as may well occur.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
