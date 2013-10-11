Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f54.google.com (mail-pb0-f54.google.com [209.85.160.54])
	by kanga.kvack.org (Postfix) with ESMTP id E39816B0031
	for <linux-mm@kvack.org>; Fri, 11 Oct 2013 01:51:04 -0400 (EDT)
Received: by mail-pb0-f54.google.com with SMTP id ro12so3688712pbb.13
        for <linux-mm@kvack.org>; Thu, 10 Oct 2013 22:51:04 -0700 (PDT)
Received: by mail-ea0-f179.google.com with SMTP id b10so1572953eae.24
        for <linux-mm@kvack.org>; Thu, 10 Oct 2013 22:51:01 -0700 (PDT)
Date: Fri, 11 Oct 2013 07:50:58 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 01/34] x86: add missed pgtable_pmd_page_ctor/dtor calls
 for preallocated pmds
Message-ID: <20131011055058.GA4838@gmail.com>
References: <1381428359-14843-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1381428359-14843-2-git-send-email-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1381428359-14843-2-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org


* Kirill A. Shutemov <kirill.shutemov@linux.intel.com> wrote:

> I've missed that we preallocate few pmds on pgd_alloc() if X86_PAE
> enabled. Let's add missed constructor/destructor calls.
> 
> I haven't noticed it during testing since prep_new_page() clears
> page->mapping and therefore page->ptl. It's effectively equal to
> spin_lock_init(&page->ptl).
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

Acked-by: Ingo Molnar <mingo@kernel.org>

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
