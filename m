Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3C229828E1
	for <linux-mm@kvack.org>; Sat,  9 Jul 2016 13:07:37 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id f126so30771530wma.3
        for <linux-mm@kvack.org>; Sat, 09 Jul 2016 10:07:37 -0700 (PDT)
Received: from mail-wm0-x235.google.com (mail-wm0-x235.google.com. [2a00:1450:400c:c09::235])
        by mx.google.com with ESMTPS id w133si3221362wmw.108.2016.07.09.10.07.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 09 Jul 2016 10:07:36 -0700 (PDT)
Received: by mail-wm0-x235.google.com with SMTP id o80so962418wme.1
        for <linux-mm@kvack.org>; Sat, 09 Jul 2016 10:07:36 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <24451.1468045037@turing-police.cc.vt.edu>
References: <577f7e55.4668420a.84f17.5cb9SMTPIN_ADDED_MISSING@mx.google.com>
 <alpine.DEB.2.20.1607080844370.3379@east.gentwo.org> <CAGXu5jKE=h32tHVLsDeaPN1GfC+BB3YbFvC+5TE5TK1oR-xU3A@mail.gmail.com>
 <alpine.DEB.2.20.1607081119170.6192@east.gentwo.org> <CAGXu5j+UdkQA+k39GNLe5CwBPVD5ZbRGTCQLqS8VF=kWx+PtsQ@mail.gmail.com>
 <CAGXu5jKxw3RxWNKLX4XVCwJ6x_zA=_RwiU9jLDm2+VRO79G7+w@mail.gmail.com>
 <57809299.84b3370a.5390c.ffff9e58SMTPIN_ADDED_BROKEN@mx.google.com> <24451.1468045037@turing-police.cc.vt.edu>
From: Kees Cook <keescook@chromium.org>
Date: Sat, 9 Jul 2016 10:07:34 -0700
Message-ID: <CAGXu5jJhnTDDhun6U9rV8H9YzuiTcqSD035Uvdv3MXB+S-LtsA@mail.gmail.com>
Subject: Re: [kernel-hardening] Re: [PATCH 9/9] mm: SLUB hardened usercopy support
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Valdis Kletnieks <Valdis.Kletnieks@vt.edu>
Cc: "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, Christoph Lameter <cl@linux.com>, Jan Kara <jack@suse.cz>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Linux-MM <linux-mm@kvack.org>, sparclinux <sparclinux@vger.kernel.org>, linux-ia64@vger.kernel.org, Andrea Arcangeli <aarcange@redhat.com>, linux-arch <linux-arch@vger.kernel.org>, "x86@kernel.org" <x86@kernel.org>, Russell King <linux@armlinux.org.uk>, PaX Team <pageexec@freemail.hu>, Borislav Petkov <bp@suse.de>, Mathias Krause <minipli@googlemail.com>, Fenghua Yu <fenghua.yu@intel.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Tony Luck <tony.luck@intel.com>, Andy Lutomirski <luto@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Dmitry Vyukov <dvyukov@google.com>, Laura Abbott <labbott@fedoraproject.org>, Brad Spengler <spender@grsecurity.net>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, LKML <linux-kernel@vger.kernel.org>, Pekka Enberg <penberg@kernel.org>, Case y Sc hauf ler <casey@schaufler-ca.com>, Andrew Morton <akpm@linux-foundation.org>, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, "David S. Miller" <davem@davemloft.net>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

On Fri, Jul 8, 2016 at 11:17 PM,  <Valdis.Kletnieks@vt.edu> wrote:
> Yeah, 'ping' dies with a similar traceback going to rawv6_setsockopt(),
> and 'trinity' dies a horrid death during initialization because it creates
> some sctp sockets to fool around with.  The problem in all these cases is that
> setsockopt uses copy_from_user() to pull in the option value, and the allocation
> isn't tagged with USERCOPY to whitelist it.

Just a note to clear up confusion: this series doesn't include the
whitelist protection, so this appears to be either bugs in the slub
checker or bugs in the code using the cfq_io_cq cache. I suspect the
former. :)

-Kees

-- 
Kees Cook
Chrome OS & Brillo Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
