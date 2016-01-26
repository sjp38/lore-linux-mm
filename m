Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 49C7E6B0005
	for <linux-mm@kvack.org>; Tue, 26 Jan 2016 01:06:39 -0500 (EST)
Received: by mail-pa0-f51.google.com with SMTP id ho8so92800892pac.2
        for <linux-mm@kvack.org>; Mon, 25 Jan 2016 22:06:39 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id q87si39072435pfa.197.2016.01.25.22.06.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Jan 2016 22:06:38 -0800 (PST)
Subject: Re: [RFC][PATCH 0/3] Sanitization of buddy pages
References: <1453740953-18109-1-git-send-email-labbott@fedoraproject.org>
From: Sasha Levin <sasha.levin@oracle.com>
Message-ID: <56A70C9D.8060102@oracle.com>
Date: Tue, 26 Jan 2016 01:05:17 -0500
MIME-Version: 1.0
In-Reply-To: <1453740953-18109-1-git-send-email-labbott@fedoraproject.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <labbott@fedoraproject.org>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com, Kees Cook <keescook@chromium.org>, Andrey Ryabinin <ryabinin.a.a@gmail.com>

On 01/25/2016 11:55 AM, Laura Abbott wrote:
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

Should poisoning of this kind be using kasan rather than "old fashioned"
poisoning?


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
