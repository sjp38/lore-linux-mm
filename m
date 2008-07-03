Subject: Re: [bug?] tg3: Failed to load firmware "tigon/tg3_tso.bin"
From: David Woodhouse <dwmw2@infradead.org>
In-Reply-To: <486CD654.4020605@garzik.org>
References: <20080703020236.adaa51fa.akpm@linux-foundation.org>
	 <20080703205548.D6E5.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <486CC440.9030909@garzik.org>
	 <Pine.LNX.4.64.0807031353030.11033@blonde.site>
	 <486CCFED.7010308@garzik.org>
	 <1215091999.10393.556.camel@pmac.infradead.org>
	 <486CD654.4020605@garzik.org>
Content-Type: text/plain
Date: Thu, 03 Jul 2008 14:52:55 +0100
Message-Id: <1215093175.10393.567.camel@pmac.infradead.org>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jeff Garzik <jeff@garzik.org>
Cc: Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, mchan@broadcom.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 2008-07-03 at 09:38 -0400, Jeff Garzik wrote:
> David Woodhouse wrote:
> >> dwmw2 has been told repeatedly that his changes will cause PRECISELY 
> >> these problems, but he refuses to take the simple steps necessary to 
> >> ensure people can continue to boot their kernels after his changes go in.
> > 
> > Complete nonsense. Setting CONFIG_FIRMWARE_IN_KERNEL isn't hard. But
> > shouldn't be the _default_, either.
> > 
> >> Presently his tg3 changes have been nak'd, in part, because of this 
> >> obviously, forseeable, work-around-able breakage.
> > 
> > They haven't even been reviewed. Nobody seems to have actually looked at
> 
> 
> Yes, they have.  You just didn't like the answers you received.

I received no comment on any part of the changes within tg3.c; only
whining about the default behaviour -- which isn't even _set_ as part of
the patch in question, any more.

> In particular, the Kconfig default for built-in tg3 firmware should 
> result in the current behavior, without the user having to take extra steps.

After feedback from a number of people, there is no individual Kconfig
option for the various firmwares; there is only one which controls them
all -- CONFIG_FIRMWARE_IN_KERNEL. The thing you're whining about isn't
even part of the patch which needs review.

> Because of your stubborn refusal on this Kconfig defaults issue, WE 
> ALREADY HAVE DRIVER-DOES-NOT-WORK BREAKAGE, JUST AS PREDICTED.

I strongly disagree that CONFIG_FIRMWARE_IN_KERNEL=y should be the
default. But if I add this patch elsewhere in the kernel, will you quit
your whining and actually review the patch you were asked to review? ...

diff --git a/drivers/base/Kconfig b/drivers/base/Kconfig
index 339c148..d47482f 100644
--- a/drivers/base/Kconfig
+++ b/drivers/base/Kconfig
@@ -37,6 +37,7 @@ config FW_LOADER
 config FIRMWARE_IN_KERNEL
 	bool "Include in-kernel firmware blobs in kernel binary"
 	depends on FW_LOADER
+	default y
 	help
 	  The kernel source tree includes a number of firmware 'blobs'
 	  which are used by various drivers. The recommended way to

-- 
dwmw2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
