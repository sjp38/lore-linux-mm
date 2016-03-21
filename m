Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f171.google.com (mail-io0-f171.google.com [209.85.223.171])
	by kanga.kvack.org (Postfix) with ESMTP id 349D16B0005
	for <linux-mm@kvack.org>; Mon, 21 Mar 2016 12:25:12 -0400 (EDT)
Received: by mail-io0-f171.google.com with SMTP id m184so215285984iof.1
        for <linux-mm@kvack.org>; Mon, 21 Mar 2016 09:25:12 -0700 (PDT)
Received: from resqmta-ch2-08v.sys.comcast.net (resqmta-ch2-08v.sys.comcast.net. [2001:558:fe21:29:69:252:207:40])
        by mx.google.com with ESMTPS id a13si21148491ioj.61.2016.03.21.09.25.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Mon, 21 Mar 2016 09:25:11 -0700 (PDT)
Date: Mon, 21 Mar 2016 11:25:09 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 0/3] fs, mm: get rid of PAGE_CACHE_* and page_cache_{get,release}
 macros
In-Reply-To: <1458561998-126622-1-git-send-email-kirill.shutemov@linux.intel.com>
Message-ID: <alpine.DEB.2.20.1603211121210.26353@east.gentwo.org>
References: <1458561998-126622-1-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Linus Torvalds <torvalds@linux-foundation.org>, Matthew Wilcox <willy@linux.intel.com>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

On Mon, 21 Mar 2016, Kirill A. Shutemov wrote:

> PAGE_CACHE_{SIZE,SHIFT,MASK,ALIGN} macros were introduced *long* time ago
> with promise that one day it will be possible to implement page cache with
> bigger chunks than PAGE_SIZE.
>
> This promise never materialized. And unlikely will.

So we decided that we are never going to put THP pages on a LRU? Will this
actually work if we have really huge memory (100s of TB) where almost
everything is a huge page? Guess we have to use hugetlbfs and we need to
think about this as being exempt from paging.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
