Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id AE4B46B0031
	for <linux-mm@kvack.org>; Mon, 14 Oct 2013 05:12:42 -0400 (EDT)
Received: by mail-pa0-f43.google.com with SMTP id hz1so7230951pad.30
        for <linux-mm@kvack.org>; Mon, 14 Oct 2013 02:12:42 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <15762.1381509010@warthog.procyon.org.uk>
References: <1381428359-14843-16-git-send-email-kirill.shutemov@linux.intel.com>
 <1381428359-14843-1-git-send-email-kirill.shutemov@linux.intel.com>
 <15762.1381509010@warthog.procyon.org.uk>
Subject: Re: [PATCH 15/34] frv: handle pgtable_page_ctor() fail
Content-Transfer-Encoding: 7bit
Message-Id: <20131014091235.C06FBE0090@blue.fi.intel.com>
Date: Mon, 14 Oct 2013 12:12:35 +0300 (EEST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Howells <dhowells@redhat.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org

David Howells wrote:
> 
> Acked-by: David Howells <dhowells@redhat.com>
> 
> for the FRV and MN10300 patches.
> 
> Can you move pte_alloc_one() to common code, at least for some arches?  I
> think that the FRV and MN10300 ones should end up the same after this - and I
> wouldn't be surprised if some of the other arches do too.

There's no true approach for generic. It depends on what pgtable_t is:
pointer to struct page or virtual address of the allocated page table.
Some arches also use some sort of cache for page table allocator. Others
don't.

I don't see a sensible way generalize it.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
