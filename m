Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id 8377A6B0038
	for <linux-mm@kvack.org>; Wed, 11 Feb 2015 14:59:40 -0500 (EST)
Received: by mail-wi0-f175.google.com with SMTP id r20so20010192wiv.2
        for <linux-mm@kvack.org>; Wed, 11 Feb 2015 11:59:40 -0800 (PST)
Received: from mail-wg0-x233.google.com (mail-wg0-x233.google.com. [2a00:1450:400c:c00::233])
        by mx.google.com with ESMTPS id fb18si712235wid.18.2015.02.11.11.59.38
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Feb 2015 11:59:39 -0800 (PST)
Received: by mail-wg0-f51.google.com with SMTP id y19so5705778wgg.10
        for <linux-mm@kvack.org>; Wed, 11 Feb 2015 11:59:38 -0800 (PST)
Date: Wed, 11 Feb 2015 11:59:33 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 2/4] mm: rename __mlock_vma_pages_range() to
 populate_vma_page_range()
In-Reply-To: <1423674728-214192-3-git-send-email-kirill.shutemov@linux.intel.com>
Message-ID: <alpine.DEB.2.10.1502111150400.9656@chino.kir.corp.google.com>
References: <1423674728-214192-1-git-send-email-kirill.shutemov@linux.intel.com> <1423674728-214192-3-git-send-email-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Michel Lespinasse <walken@google.com>, Rik van Riel <riel@redhat.com>

On Wed, 11 Feb 2015, Kirill A. Shutemov wrote:

> __mlock_vma_pages_range() doesn't necessary mlock pages. It depends on
> vma flags. The same codepath is used for MAP_POPULATE.
> 

s/necessary/necessarily/

> Let's rename __mlock_vma_pages_range() to populate_vma_page_range().
> 
> This patch also drops mlock_vma_pages_range() references from
> documentation. It has gone in commit cea10a19b797.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

I think it makes sense to drop the references about "downgrading" 
mm->mmap_sem in the documentation since populate_vma_page_range() can be 
called with it held either for read or write depending on the context.

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
