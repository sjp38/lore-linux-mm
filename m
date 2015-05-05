Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f49.google.com (mail-wg0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 7488E6B0038
	for <linux-mm@kvack.org>; Tue,  5 May 2015 03:30:07 -0400 (EDT)
Received: by wgyo15 with SMTP id o15so172705036wgy.2
        for <linux-mm@kvack.org>; Tue, 05 May 2015 00:30:07 -0700 (PDT)
Received: from kirsi1.inet.fi (mta-out1.inet.fi. [62.71.2.195])
        by mx.google.com with ESMTP id d1si15294387wiy.103.2015.05.05.00.30.05
        for <linux-mm@kvack.org>;
        Tue, 05 May 2015 00:30:05 -0700 (PDT)
Date: Tue, 5 May 2015 10:29:52 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 0/2] Reintroduce picky __compound_tail_refcounted()
Message-ID: <20150505072952.GA9414@node.dhcp.inet.fi>
References: <1430238298-80442-1-git-send-email-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1430238298-80442-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrea Arcangeli <aarcange@redhat.com>, Borislav Petkov <bp@alien8.de>, Hugh Dickins <hughd@google.com>, Linus Torvalds <torvalds@linux-foundation.org>

On Tue, Apr 28, 2015 at 07:24:56PM +0300, Kirill A. Shutemov wrote:
> Hi Andrew,
> 
> My patch 8d63d99a5dfb which was merged during 4.1 merge window caused
> regression:
> 
>   page:ffffea0010a15040 count:0 mapcount:1 mapping:          (null) index:0x0
>   flags: 0x8000000000008014(referenced|dirty|tail)
>   page dumped because: VM_BUG_ON_PAGE(page_mapcount(page) != 0)
>   ------------[ cut here ]------------
>   kernel BUG at mm/swap.c:134!
> 
> The patch was reverted by Linus.
> 
> This VM_BUG_ON_PAGE() is bogus. The first patch explains why the assert is
> wrong and removes it. The second re-introduces original patch.
> 
> Kirill A. Shutemov (2):
>   mm: drop bogus VM_BUG_ON_PAGE assert in put_page() codepath
>   mm: avoid tail page refcounting on non-THP compound pages
> 
>  include/linux/mm.h | 2 +-
>  mm/swap.c          | 1 -
>  2 files changed, 1 insertion(+), 2 deletions(-)

Ping?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
