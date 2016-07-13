Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f72.google.com (mail-vk0-f72.google.com [209.85.213.72])
	by kanga.kvack.org (Postfix) with ESMTP id 378DE6B025F
	for <linux-mm@kvack.org>; Wed, 13 Jul 2016 18:01:49 -0400 (EDT)
Received: by mail-vk0-f72.google.com with SMTP id r135so125321091vkf.0
        for <linux-mm@kvack.org>; Wed, 13 Jul 2016 15:01:49 -0700 (PDT)
Received: from mail-vk0-x232.google.com (mail-vk0-x232.google.com. [2607:f8b0:400c:c05::232])
        by mx.google.com with ESMTPS id l189si921906vkh.174.2016.07.13.15.01.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Jul 2016 15:01:48 -0700 (PDT)
Received: by mail-vk0-x232.google.com with SMTP id x130so85238387vkc.0
        for <linux-mm@kvack.org>; Wed, 13 Jul 2016 15:01:48 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1468446964-22213-2-git-send-email-keescook@chromium.org>
References: <1468446964-22213-1-git-send-email-keescook@chromium.org> <1468446964-22213-2-git-send-email-keescook@chromium.org>
From: Andy Lutomirski <luto@amacapital.net>
Date: Wed, 13 Jul 2016 15:01:28 -0700
Message-ID: <CALCETrVDJDjdoh7yvOPd=_5twQnzQRhe8G2KLaRw-NnA1Uf__g@mail.gmail.com>
Subject: Re: [PATCH v2 01/11] mm: Implement stack frame object validation
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, Casey Schaufler <casey@schaufler-ca.com>, PaX Team <pageexec@freemail.hu>, Brad Spengler <spender@grsecurity.net>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Michael Ellerman <mpe@ellerman.id.au>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, "David S. Miller" <davem@davemloft.net>, X86 ML <x86@kernel.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@suse.de>, Mathias Krause <minipli@googlemail.com>, Jan Kara <jack@suse.cz>, Vitaly Wool <vitalywool@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Dmitry Vyukov <dvyukov@google.com>, Laura Abbott <labbott@fedoraproject.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org, linux-arch <linux-arch@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, Josh Poimboeuf <jpoimboe@redhat.com>

On Wed, Jul 13, 2016 at 2:55 PM, Kees Cook <keescook@chromium.org> wrote:
> This creates per-architecture function arch_within_stack_frames() that
> should validate if a given object is contained by a kernel stack frame.
> Initial implementation is on x86.
>
> This is based on code from PaX.
>

This, along with Josh's livepatch work, are two examples of unwinders
that matter for correctness instead of just debugging.  ISTM this
should just use Josh's code directly once it's been written.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
