Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 1AAAB828F3
	for <linux-mm@kvack.org>; Sun, 10 Jan 2016 13:59:29 -0500 (EST)
Received: by mail-wm0-f44.google.com with SMTP id u188so191127039wmu.1
        for <linux-mm@kvack.org>; Sun, 10 Jan 2016 10:59:29 -0800 (PST)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:120:8448::d00d])
        by mx.google.com with ESMTP id r138si16855772wmg.30.2016.01.10.10.59.27
        for <linux-mm@kvack.org>;
        Sun, 10 Jan 2016 10:59:27 -0800 (PST)
Date: Sun, 10 Jan 2016 19:59:16 +0100
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [RFC 01/13] x86/paravirt: Turn KASAN off for parvirt.o
Message-ID: <20160110185916.GD22896@pd.tnic>
References: <cover.1452294700.git.luto@kernel.org>
 <bffe57f96d76a92655cb5d230d86cec195a20f6e.1452294700.git.luto@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <bffe57f96d76a92655cb5d230d86cec195a20f6e.1452294700.git.luto@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, Brian Gerst <brgerst@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>

+ Andrey.

On Fri, Jan 08, 2016 at 03:15:19PM -0800, Andy Lutomirski wrote:
> Otherwise terrible things happen if some of the callbacks end up
> calling into KASAN in unexpected places.
> 
> This has no obvious symptoms yet, but adding a memory reference to
> native_flush_tlb_global without this blows up on KASAN kernels.
> 
> Signed-off-by: Andy Lutomirski <luto@kernel.org>
> ---
>  arch/x86/kernel/Makefile | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/arch/x86/kernel/Makefile b/arch/x86/kernel/Makefile
> index b1b78ffe01d0..b7cd5bdf314b 100644
> --- a/arch/x86/kernel/Makefile
> +++ b/arch/x86/kernel/Makefile
> @@ -19,6 +19,7 @@ endif
>  KASAN_SANITIZE_head$(BITS).o := n
>  KASAN_SANITIZE_dumpstack.o := n
>  KASAN_SANITIZE_dumpstack_$(BITS).o := n
> +KASAN_SANITIZE_paravirt.o := n
>  
>  CFLAGS_irq.o := -I$(src)/../include/asm/trace

Shouldn't we take this one irrespectively of what happens to the rest in
the patchset?

-- 
Regards/Gruss,
    Boris.

ECO tip #101: Trim your mails when you reply.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
