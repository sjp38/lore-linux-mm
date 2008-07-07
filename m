Message-ID: <48725155.2040007@garzik.org>
Date: Mon, 07 Jul 2008 13:24:37 -0400
From: Jeff Garzik <jeff@garzik.org>
MIME-Version: 1.0
Subject: Re: [bug?] tg3: Failed to load firmware "tigon/tg3_tso.bin"
References: <1215093175.10393.567.camel@pmac.infradead.org>	<20080703173040.GB30506@mit.edu>	<1215111362.10393.651.camel@pmac.infradead.org>	<20080703.162120.206258339.davem@davemloft.net>	<486D6DDB.4010205@infradead.org>	<87ej6armez.fsf@basil.nowhere.org>	<1215177044.10393.743.camel@pmac.infradead.org>	<486E2260.5050503@garzik.org>	<1215178035.10393.763.camel@pmac.infradead.org>	<486E2818.1060003@garzik.org>	<1215179161.10393.773.camel@pmac.infradead.org>	<486E2E9B.20200@garzik.org>	<20080704153822.4db2f325@lxorguk.ukuu.org.uk>	<48715807.8070605@garzik.org> <20080707165333.6347f564@the-village.bc.nu>
In-Reply-To: <20080707165333.6347f564@the-village.bc.nu>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: David Woodhouse <dwmw2@infradead.org>, Andi Kleen <andi@firstfloor.org>, David Miller <davem@davemloft.net>, tytso@mit.edu, hugh@veritas.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, mchan@broadcom.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Alan Cox wrote:
>>> And we had the same argument over ten years ago about those evil module
>>> things which stopped you just using scp to copy the kernel in one go.
>>> Fortunately the nay sayers lost so we have modules.
>> Broken analogy.
>>
>> When modules were added, you were given the option to use them, or not.
> 
> You can still choose to compile firmware in. Did you read the patches ?

You cannot compile the firmware into the modules themselves, which is a 
regression from current behavior.

Its a problem for cases where you cannot as readily update the kernel 
image, such as vendor kernel + driver disk situations, or other examples 
already cited.

When the firmware travels with the module, as it does today in tg3, bnx2 
and others, is the most reliable system available.  The simplest, the 
least amount of "parts", the easiest to upgrade, the best method to 
guarantee driver/firmware version matches.  It works wonderfully today.

Is it difficult to see why someone might want to keep the same attributes?

Compiled-in firmware wastes memory and isn't upgradable -- just like 
static kernel vs. kernel modules debate -- but it IS far more reliable 
than any system where the firmware is separated from the kernel module 
itself.

I'd heartily support David's efforts if it was done in a regression-free 
manner.  But it is just so easy to build and package a _silently_ 
non-working driver, simply because the firmware got missed somewhere.

The best path to this new system is to (a) ensure the old system still 
works, and then (b) make it easy (transparent?) to adopt the new system.

	Jeff


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
