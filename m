Message-ID: <48726B7F.5010402@garzik.org>
Date: Mon, 07 Jul 2008 15:16:15 -0400
From: Jeff Garzik <jeff@garzik.org>
MIME-Version: 1.0
Subject: Re: [bug?] tg3: Failed to load firmware "tigon/tg3_tso.bin"
References: <1215093175.10393.567.camel@pmac.infradead.org>	<20080703173040.GB30506@mit.edu>	<1215111362.10393.651.camel@pmac.infradead.org>	<20080703.162120.206258339.davem@davemloft.net>	<486D6DDB.4010205@infradead.org>	<87ej6armez.fsf@basil.nowhere.org>	<1215177044.10393.743.camel@pmac.infradead.org>	<486E2260.5050503@garzik.org>	<1215178035.10393.763.camel@pmac.infradead.org>	<486E2818.1060003@garzik.org>	<1215179161.10393.773.camel@pmac.infradead.org>	<486E2E9B.20200@garzik.org>	<20080704153822.4db2f325@lxorguk.ukuu.org.uk>	<48715807.8070605@garzik.org>	<20080707165333.6347f564@the-village.bc.nu>	<48725155.2040007@garzik.org>	<20080707191359.11f6297f@the-village.bc.nu>	<48726734.7080601@garzik.org> <20080707193008.17795d61@the-village.bc.nu>
In-Reply-To: <20080707193008.17795d61@the-village.bc.nu>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: David Woodhouse <dwmw2@infradead.org>, Andi Kleen <andi@firstfloor.org>, David Miller <davem@davemloft.net>, tytso@mit.edu, hugh@veritas.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, mchan@broadcom.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Alan Cox wrote:
> On Mon, 07 Jul 2008 14:57:56 -0400
> Jeff Garzik <jeff@garzik.org> wrote:
> 
>> Alan Cox wrote:
>>>> When the firmware travels with the module, as it does today in tg3, bnx2 
>>>> and others, is the most reliable system available.  The simplest, the 
>>>> least amount of "parts", the easiest to upgrade, the best method to 
>>>> guarantee driver/firmware version matches.  It works wonderfully today.
>>>>
>>>> Is it difficult to see why someone might want to keep the same attributes?
>>> No I can see that, should be a simple matter of sending David patches.
>> Isn't it David's obligation not to remove a highly reliable, working system?
> 
> I don't see why it should be David's job to add every conceivable feature
> to the code. 

Just whose job is it, exactly, to avoid regressions?

Why is it unfair to ask a patch author not to break stuff?


> And this is the pot calling the kettle black. You badly
> broke Marvell PATA support by setting the Marvell SATA devices to AHCI. I
> note you've still not fixed that after some months.

Even if we accept that at face value, which I don't (it's more a driver 
load order issue), that is no excuse for further regressions.

	Jeff


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
