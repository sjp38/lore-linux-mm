Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 56FD76B0003
	for <linux-mm@kvack.org>; Thu, 12 Jul 2018 09:42:30 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id f31-v6so9509266plb.10
        for <linux-mm@kvack.org>; Thu, 12 Jul 2018 06:42:30 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id u8-v6si21281585plh.492.2018.07.12.06.42.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Jul 2018 06:42:29 -0700 (PDT)
Date: Thu, 12 Jul 2018 16:42:10 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCH] thp: fix data loss when splitting a file pmd
Message-ID: <20180712134210.d7kzlubl6runpfkr@black.fi.intel.com>
References: <alpine.LSU.2.11.1807111741430.1106@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1807111741430.1106@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ashwin Chaugule <ashwinch@google.com>, "Huang, Ying" <ying.huang@intel.com>, Yang Shi <yang.shi@linux.alibaba.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, Jul 12, 2018 at 12:48:54AM +0000, Hugh Dickins wrote:
> __split_huge_pmd_locked() must check if the cleared huge pmd was dirty,
> and propagate that to PageDirty: otherwise, data may be lost when a huge
> tmpfs page is modified then split then reclaimed.
> 
> How has this taken so long to be noticed?  Because there was no problem
> when the huge page is written by a write system call (shmem_write_end()
> calls set_page_dirty()), nor when the page is allocated for a write fault
> (fault_dirty_shared_page() calls set_page_dirty()); but when allocated
> for a read fault (which MAP_POPULATE simulates), no set_page_dirty().

Yeah... Sorry.

Reviewed-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

-- 
 Kirill A. Shutemov
