Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f53.google.com (mail-wg0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id 8EFB96B00D4
	for <linux-mm@kvack.org>; Thu, 13 Nov 2014 18:53:36 -0500 (EST)
Received: by mail-wg0-f53.google.com with SMTP id b13so18039039wgh.12
        for <linux-mm@kvack.org>; Thu, 13 Nov 2014 15:53:36 -0800 (PST)
Received: from pandora.arm.linux.org.uk (pandora.arm.linux.org.uk. [2001:4d48:ad52:3201:214:fdff:fe10:1be6])
        by mx.google.com with ESMTPS id dz13si46737846wjb.100.2014.11.13.15.53.35
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 13 Nov 2014 15:53:35 -0800 (PST)
Date: Thu, 13 Nov 2014 23:53:22 +0000
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [RFC V6 2/3] arm:add bitrev.h file to support rbit instruction
Message-ID: <20141113235322.GC4042@n2100.arm.linux.org.uk>
References: <35FD53F367049845BC99AC72306C23D103E010D18261@CNBJMBX05.corpusers.net>
 <35FD53F367049845BC99AC72306C23D103E010D18264@CNBJMBX05.corpusers.net>
 <35FD53F367049845BC99AC72306C23D103E010D18265@CNBJMBX05.corpusers.net>
 <35FD53F367049845BC99AC72306C23D103E010D18266@CNBJMBX05.corpusers.net>
 <20141030120127.GC32589@arm.com>
 <CAKv+Gu9g5Q6fjPUy+P8YxkeDrH+bdO4kKGnxTQZRFhQpgPxaPA@mail.gmail.com>
 <20141030135749.GE32589@arm.com>
 <35FD53F367049845BC99AC72306C23D103E010D18272@CNBJMBX05.corpusers.net>
 <35FD53F367049845BC99AC72306C23D103E010D18273@CNBJMBX05.corpusers.net>
 <35FD53F367049845BC99AC72306C23D103E010D18275@CNBJMBX05.corpusers.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <35FD53F367049845BC99AC72306C23D103E010D18275@CNBJMBX05.corpusers.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Wang, Yalin" <Yalin.Wang@sonymobile.com>
Cc: 'Will Deacon' <will.deacon@arm.com>, 'Ard Biesheuvel' <ard.biesheuvel@linaro.org>, "'linux-kernel@vger.kernel.org'" <linux-kernel@vger.kernel.org>, "'akinobu.mita@gmail.com'" <akinobu.mita@gmail.com>, "'linux-mm@kvack.org'" <linux-mm@kvack.org>, 'Joe Perches' <joe@perches.com>, "'linux-arm-kernel@lists.infradead.org'" <linux-arm-kernel@lists.infradead.org>

On Fri, Oct 31, 2014 at 01:42:44PM +0800, Wang, Yalin wrote:
> This patch add bitrev.h file to support rbit instruction,
> so that we can do bitrev operation by hardware.
> Signed-off-by: Yalin Wang <yalin.wang@sonymobile.com>
> ---
>  arch/arm/Kconfig              |  1 +
>  arch/arm/include/asm/bitrev.h | 21 +++++++++++++++++++++
>  2 files changed, 22 insertions(+)
>  create mode 100644 arch/arm/include/asm/bitrev.h
> 
> diff --git a/arch/arm/Kconfig b/arch/arm/Kconfig
> index 89c4b5c..be92b3b 100644
> --- a/arch/arm/Kconfig
> +++ b/arch/arm/Kconfig
> @@ -28,6 +28,7 @@ config ARM
>  	select HANDLE_DOMAIN_IRQ
>  	select HARDIRQS_SW_RESEND
>  	select HAVE_ARCH_AUDITSYSCALL if (AEABI && !OABI_COMPAT)
> +	select HAVE_ARCH_BITREVERSE if (CPU_V7M || CPU_V7)

Looking at this, this is just wrong.  Take a moment to consider what
happens if we build a kernel which supports both ARMv6 _and_ ARMv7 CPUs.
What happens if an ARMv6 CPU tries to execute an rbit instruction?

Second point (which isn't obvious from your submissions on-list) is that
you've loaded the patch system up with patches for other parts of the
kernel tree for which I am not responsible for.  As such, I can't take
those patches without the sub-tree maintainer acking them.  Also, the
commit text in those patches look weird:

6fire: Convert byte_rev_table uses to bitrev8

Use the inline function instead of directly indexing the array.

This allows some architectures with hardware instructions for bit
reversals to eliminate the array.

Signed-off-by: Joe Perches <(address hidden)>
Signed-off-by: Yalin Wang <(address hidden)>

Why is Joe signing off on these patches?  As his is the first sign-off,
one assumes that he was responsible for creating the patch in the first
place, but there is no From: line marking him as the author.  Shouldn't
his entry be an Acked-by: ?

Confused.

-- 
FTTC broadband for 0.8mile line: currently at 9.5Mbps down 400kbps up
according to speedtest.net.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
