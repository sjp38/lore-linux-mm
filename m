Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f176.google.com (mail-ig0-f176.google.com [209.85.213.176])
	by kanga.kvack.org (Postfix) with ESMTP id 4E3286B0005
	for <linux-mm@kvack.org>; Mon, 21 Mar 2016 12:59:28 -0400 (EDT)
Received: by mail-ig0-f176.google.com with SMTP id nk17so75515820igb.1
        for <linux-mm@kvack.org>; Mon, 21 Mar 2016 09:59:28 -0700 (PDT)
Received: from resqmta-ch2-05v.sys.comcast.net (resqmta-ch2-05v.sys.comcast.net. [2001:558:fe21:29:69:252:207:37])
        by mx.google.com with ESMTPS id q78si11014819ioe.124.2016.03.21.09.59.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Mon, 21 Mar 2016 09:59:26 -0700 (PDT)
Date: Mon, 21 Mar 2016 11:59:25 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 0/3] fs, mm: get rid of PAGE_CACHE_* and page_cache_{get,release}
 macros
In-Reply-To: <20160321163404.GA141069@black.fi.intel.com>
Message-ID: <alpine.DEB.2.20.1603211155280.26653@east.gentwo.org>
References: <1458561998-126622-1-git-send-email-kirill.shutemov@linux.intel.com> <alpine.DEB.2.20.1603211121210.26353@east.gentwo.org> <20160321163404.GA141069@black.fi.intel.com>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Linus Torvalds <torvalds@linux-foundation.org>, Matthew Wilcox <willy@linux.intel.com>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

On Mon, 21 Mar 2016, Kirill A. Shutemov wrote:

> We do have anon-THP pages on LRU. My huge tmpfs patchset also put
> file-THPs on LRU list.

So they are on the LRU as 4k units? Tried to look it up.

> > Will this actually work if we have really huge memory (100s of TB) where
> > almost everything is a huge page? Guess we have to use hugetlbfs and we
> > need to think about this as being exempt from paging.
>
> Sorry, I failed to understand your message.
>
> Look on huge tmpfs patchset. It allows both small and huge pages in page
> cache.

Thus my wonder about this patchset. It seems then that the huge pages are
treated as 4k pages? Otherwise we would have two sizes for pages in the
page cache. Sorry I did not follow that too closely. Will try finding that
patchset.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
