Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id 4FCD46B0032
	for <linux-mm@kvack.org>; Thu, 12 Feb 2015 06:03:25 -0500 (EST)
Received: by mail-wi0-f170.google.com with SMTP id hi2so4071799wib.1
        for <linux-mm@kvack.org>; Thu, 12 Feb 2015 03:03:24 -0800 (PST)
Received: from jenni2.inet.fi (mta-out1.inet.fi. [62.71.2.203])
        by mx.google.com with ESMTP id n18si2389721wie.4.2015.02.12.03.03.23
        for <linux-mm@kvack.org>;
        Thu, 12 Feb 2015 03:03:23 -0800 (PST)
Date: Thu, 12 Feb 2015 13:03:18 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 2/4] mm: rename __mlock_vma_pages_range() to
 populate_vma_page_range()
Message-ID: <20150212110318.GA15658@node.dhcp.inet.fi>
References: <1423674728-214192-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1423674728-214192-3-git-send-email-kirill.shutemov@linux.intel.com>
 <alpine.DEB.2.10.1502111150400.9656@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1502111150400.9656@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Michel Lespinasse <walken@google.com>, Rik van Riel <riel@redhat.com>

On Wed, Feb 11, 2015 at 11:59:33AM -0800, David Rientjes wrote:
> On Wed, 11 Feb 2015, Kirill A. Shutemov wrote:
> 
> > __mlock_vma_pages_range() doesn't necessary mlock pages. It depends on
> > vma flags. The same codepath is used for MAP_POPULATE.
> > 
> 
> s/necessary/necessarily/
> 
> > Let's rename __mlock_vma_pages_range() to populate_vma_page_range().
> > 
> > This patch also drops mlock_vma_pages_range() references from
> > documentation. It has gone in commit cea10a19b797.
> > 
> > Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> 
> I think it makes sense to drop the references about "downgrading" 
> mm->mmap_sem in the documentation since populate_vma_page_range() can be 
> called with it held either for read or write depending on the context.

I'm not sure what references you're talking about.

Is it about this part:

 * If @nonblocking is non-NULL, it must held for read only and may be
 * released.  If it's released, *@nonblocking will be set to 0.

?

The comment is still true as far as I can say. It comes from up_read() in
__lock_page_or_retry().

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
