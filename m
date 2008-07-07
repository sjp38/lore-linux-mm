Date: Mon, 7 Jul 2008 19:45:58 +0100
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [bug?] tg3: Failed to load firmware "tigon/tg3_tso.bin"
Message-ID: <20080707194558.4be87882@the-village.bc.nu>
In-Reply-To: <48726B7F.5010402@garzik.org>
References: <1215093175.10393.567.camel@pmac.infradead.org>
	<20080703173040.GB30506@mit.edu>
	<1215111362.10393.651.camel@pmac.infradead.org>
	<20080703.162120.206258339.davem@davemloft.net>
	<486D6DDB.4010205@infradead.org>
	<87ej6armez.fsf@basil.nowhere.org>
	<1215177044.10393.743.camel@pmac.infradead.org>
	<486E2260.5050503@garzik.org>
	<1215178035.10393.763.camel@pmac.infradead.org>
	<486E2818.1060003@garzik.org>
	<1215179161.10393.773.camel@pmac.infradead.org>
	<486E2E9B.20200@garzik.org>
	<20080704153822.4db2f325@lxorguk.ukuu.org.uk>
	<48715807.8070605@garzik.org>
	<20080707165333.6347f564@the-village.bc.nu>
	<48725155.2040007@garzik.org>
	<20080707191359.11f6297f@the-village.bc.nu>
	<48726734.7080601@garzik.org>
	<20080707193008.17795d61@the-village.bc.nu>
	<48726B7F.5010402@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jeff Garzik <jeff@garzik.org>
Cc: David Woodhouse <dwmw2@infradead.org>, Andi Kleen <andi@firstfloor.org>, David Miller <davem@davemloft.net>, tytso@mit.edu, hugh@veritas.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, mchan@broadcom.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> > And this is the pot calling the kettle black. You badly
> > broke Marvell PATA support by setting the Marvell SATA devices to AHCI. I
> > note you've still not fixed that after some months.
> 
> Even if we accept that at face value, which I don't (it's more a driver 
> load order issue), that is no excuse for further regressions.

So you are allowed to break stuff without fixing it (and driver load
order issue is not as far as I can tell the case - the AHCI stuff means
you lose the PATA port) but David isnt ?

How about we revert all the marvell changes - or would in truth be
another case where the good done for most (SATA AHCI support) outweighs
the bad for a few (PATA port problems) ?

Sorry Jeff but you don't get to jump up and down on David without being
reminded that your own actions are not consistent with your words.

Alan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
