Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f170.google.com (mail-pf0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 071D86B007E
	for <linux-mm@kvack.org>; Tue, 22 Mar 2016 06:41:25 -0400 (EDT)
Received: by mail-pf0-f170.google.com with SMTP id 4so174020720pfd.0
        for <linux-mm@kvack.org>; Tue, 22 Mar 2016 03:41:24 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id p13si15044840pfj.175.2016.03.22.03.41.17
        for <linux-mm@kvack.org>;
        Tue, 22 Mar 2016 03:41:17 -0700 (PDT)
Date: Tue, 22 Mar 2016 13:41:13 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCH 0/3] fs, mm: get rid of PAGE_CACHE_* and
 page_cache_{get,release} macros
Message-ID: <20160322104113.GA143214@black.fi.intel.com>
References: <1458561998-126622-1-git-send-email-kirill.shutemov@linux.intel.com>
 <alpine.DEB.2.20.1603211121210.26353@east.gentwo.org>
 <20160321163404.GA141069@black.fi.intel.com>
 <alpine.DEB.2.20.1603211155280.26653@east.gentwo.org>
 <20160321170655.GA141158@black.fi.intel.com>
 <alpine.DEB.2.20.1603211229060.26653@east.gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1603211229060.26653@east.gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Linus Torvalds <torvalds@linux-foundation.org>, Matthew Wilcox <willy@linux.intel.com>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

On Mon, Mar 21, 2016 at 12:29:34PM -0500, Christoph Lameter wrote:
> On Mon, 21 Mar 2016, Kirill A. Shutemov wrote:
> 
> > We do have two page sizes in the page cache. It's the only option to get
> > transparent huge pages transparent.
> 
> Should then not PAGE_CACHE_SIZE take a page parameter and return the
> correct page size?

Why? What would you achieve by this?

We already have a way to find out size of page: compoun_order() or
hpage_nr_pages().

And not in every place where PAGE_CACHE_SIZE is used we have corresponding
struct page.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
