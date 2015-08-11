Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f47.google.com (mail-qg0-f47.google.com [209.85.192.47])
	by kanga.kvack.org (Postfix) with ESMTP id F24076B0038
	for <linux-mm@kvack.org>; Tue, 11 Aug 2015 17:14:06 -0400 (EDT)
Received: by qgdd90 with SMTP id d90so48274005qgd.3
        for <linux-mm@kvack.org>; Tue, 11 Aug 2015 14:14:06 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id w74si5774059qha.69.2015.08.11.14.14.05
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Aug 2015 14:14:06 -0700 (PDT)
Date: Tue, 11 Aug 2015 14:14:04 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm/hwpoison: fix panic due to split huge zero page
Message-Id: <20150811141404.ecb19c1a66c32abf60d6663c@linux-foundation.org>
In-Reply-To: <BLU437-SMTP5348473FAB81C31638A9A0807F0@phx.gbl>
References: <BLU437-SMTP5348473FAB81C31638A9A0807F0@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <wanpeng.li@hotmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

On Tue, 11 Aug 2015 18:47:57 +0800 Wanpeng Li <wanpeng.li@hotmail.com> wrote:

> 
> ...
>
> Huge zero page is allocated if page fault w/o FAULT_FLAG_WRITE flag. 
> The get_user_pages_fast() which called in madvise_hwpoison() will get 
> huge zero page if the page is not allocated before. Huge zero page is 
> a tranparent huge page, however, it is not an anonymous page. memory_failure 
> will split the huge zero page and trigger BUG_ON(is_huge_zero_page(page)); 
> After commit (98ed2b0: mm/memory-failure: give up error handling for 
> non-tail-refcounted thp), memory_failure will not catch non anon thp 
> from madvise_hwpoison path and this bug occur.

So I'm assuming this patch is needed for 4.2 but not in earlier
kernels.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
