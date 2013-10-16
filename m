Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id E3B4B6B0031
	for <linux-mm@kvack.org>; Wed, 16 Oct 2013 08:11:53 -0400 (EDT)
Received: by mail-pa0-f42.google.com with SMTP id kx10so975638pab.15
        for <linux-mm@kvack.org>; Wed, 16 Oct 2013 05:11:53 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <CACz4_2eh3F2An9F0GxSvw8kSmn2VZbqbdRVGXA2B=gvPFCChUw@mail.gmail.com>
References: <20131015001214.GD3432@hippobay.mtv.corp.google.com>
 <20131015102912.2BC99E0090@blue.fi.intel.com>
 <CACz4_2eh3F2An9F0GxSvw8kSmn2VZbqbdRVGXA2B=gvPFCChUw@mail.gmail.com>
Subject: Re: [PATCH 03/12] mm, thp, tmpfs: handle huge page cases in
 shmem_getpage_gfp
Content-Transfer-Encoding: 7bit
Message-Id: <20131016121145.EFC7AE0090@blue.fi.intel.com>
Date: Wed, 16 Oct 2013 15:11:45 +0300 (EEST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ning Qu <quning@google.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Al Viro <viro@zeniv.linux.org.uk>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <willy@linux.intel.com>, Hillf Danton <dhillf@gmail.com>, Dave Hansen <dave@sr71.net>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

Ning Qu wrote:
> you mean something like this? If so, then fixed.
> 
>                if (must_use_thp) {
>                         page = shmem_alloc_hugepage(gfp, info, index);
>                         if (page) {
>                                 count_vm_event(THP_WRITE_ALLOC);
>                         } else
>                                 count_vm_event(THP_WRITE_ALLOC_FAILED);
>                 } else {
>                         page = shmem_alloc_page(gfp, info, index);
>                 }
> 
>                 if (!page) {
>                         error = -ENOMEM;
>                         goto unacct;
>                 }
>                 nr = hpagecache_nr_pages(page);

Yeah.

count_vm_event() part still looks ugly, but I have similar in my code.
I'll think more how to rework in to make it better.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
