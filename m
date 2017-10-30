Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 14C056B0033
	for <linux-mm@kvack.org>; Mon, 30 Oct 2017 12:09:43 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id v88so8206838wrb.22
        for <linux-mm@kvack.org>; Mon, 30 Oct 2017 09:09:43 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id r23sor7031231edm.22.2017.10.30.09.09.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 30 Oct 2017 09:09:32 -0700 (PDT)
Date: Mon, 30 Oct 2017 19:09:30 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] mm: migration: deposit page table when copying a PMD
 migration entry.
Message-ID: <20171030160930.bxisbzpw5pjznelj@node.shutemov.name>
References: <20171030144636.4836-1-zi.yan@sent.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171030144636.4836-1-zi.yan@sent.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zi Yan <zi.yan@sent.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Zi Yan <zi.yan@cs.rutgers.edu>, Fengguang Wu <fengguang.wu@intel.com>

On Mon, Oct 30, 2017 at 10:46:36AM -0400, Zi Yan wrote:
> From: Zi Yan <zi.yan@cs.rutgers.edu>
> 
> We need to deposit pre-allocated PTE page table when a PMD migration
> entry is copied in copy_huge_pmd(). Otherwise, we will leak the
> pre-allocated page and cause a NULL pointer dereference later
> in zap_huge_pmd().
> 
> The missing counters during PMD migration entry copy process are added
> as well.
> 
> The bug report is here: https://lkml.org/lkml/2017/10/29/214
> 
> Fixes: 84c3fc4e9c563 ("mm: thp: check pmd migration entry in common path")
> Reported-by: Fengguang Wu <fengguang.wu@intel.com>
> Signed-off-by: Zi Yan <zi.yan@cs.rutgers.edu>
> Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
