Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id E14E86B0005
	for <linux-mm@kvack.org>; Sat,  9 Jul 2016 17:27:45 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id q11so6106878qtb.1
        for <linux-mm@kvack.org>; Sat, 09 Jul 2016 14:27:45 -0700 (PDT)
Received: from mail-vk0-x22c.google.com (mail-vk0-x22c.google.com. [2607:f8b0:400c:c05::22c])
        by mx.google.com with ESMTPS id 101si57170uag.94.2016.07.09.14.27.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 09 Jul 2016 14:27:44 -0700 (PDT)
Received: by mail-vk0-x22c.google.com with SMTP id f7so80553066vkb.3
        for <linux-mm@kvack.org>; Sat, 09 Jul 2016 14:27:44 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1467843928-29351-1-git-send-email-keescook@chromium.org>
References: <1467843928-29351-1-git-send-email-keescook@chromium.org>
From: Andy Lutomirski <luto@amacapital.net>
Date: Sat, 9 Jul 2016 14:27:25 -0700
Message-ID: <CALCETrU5Emr7jZNH5bh7Z+C8fLOcAah9SzeJbDjqW7N-xWGxHA@mail.gmail.com>
Subject: Re: [PATCH 0/9] mm: Hardened usercopy
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Brad Spengler <spender@grsecurity.net>, Pekka Enberg <penberg@kernel.org>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Casey Schaufler <casey@schaufler-ca.com>, Will Deacon <will.deacon@arm.com>, Rik van Riel <riel@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Dmitry Vyukov <dvyukov@google.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, X86 ML <x86@kernel.org>, Catalin Marinas <catalin.marinas@arm.com>, linux-arch <linux-arch@vger.kernel.org>, David Rientjes <rientjes@google.com>, Mathias Krause <minipli@googlemail.com>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, "David S. Miller" <davem@davemloft.net>, Laura Abbott <labbott@fedoraproject.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Jan Kara <jack@suse.cz>, Russell King <linux@armlinux.org.uk>, Michael Ellerman <mpe@ellerman.id.au>, Andrea Arcangeli <aarcange@redhat.com>, Fenghua Yu <fenghua.yu@intel.com>, linuxppc-dev@lists.ozlabs.org, Vitaly Wool <vitalywool@gmail.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Borislav Petkov <bp@suse.de>, Tony Luck <tony.luck@intel.com>, PaX Team <pageexec@freemail.hu>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, sparclinux@vger.kernel.org

On Jul 6, 2016 6:25 PM, "Kees Cook" <keescook@chromium.org> wrote:
>
> Hi,
>
> This is a start of the mainline port of PAX_USERCOPY[1]. After I started
> writing tests (now in lkdtm in -next) for Casey's earlier port[2], I
> kept tweaking things further and further until I ended up with a whole
> new patch series. To that end, I took Rik's feedback and made a number
> of other changes and clean-ups as well.
>

I like the series, but I have one minor nit to pick.  The effect of
this series is to harden usercopy, but most of the code is really
about infrastructure to validate that a pointed-to object is valid.
Might it make sense to call the infrastructure part something else?
After all, this could be extended in the future for memcpy or even for
some GCC plugin to check pointers passed to ordinary (non-allocator)
functions.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
