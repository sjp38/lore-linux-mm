Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f45.google.com (mail-qg0-f45.google.com [209.85.192.45])
	by kanga.kvack.org (Postfix) with ESMTP id E74BC28001E
	for <linux-mm@kvack.org>; Fri, 31 Oct 2014 06:43:21 -0400 (EDT)
Received: by mail-qg0-f45.google.com with SMTP id z107so5365808qgd.32
        for <linux-mm@kvack.org>; Fri, 31 Oct 2014 03:43:21 -0700 (PDT)
Received: from foss-mx-na.foss.arm.com (foss-mx-na.foss.arm.com. [217.140.108.86])
        by mx.google.com with ESMTP id j4si4401947qai.6.2014.10.31.03.43.20
        for <linux-mm@kvack.org>;
        Fri, 31 Oct 2014 03:43:21 -0700 (PDT)
Date: Fri, 31 Oct 2014 10:43:06 +0000
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [RFC V6 3/3] arm64:add bitrev.h file to support rbit instruction
Message-ID: <20141031104305.GC6731@arm.com>
References: <35FD53F367049845BC99AC72306C23D103E010D18260@CNBJMBX05.corpusers.net>
 <35FD53F367049845BC99AC72306C23D103E010D18261@CNBJMBX05.corpusers.net>
 <35FD53F367049845BC99AC72306C23D103E010D18264@CNBJMBX05.corpusers.net>
 <35FD53F367049845BC99AC72306C23D103E010D18265@CNBJMBX05.corpusers.net>
 <35FD53F367049845BC99AC72306C23D103E010D18266@CNBJMBX05.corpusers.net>
 <20141030120127.GC32589@arm.com>
 <CAKv+Gu9g5Q6fjPUy+P8YxkeDrH+bdO4kKGnxTQZRFhQpgPxaPA@mail.gmail.com>
 <20141030135749.GE32589@arm.com>
 <35FD53F367049845BC99AC72306C23D103E010D18272@CNBJMBX05.corpusers.net>
 <35FD53F367049845BC99AC72306C23D103E010D18274@CNBJMBX05.corpusers.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <35FD53F367049845BC99AC72306C23D103E010D18274@CNBJMBX05.corpusers.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Wang, Yalin" <Yalin.Wang@sonymobile.com>
Cc: 'Ard Biesheuvel' <ard.biesheuvel@linaro.org>, 'Russell King - ARM Linux' <linux@arm.linux.org.uk>, "'linux-kernel@vger.kernel.org'" <linux-kernel@vger.kernel.org>, "'akinobu.mita@gmail.com'" <akinobu.mita@gmail.com>, "'linux-mm@kvack.org'" <linux-mm@kvack.org>, 'Joe Perches' <joe@perches.com>, "'linux-arm-kernel@lists.infradead.org'" <linux-arm-kernel@lists.infradead.org>

On Fri, Oct 31, 2014 at 05:41:48AM +0000, Wang, Yalin wrote:
> This patch add bitrev.h file to support rbit instruction,
> so that we can do bitrev operation by hardware.
> Signed-off-by: Yalin Wang <yalin.wang@sonymobile.com>
> ---
>  arch/arm64/Kconfig              |  1 +
>  arch/arm64/include/asm/bitrev.h | 21 +++++++++++++++++++++
>  2 files changed, 22 insertions(+)
>  create mode 100644 arch/arm64/include/asm/bitrev.h
> 
> diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
> index 9532f8d..b1ec1dd 100644
> --- a/arch/arm64/Kconfig
> +++ b/arch/arm64/Kconfig
> @@ -35,6 +35,7 @@ config ARM64
>  	select HANDLE_DOMAIN_IRQ
>  	select HARDIRQS_SW_RESEND
>  	select HAVE_ARCH_AUDITSYSCALL
> +	select HAVE_ARCH_BITREVERSE
>  	select HAVE_ARCH_JUMP_LABEL
>  	select HAVE_ARCH_KGDB
>  	select HAVE_ARCH_TRACEHOOK
> diff --git a/arch/arm64/include/asm/bitrev.h b/arch/arm64/include/asm/bitrev.h
> new file mode 100644
> index 0000000..706a209
> --- /dev/null
> +++ b/arch/arm64/include/asm/bitrev.h
> @@ -0,0 +1,21 @@
> +#ifndef __ASM_ARM64_BITREV_H
> +#define __ASM_ARM64_BITREV_H

Really minor nit, but we don't tend to include 'ARM64' in our header guards,
so this should just be __ASM_BITREV_H.

With that change,

  Acked-by: Will Deacon <will.deacon@arm.com>

Will

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
