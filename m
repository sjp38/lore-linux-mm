Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1DC6E6B0253
	for <linux-mm@kvack.org>; Thu,  7 Jul 2016 15:37:48 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id a2so17186486lfe.0
        for <linux-mm@kvack.org>; Thu, 07 Jul 2016 12:37:48 -0700 (PDT)
Received: from Galois.linutronix.de (linutronix.de. [2001:470:1f0b:db:abcd:42:0:1])
        by mx.google.com with ESMTPS id m185si1541800wmm.126.2016.07.07.12.37.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 07 Jul 2016 12:37:46 -0700 (PDT)
Date: Thu, 7 Jul 2016 21:34:53 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH 1/9] mm: Hardened usercopy
In-Reply-To: <CAGXu5jJWVow4i_M7Qg4ZFgZh3k_fUxUs4pDJSf5Yc8Q-FK9HoQ@mail.gmail.com>
Message-ID: <alpine.DEB.2.11.1607072133550.4083@nanos>
References: <1467843928-29351-1-git-send-email-keescook@chromium.org> <1467843928-29351-2-git-send-email-keescook@chromium.org> <alpine.DEB.2.11.1607070938430.4083@nanos> <CAGXu5jJWVow4i_M7Qg4ZFgZh3k_fUxUs4pDJSf5Yc8Q-FK9HoQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, Casey Schaufler <casey@schaufler-ca.com>, PaX Team <pageexec@freemail.hu>, Brad Spengler <spender@grsecurity.net>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Michael Ellerman <mpe@ellerman.id.au>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, "David S. Miller" <davem@davemloft.net>, "x86@kernel.org" <x86@kernel.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@suse.de>, Mathias Krause <minipli@googlemail.com>, Jan Kara <jack@suse.cz>, Vitaly Wool <vitalywool@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Dmitry Vyukov <dvyukov@google.com>, Laura Abbott <labbott@fedoraproject.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, linux-ia64@vger.kernel.org, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, sparclinux <sparclinux@vger.kernel.org>, linux-arch <linux-arch@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>

On Thu, 7 Jul 2016, Kees Cook wrote:
> On Thu, Jul 7, 2016 at 3:42 AM, Thomas Gleixner <tglx@linutronix.de> wrote:
> > I'd rather make that a weak function returning 1 which can be replaced by
> > x86 for CONFIG_FRAME_POINTER=y. That also allows other architectures to
> > implement their specific frame checks.
> 
> Yeah, though I prefer CONFIG-controlled stuff over weak functions, but
> I agree, something like arch_check_stack_frame(...) or similar. I'll
> build something for this on the next revision.

I'm fine with CONFIG_CONTROLLED as long as the ifdeffery is limited to header
files.

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
