Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id C64D96B00CA
	for <linux-mm@kvack.org>; Wed,  6 Nov 2013 05:49:27 -0500 (EST)
Received: by mail-pd0-f172.google.com with SMTP id w10so10021978pde.31
        for <linux-mm@kvack.org>; Wed, 06 Nov 2013 02:49:27 -0800 (PST)
Received: from psmtp.com ([74.125.245.158])
        by mx.google.com with SMTP id hb3si16972109pac.152.2013.11.06.02.49.24
        for <linux-mm@kvack.org>;
        Wed, 06 Nov 2013 02:49:26 -0800 (PST)
Received: by mail-pd0-f181.google.com with SMTP id x10so9913301pdj.40
        for <linux-mm@kvack.org>; Wed, 06 Nov 2013 02:49:23 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20131106103403.GB21074@mudshark.cambridge.arm.com>
References: <1382442839-7458-1-git-send-email-kirill.shutemov@linux.intel.com>
	<20131105150145.734a5dd5b5d455800ebfa0d3@linux-foundation.org>
	<20131105224217.GC20167@shutemov.name>
	<20131105155619.021f32eba1ca8f15a73ed4c9@linux-foundation.org>
	<20131105231310.GE20167@shutemov.name>
	<20131106103403.GB21074@mudshark.cambridge.arm.com>
Date: Wed, 6 Nov 2013 11:49:23 +0100
Message-ID: <CAMuHMdWyrsyrf8N0ytSDfe0y1oxGrfFCZCmV-9Mm11yuyTs=5g@mail.gmail.com>
Subject: Re: [PATCH] mm: create a separate slab for page->ptl allocation
From: Geert Uytterhoeven <geert@linux-m68k.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Deacon <will.deacon@arm.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>

On Wed, Nov 6, 2013 at 11:34 AM, Will Deacon <will.deacon@arm.com> wrote:
> FWIW: if the architecture selects ARCH_USE_CMPXCHG_LOCKREF, then a spinlock_t
> is 32-bit (assuming that unsigned int is also 32-bit).

Linux already assumes (unsigned) int is 32-bit.

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
