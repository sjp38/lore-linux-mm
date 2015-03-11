Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id AAF8590002E
	for <linux-mm@kvack.org>; Wed, 11 Mar 2015 02:30:30 -0400 (EDT)
Received: by wiwh11 with SMTP id h11so8815198wiw.5
        for <linux-mm@kvack.org>; Tue, 10 Mar 2015 23:30:30 -0700 (PDT)
Received: from mail-we0-x22a.google.com (mail-we0-x22a.google.com. [2a00:1450:400c:c03::22a])
        by mx.google.com with ESMTPS id bp16si7560292wib.122.2015.03.10.23.30.28
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Mar 2015 23:30:29 -0700 (PDT)
Received: by wevk48 with SMTP id k48so6804384wev.7
        for <linux-mm@kvack.org>; Tue, 10 Mar 2015 23:30:28 -0700 (PDT)
Date: Wed, 11 Mar 2015 07:30:25 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 1/3] mm, x86: Document return values of mapping funcs
Message-ID: <20150311063024.GB29788@gmail.com>
References: <1426018997-12936-1-git-send-email-toshi.kani@hp.com>
 <1426018997-12936-2-git-send-email-toshi.kani@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1426018997-12936-2-git-send-email-toshi.kani@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: akpm@linux-foundation.org, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, arnd@arndb.de, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com, Elliott@hp.com, pebolle@tiscali.nl


* Toshi Kani <toshi.kani@hp.com> wrote:

> Documented the return values of KVA mapping functions,
> pud_set_huge(), pmd_set_huge, pud_clear_huge() and
> pmd_clear_huge().
> 
> Simplified the conditions to select HAVE_ARCH_HUGE_VMAP
> in Kconfig since X86_PAE depends on X86_32.

Changelogs are not a diary, they are a story, generally written in the 
present tense. So it should be something like:

  Document the return values of KVA mapping functions,
  pud_set_huge(), pmd_set_huge, pud_clear_huge() and
  pmd_clear_huge().

  Simplify the conditions to select HAVE_ARCH_HUGE_VMAP
  in the Kconfig, since X86_PAE depends on X86_32.

(also note the slight fixes I made to the text.)

> There is no functinal change in this patch.

Typo.

> +/**
> + * pud_set_huge - setup kernel PUD mapping
> + *
> + * MTRRs can override PAT memory types with a 4KB granularity.  Therefore,

s/with a/with

> + * it does not set up a huge page when the range is covered by non-WB type
> + * of MTRRs.  0xFF indicates that MTRRs are disabled.
> + *
> + * Return 1 on success, and 0 on no-operation.

What is a 'no-operation'?

I suspect you want:

    * Returns 1 on success, and 0 when no PUD was set.


> +/**
> + * pmd_set_huge - setup kernel PMD mapping
> + *
> + * MTRRs can override PAT memory types with a 4KB granularity.  Therefore,
> + * it does not set up a huge page when the range is covered by non-WB type
> + * of MTRRs.  0xFF indicates that MTRRs are disabled.
> + *
> + * Return 1 on success, and 0 on no-operation.

Ditto (and the rest of the patch).

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
