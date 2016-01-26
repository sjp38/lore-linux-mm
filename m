Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f182.google.com (mail-yk0-f182.google.com [209.85.160.182])
	by kanga.kvack.org (Postfix) with ESMTP id 3281A6B0005
	for <linux-mm@kvack.org>; Tue, 26 Jan 2016 04:08:08 -0500 (EST)
Received: by mail-yk0-f182.google.com with SMTP id v14so192124712ykd.3
        for <linux-mm@kvack.org>; Tue, 26 Jan 2016 01:08:08 -0800 (PST)
Received: from mail-yk0-x241.google.com (mail-yk0-x241.google.com. [2607:f8b0:4002:c07::241])
        by mx.google.com with ESMTPS id z67si142983ywb.228.2016.01.26.01.08.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Jan 2016 01:08:07 -0800 (PST)
Received: by mail-yk0-x241.google.com with SMTP id v14so14201388ykd.1
        for <linux-mm@kvack.org>; Tue, 26 Jan 2016 01:08:07 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1453740953-18109-1-git-send-email-labbott@fedoraproject.org>
References: <1453740953-18109-1-git-send-email-labbott@fedoraproject.org>
Date: Tue, 26 Jan 2016 10:08:06 +0100
Message-ID: <CA+rthh9diW4PddNjDm56o3peB+38oEh9Q5rPtbeQXKTnoEQc2w@mail.gmail.com>
Subject: Re: [kernel-hardening] [RFC][PATCH 0/3] Sanitization of buddy pages
From: Mathias Krause <minipli@googlemail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kernel-hardening@lists.openwall.com
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>, Laura Abbott <labbott@fedoraproject.org>, linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Kees Cook <keescook@chromium.org>, PaX Team <pageexec@freemail.hu>

On 25 January 2016 at 17:55, Laura Abbott <labbott@fedoraproject.org> wrote:
> Hi,
>
> This is an implementation of page poisoning/sanitization for all arches. It
> takes advantage of the existing implementation for
> !ARCH_SUPPORTS_DEBUG_PAGEALLOC arches. This is a different approach than what
> the Grsecurity patches were taking but should provide equivalent functionality.
>
> For those who aren't familiar with this, the goal of sanitization is to reduce
> the severity of use after free and uninitialized data bugs. Memory is cleared
> on free so any sensitive data is no longer available. Discussion of
> sanitization was brough up in a thread about CVEs
> (lkml.kernel.org/g/<20160119112812.GA10818@mwanda>)
>
> I eventually expect Kconfig names will want to be changed and or moved if this
> is going to be used for security but that can happen later.
>
> Credit to Mathias Krause for the version in grsecurity

Thanks for the credits but I don't deserve them. I've contributed the
slab based sanitization only. The page based one shipped in PaX and
grsecurity is from the PaX Team.

>
> Laura Abbott (3):
>   mm/debug-pagealloc.c: Split out page poisoning from debug page_alloc
>   mm/page_poison.c: Enable PAGE_POISONING as a separate option
>   mm/page_poisoning.c: Allow for zero poisoning
>
>  Documentation/kernel-parameters.txt |   5 ++
>  include/linux/mm.h                  |  13 +++
>  include/linux/poison.h              |   4 +
>  mm/Kconfig.debug                    |  35 +++++++-
>  mm/Makefile                         |   5 +-
>  mm/debug-pagealloc.c                | 127 +----------------------------
>  mm/page_alloc.c                     |  10 ++-
>  mm/page_poison.c                    | 158 ++++++++++++++++++++++++++++++++++++
>  8 files changed, 228 insertions(+), 129 deletions(-)
>  create mode 100644 mm/page_poison.c
>
> --
> 2.5.0
>

Regards,
Mathias

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
