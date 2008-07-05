Message-ID: <486F0F44.4000902@garzik.org>
Date: Sat, 05 Jul 2008 02:05:56 -0400
From: Jeff Garzik <jeff@garzik.org>
MIME-Version: 1.0
Subject: Re: [bug?] tg3: Failed to load firmware "tigon/tg3_tso.bin"
References: <1215178035.10393.763.camel@pmac.infradead.org>	<486E2818.1060003@garzik.org>	<20080704142753.27848ff8@lxorguk.ukuu.org.uk> <20080704.134329.209642254.davem@davemloft.net>
In-Reply-To: <20080704.134329.209642254.davem@davemloft.net>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Miller <davem@davemloft.net>
Cc: alan@lxorguk.ukuu.org.uk, dwmw2@infradead.org, andi@firstfloor.org, tytso@mit.edu, hugh@veritas.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, mchan@broadcom.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org
List-ID: <linux-mm.kvack.org>

David Miller wrote:
> External firmware is by design an error prone system, even with
> versioning.  But by being built and linked into the driver, it
> is fool proof.
> 
> On a technical basis alone, we would never disconnect a crucial
> component such as firmware, from the driver.  The only thing
> charging these transoformations, from day one, is legal concerns.
> 
> I've been against request_firmware() from the beginning, because
> they make life unnecessarily difficult, and it is error prone no
> matter how well you design the validation step.

Precisely.  External firmware is quite simply less error prone, since it 
is always with the driver code that uses it.  No other system can 
approach that reliability.

But I did (and do) think request_firmware() is a necessary piece of the 
puzzle.  Personally I've always felt it is a design choice by the 
individual driver author, whether to compile-in firmware or use external 
firmware.

	Jeff


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
