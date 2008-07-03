Message-ID: <486CD654.4020605@garzik.org>
Date: Thu, 03 Jul 2008 09:38:28 -0400
From: Jeff Garzik <jeff@garzik.org>
MIME-Version: 1.0
Subject: Re: [bug?] tg3: Failed to load firmware "tigon/tg3_tso.bin"
References: <20080703020236.adaa51fa.akpm@linux-foundation.org>	 <20080703205548.D6E5.KOSAKI.MOTOHIRO@jp.fujitsu.com>	 <486CC440.9030909@garzik.org>	 <Pine.LNX.4.64.0807031353030.11033@blonde.site>	 <486CCFED.7010308@garzik.org> <1215091999.10393.556.camel@pmac.infradead.org>
In-Reply-To: <1215091999.10393.556.camel@pmac.infradead.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Woodhouse <dwmw2@infradead.org>
Cc: Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, mchan@broadcom.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org
List-ID: <linux-mm.kvack.org>

David Woodhouse wrote:
>> dwmw2 has been told repeatedly that his changes will cause PRECISELY 
>> these problems, but he refuses to take the simple steps necessary to 
>> ensure people can continue to boot their kernels after his changes go in.
> 
> Complete nonsense. Setting CONFIG_FIRMWARE_IN_KERNEL isn't hard. But
> shouldn't be the _default_, either.
> 
>> Presently his tg3 changes have been nak'd, in part, because of this 
>> obviously, forseeable, work-around-able breakage.
> 
> They haven't even been reviewed. Nobody seems to have actually looked at


Yes, they have.  You just didn't like the answers you received.

In particular, the Kconfig default for built-in tg3 firmware should 
result in the current behavior, without the user having to take extra steps.

Because of your stubborn refusal on this Kconfig defaults issue, WE 
ALREADY HAVE DRIVER-DOES-NOT-WORK BREAKAGE, JUST AS PREDICTED.

Wake up and smell reality.  Please.

	Jeff


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
