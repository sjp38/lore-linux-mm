Date: Thu, 3 Jul 2008 23:25:54 +0100
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [bug?] tg3: Failed to load firmware "tigon/tg3_tso.bin"
Message-ID: <20080703232554.7271d645@lxorguk.ukuu.org.uk>
In-Reply-To: <486D511A.9020405@garzik.org>
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
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jeff Garzik <jeff@garzik.org>
Cc: David Woodhouse <dwmw2@infradead.org>, Theodore Tso <tytso@mit.edu>, Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, mchan@broadcom.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org
List-ID: <linux-mm.kvack.org>

O
> Further, all current kernel build and test etc. scripts are unaware of 
> 'make firmware_install', and it is unfair to everybody to force a 
> flag-day build process change on people, just to keep their drivers in 
> the same working state today as it was yesterday.

IMHO we want firmware built in as the default for the moment. If the
firmware model makes sense (as I think it does) then the distributions
will catch up, turn it on and sort out the default behaviour - exactly as
they did all those years ago with modules, more recently with "use an
initrd" and so on.

> as "making no sense".  All these are real world examples where users 
> FOLLOWING THEIR NORMAL, PROSCRIBED KERNEL PROCESSES will produce 

I hope you mean "prescribed" ;)

> The only valid assumption here is to assume that the user is /unaware/ 
> of these new steps they must take in order to continue to have a working 
> system.

To a large extent not the user but their distro - consider "make install"

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
