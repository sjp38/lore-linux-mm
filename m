Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 908A26B0031
	for <linux-mm@kvack.org>; Thu, 12 Jun 2014 18:07:42 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id kq14so1397719pab.14
        for <linux-mm@kvack.org>; Thu, 12 Jun 2014 15:07:42 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id he6si2496691pac.20.2014.06.12.15.07.41
        for <linux-mm@kvack.org>;
        Thu, 12 Jun 2014 15:07:41 -0700 (PDT)
Message-ID: <539A248F.2090306@intel.com>
Date: Thu, 12 Jun 2014 15:07:11 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH -mm v2 06/11] pagewalk: add size to struct mm_walk
References: <1402609691-13950-1-git-send-email-n-horiguchi@ah.jp.nec.com> <1402609691-13950-7-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1402609691-13950-7-git-send-email-n-horiguchi@ah.jp.nec.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-kernel@vger.kernel.org

On 06/12/2014 02:48 PM, Naoya Horiguchi wrote:
> This variable is helpful if we try to share the callback function between
> multiple slots (for example between pte_entry() and pmd_entry()) as done
> in later patches.

smaps_pte() already does this:

static int smaps_pte(pte_t *pte, unsigned long addr, unsigned long end,
                        struct mm_walk *walk)
...
        unsigned long ptent_size = end - addr;

Other than the hugetlb handler, can't we always imply the size from
end-addr?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
