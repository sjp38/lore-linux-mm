Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id BDF126B0031
	for <linux-mm@kvack.org>; Sat, 16 Nov 2013 15:43:35 -0500 (EST)
Received: by mail-pd0-f178.google.com with SMTP id p10so4836308pdj.23
        for <linux-mm@kvack.org>; Sat, 16 Nov 2013 12:43:35 -0800 (PST)
Received: from psmtp.com ([74.125.245.118])
        by mx.google.com with SMTP id yf2si1487360pab.259.2013.11.16.12.43.33
        for <linux-mm@kvack.org>;
        Sat, 16 Nov 2013 12:43:34 -0800 (PST)
Received: by mail-pb0-f54.google.com with SMTP id ro12so5066233pbb.13
        for <linux-mm@kvack.org>; Sat, 16 Nov 2013 12:43:32 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1383833644-27091-2-git-send-email-kirill.shutemov@linux.intel.com>
References: <1383833644-27091-1-git-send-email-kirill.shutemov@linux.intel.com>
	<1383833644-27091-2-git-send-email-kirill.shutemov@linux.intel.com>
Date: Sat, 16 Nov 2013 21:43:32 +0100
Message-ID: <CAMuHMdV33zBfsztXGsSv5YO+r4c2Fxh+0tH7togtS7EjdhDXeA@mail.gmail.com>
Subject: Re: [PATCH 2/2] mm: create a separate slab for page->ptl allocation
From: Geert Uytterhoeven <geert@linux-m68k.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>

On Thu, Nov 7, 2013 at 3:14 PM, Kirill A. Shutemov
<kirill.shutemov@linux.intel.com> wrote:
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h

> +static inline void pgtable_init(void)
> +{
> +       ptlock_cache_init();
> +       pgtable_cache_init();
> +}

sparc64defconfig:

include/linux/mm.h:1391:2: error: implicit declaration of function
'pgtable_cache_init' [-Werror=implicit-function-declaration]
arch/sparc/include/asm/pgtable_64.h:978:13: error: conflicting types
for 'pgtable_cache_init' [-Werror]

http://kisskb.ellerman.id.au/kisskb/buildresult/10040274/

Has this been in -next?

Probably it needs <asm/pgtable.h>.

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
