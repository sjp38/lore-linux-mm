Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f181.google.com (mail-pf0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 172FE6B0005
	for <linux-mm@kvack.org>; Mon, 21 Mar 2016 13:07:06 -0400 (EDT)
Received: by mail-pf0-f181.google.com with SMTP id n5so271289687pfn.2
        for <linux-mm@kvack.org>; Mon, 21 Mar 2016 10:07:06 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id l79si19487662pfj.200.2016.03.21.10.07.05
        for <linux-mm@kvack.org>;
        Mon, 21 Mar 2016 10:07:05 -0700 (PDT)
Date: Mon, 21 Mar 2016 20:06:55 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCH 0/3] fs, mm: get rid of PAGE_CACHE_* and
 page_cache_{get,release} macros
Message-ID: <20160321170655.GA141158@black.fi.intel.com>
References: <1458561998-126622-1-git-send-email-kirill.shutemov@linux.intel.com>
 <alpine.DEB.2.20.1603211121210.26353@east.gentwo.org>
 <20160321163404.GA141069@black.fi.intel.com>
 <alpine.DEB.2.20.1603211155280.26653@east.gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1603211155280.26653@east.gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Linus Torvalds <torvalds@linux-foundation.org>, Matthew Wilcox <willy@linux.intel.com>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

On Mon, Mar 21, 2016 at 11:59:25AM -0500, Christoph Lameter wrote:
> On Mon, 21 Mar 2016, Kirill A. Shutemov wrote:
> 
> > We do have anon-THP pages on LRU. My huge tmpfs patchset also put
> > file-THPs on LRU list.
> 
> So they are on the LRU as 4k units? Tried to look it up.

One entry on LRU per huge page.

> > > Will this actually work if we have really huge memory (100s of TB) where
> > > almost everything is a huge page? Guess we have to use hugetlbfs and we
> > > need to think about this as being exempt from paging.
> >
> > Sorry, I failed to understand your message.
> >
> > Look on huge tmpfs patchset. It allows both small and huge pages in page
> > cache.
> 
> Thus my wonder about this patchset. It seems then that the huge pages are
> treated as 4k pages? Otherwise we would have two sizes for pages in the
> page cache. Sorry I did not follow that too closely. Will try finding that
> patchset.

We do have two page sizes in the page cache. It's the only option to get
transparent huge pages transparent.

We have 512 (on x86-64) entries on radix-tree per huge page, but we can
opt to Matthew's multi-order entries later. See e61452365372 "radix_tree:
add support for multi-order entries".

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
