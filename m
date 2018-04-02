Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3EE516B0009
	for <linux-mm@kvack.org>; Mon,  2 Apr 2018 14:08:17 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id z1so11587751qtz.12
        for <linux-mm@kvack.org>; Mon, 02 Apr 2018 11:08:17 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z40sor690963qtj.17.2018.04.02.11.08.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 02 Apr 2018 11:08:16 -0700 (PDT)
Date: Mon, 2 Apr 2018 14:08:13 -0400 (EDT)
From: Nicolas Pitre <nicolas.pitre@linaro.org>
Subject: Re: [PATCH v3 5/6] Initialize the mapping of KASan shadow memory
In-Reply-To: <20180402120440.31900-6-liuwenliang@huawei.com>
Message-ID: <nycvar.YSQ.7.76.1804021402521.28462@knanqh.ubzr>
References: <20180402120440.31900-1-liuwenliang@huawei.com> <20180402120440.31900-6-liuwenliang@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Abbott Liu <liuwenliang@huawei.com>
Cc: aryabinin@virtuozzo.com, dvyukov@google.com, Jonathan Corbet <corbet@lwn.net>, Russell King - ARM Linux <linux@armlinux.org.uk>, christoffer.dall@linaro.org, marc.zyngier@arm.com, kstewart@linuxfoundation.org, gregkh@linuxfoundation.org, f.fainelli@gmail.com, Andrew Morton <akpm@linux-foundation.org>, linux@rasmusvillemoes.dk, mawilcox@microsoft.com, pombredanne@nexb.com, ard.biesheuvel@linaro.org, vladimir.murzin@arm.com, alexander.levin@verizon.com, tglx@linutronix.de, thgarnie@google.com, dhowells@redhat.com, keescook@chromium.org, Arnd Bergmann <arnd@arndb.de>, geert@linux-m68k.org, tixy@linaro.org, julien.thierry@arm.com, mark.rutland@arm.com, james.morse@arm.com, zhichao.huang@linaro.org, jinb.park7@gmail.com, labbott@redhat.com, philip@cog.systems, grygorii.strashko@linaro.org, Catalin Marinas <catalin.marinas@arm.com>, opendmb@gmail.com, kirill.shutemov@linux.intel.com, kasan-dev@googlegroups.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, kvmarm@lists.cs.columbia.edu, linux-mm@kvack.org

On Mon, 2 Apr 2018, Abbott Liu wrote:

> index c79b829..20161e2 100644
> --- a/arch/arm/kernel/head-common.S
> +++ b/arch/arm/kernel/head-common.S
> @@ -115,6 +115,9 @@ __mmap_switched:
>  	str	r8, [r2]			@ Save atags pointer
>  	cmp	r3, #0
>  	strne	r10, [r3]			@ Save control register values
> +#ifdef CONFIG_KASAN
> +	bl	kasan_early_init
> +#endif
>  	mov	lr, #0
>  	b	start_kernel
>  ENDPROC(__mmap_switched)

Would be better if lr was cleared before calling kasan_early_init.


Nicolas
