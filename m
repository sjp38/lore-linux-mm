Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 54DA36B0039
	for <linux-mm@kvack.org>; Fri, 12 Sep 2014 17:14:33 -0400 (EDT)
Received: by mail-pa0-f45.google.com with SMTP id rd3so2126284pab.4
        for <linux-mm@kvack.org>; Fri, 12 Sep 2014 14:14:33 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id ya2si10182159pbb.87.2014.09.12.14.14.31
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Sep 2014 14:14:31 -0700 (PDT)
Date: Fri, 12 Sep 2014 14:14:29 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: export symbol dependencies of is_zero_pfn()
Message-Id: <20140912141429.17d570d1a7e1cb99ec73f0f7@linux-foundation.org>
In-Reply-To: <1410553043-575-1-git-send-email-ard.biesheuvel@linaro.org>
References: <1410553043-575-1-git-send-email-ard.biesheuvel@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Cc: kvm@vger.kernel.org, pbonzini@redhat.com, christoffer.dall@linaro.org, linux-mm@kvack.org, linux-s390@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mips@linux-mips.org, ralf@linux-mips.org, schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com

On Fri, 12 Sep 2014 22:17:23 +0200 Ard Biesheuvel <ard.biesheuvel@linaro.org> wrote:

> In order to make the static inline function is_zero_pfn() callable by
> modules, export its symbol dependencies 'zero_pfn' and (for s390 and
> mips) 'zero_page_mask'.

So hexagon and score get the export if/when needed.

> We need this for KVM, as CONFIG_KVM is a tristate for all supported
> architectures except ARM and arm64, and testing a pfn whether it refers
> to the zero page is required to correctly distinguish the zero page
> from other special RAM ranges that may also have the PG_reserved bit
> set, but need to be treated as MMIO memory.
> 
> Signed-off-by: Ard Biesheuvel <ard.biesheuvel@linaro.org>
> ---
>  arch/mips/mm/init.c | 1 +
>  arch/s390/mm/init.c | 1 +
>  mm/memory.c         | 2 ++

Looks OK to me.  Please include the patch in whichever tree is is that
needs it, and merge it up via that tree.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
