Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f174.google.com (mail-pf0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 4A71F6B0264
	for <linux-mm@kvack.org>; Tue, 15 Mar 2016 11:31:05 -0400 (EDT)
Received: by mail-pf0-f174.google.com with SMTP id n5so33186221pfn.2
        for <linux-mm@kvack.org>; Tue, 15 Mar 2016 08:31:05 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id n2si5705999pap.201.2016.03.15.08.31.03
        for <linux-mm@kvack.org>;
        Tue, 15 Mar 2016 08:31:03 -0700 (PDT)
Subject: Re: [PATCH] thp, mlock: update unevictable-lru.txt
References: <1458053744-40664-1-git-send-email-kirill.shutemov@linux.intel.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <56E82AAE.8090003@intel.com>
Date: Tue, 15 Mar 2016 08:30:54 -0700
MIME-Version: 1.0
In-Reply-To: <1458053744-40664-1-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org

On 03/15/2016 07:55 AM, Kirill A. Shutemov wrote:
> +Transparent huge page is represented by single entry on a lru list and
> +therefore we can only make unevictable entire compound page, not
> +individual subpages.

A few grammar nits:

A transparent huge page is represented by a single entry on an lru list.
Therefore, we can only make unevictable an entire compound page, not
individual subpages.

...
> +We handle this by forbidding mlocking PTE-mapped huge pages. This way we
> +keep the huge page accessible for vmscan. Under memory pressure the page
> +will be split, subpages from VM_LOCKED VMAs moved to unevictable lru and
> +the rest can be evicted.

What do you mean by "mlocking" in this context?  Do you mean that we
actually return -ESOMETHING from mlock() on PTE-mapped huge pages?  Or,
do you just mean that we defer treating PTE-mapped huge pages as
PageUnevictable() inside the kernel?

I think we should probably avoid saying "mlocking" when we really mean
"kernel-internal mlocked page handling" aka. the unevictable list.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
