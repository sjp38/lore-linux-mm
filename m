Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id B237E6B0005
	for <linux-mm@kvack.org>; Wed,  3 Aug 2016 15:04:56 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id 1so131003972wmz.2
        for <linux-mm@kvack.org>; Wed, 03 Aug 2016 12:04:56 -0700 (PDT)
Received: from mail-lf0-x241.google.com (mail-lf0-x241.google.com. [2a00:1450:4010:c07::241])
        by mx.google.com with ESMTPS id z195si4100941lfd.120.2016.08.03.12.04.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Aug 2016 12:04:55 -0700 (PDT)
Received: by mail-lf0-x241.google.com with SMTP id f93so12468928lfi.0
        for <linux-mm@kvack.org>; Wed, 03 Aug 2016 12:04:54 -0700 (PDT)
Date: Wed, 3 Aug 2016 22:04:51 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] shmem: Fix link error if huge pages support is disabled
Message-ID: <20160803190451.GA9830@node.shutemov.name>
References: <1470247099-14217-1-git-send-email-geert@linux-m68k.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1470247099-14217-1-git-send-email-geert@linux-m68k.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Aug 03, 2016 at 07:58:19PM +0200, Geert Uytterhoeven wrote:
> If CONFIG_TRANSPARENT_HUGE_PAGECACHE=n, HPAGE_PMD_NR evaluates to
> BUILD_BUG_ON(), and may cause (e.g. with gcc 4.12):
> 
>     mm/built-in.o: In function `shmem_alloc_hugepage':
>     shmem.c:(.text+0x17570): undefined reference to `__compiletime_assert_1365'
> 
> To fix this, move the assignment to hindex after the check for huge
> pages support.
> 
> Fixes: 800d8c63b2e989c2 ("shmem: add huge pages support")
> Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
