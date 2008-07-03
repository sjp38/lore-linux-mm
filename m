Message-ID: <486CCFED.7010308@garzik.org>
Date: Thu, 03 Jul 2008 09:11:09 -0400
From: Jeff Garzik <jeff@garzik.org>
MIME-Version: 1.0
Subject: Re: [bug?] tg3: Failed to load firmware "tigon/tg3_tso.bin"
References: <20080703020236.adaa51fa.akpm@linux-foundation.org> <20080703205548.D6E5.KOSAKI.MOTOHIRO@jp.fujitsu.com> <486CC440.9030909@garzik.org> <Pine.LNX.4.64.0807031353030.11033@blonde.site>
In-Reply-To: <Pine.LNX.4.64.0807031353030.11033@blonde.site>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, mchan@broadcom.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, David Woodhouse <dwmw2@infradead.org>
List-ID: <linux-mm.kvack.org>

Hugh Dickins wrote:
> On Thu, 3 Jul 2008, Jeff Garzik wrote:
>> KOSAKI Motohiro wrote:
>>> Hi Michael,
>>>
>>> my server output following error message on 2.6.26-rc8-mm1.
>>> Is this a bug?
>>>
>>> ------------------------------------------------------------------
>>> tg3.c:v3.93 (May 22, 2008)
>>> GSI 72 (level, low) -> CPU 0 (0x0001) vector 51
>>> tg3 0000:06:01.0: PCI INT A -> GSI 72 (level, low) -> IRQ 51
>>> firmware: requesting tigon/tg3_tso.bin
>>> tg3: Failed to load firmware "tigon/tg3_tso.bin"
>>> tg3 0000:06:01.0: PCI INT A disabled
>>> GSI 72 (level, low) -> CPU 0 (0x0001) vector 51 unregistered
>>> tg3: probe of 0000:06:01.0 failed with error -2
>>> GSI 73 (level, low) -> CPU 0 (0x0001) vector 51
>>> tg3 0000:06:01.1: PCI INT B -> GSI 73 (level, low) -> IRQ 52
>>> firmware: requesting tigon/tg3_tso.bin
>> This change did not come from the network developers or Broadcom, so someone
>> else broke tg3 in -mm...
> 
> I think it's a consequence of not choosing CONFIG_FIRMWARE_IN_KERNEL=y.
> 
> That caught me out on PowerMac G5 trying mmotm yesterday, it just hung
> for a few minutes in earlyish boot with a message about tg3_tso.bin,
> and then proceeded to boot up but without the network.  I was unclear
> whether I'd been stupid, or the FIRMWARE_IN_KERNEL Kconfigery was poor.
> 
> I avoid initrd, and have tigon3 built in, if that's of any relevance.
> 
> I wonder if that's Andrew's problem with 2.6.26-rc8-mm1 on his G5:
> mine here boots up fine (now I know to CONFIG_FIRMWARE_IN_KERNEL=y).


dwmw2 has been told repeatedly that his changes will cause PRECISELY 
these problems, but he refuses to take the simple steps necessary to 
ensure people can continue to boot their kernels after his changes go in.

Presently his tg3 changes have been nak'd, in part, because of this 
obviously, forseeable, work-around-able breakage.

	Jeff


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
