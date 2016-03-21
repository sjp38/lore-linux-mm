Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f173.google.com (mail-pf0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 5B80D6B0005
	for <linux-mm@kvack.org>; Mon, 21 Mar 2016 12:34:08 -0400 (EDT)
Received: by mail-pf0-f173.google.com with SMTP id n5so270312316pfn.2
        for <linux-mm@kvack.org>; Mon, 21 Mar 2016 09:34:08 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id wv6si7159429pac.41.2016.03.21.09.34.07
        for <linux-mm@kvack.org>;
        Mon, 21 Mar 2016 09:34:07 -0700 (PDT)
Date: Mon, 21 Mar 2016 19:34:04 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCH 0/3] fs, mm: get rid of PAGE_CACHE_* and
 page_cache_{get,release} macros
Message-ID: <20160321163404.GA141069@black.fi.intel.com>
References: <1458561998-126622-1-git-send-email-kirill.shutemov@linux.intel.com>
 <alpine.DEB.2.20.1603211121210.26353@east.gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1603211121210.26353@east.gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Linus Torvalds <torvalds@linux-foundation.org>, Matthew Wilcox <willy@linux.intel.com>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

On Mon, Mar 21, 2016 at 11:25:09AM -0500, Christoph Lameter wrote:
> On Mon, 21 Mar 2016, Kirill A. Shutemov wrote:
> 
> > PAGE_CACHE_{SIZE,SHIFT,MASK,ALIGN} macros were introduced *long* time ago
> > with promise that one day it will be possible to implement page cache with
> > bigger chunks than PAGE_SIZE.
> >
> > This promise never materialized. And unlikely will.
> 
> So we decided that we are never going to put THP pages on a LRU?

Err?.. What?

We do have anon-THP pages on LRU. My huge tmpfs patchset also put
file-THPs on LRU list.

The patchset has nothing to do with THP or them being on LRU.

> Will this actually work if we have really huge memory (100s of TB) where
> almost everything is a huge page? Guess we have to use hugetlbfs and we
> need to think about this as being exempt from paging.

Sorry, I failed to understand your message.

Look on huge tmpfs patchset. It allows both small and huge pages in page
cache.

Anyway, it's out of scope of the patchset.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
