Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 8983E6B007E
	for <linux-mm@kvack.org>; Thu, 31 Mar 2016 22:35:14 -0400 (EDT)
Received: by mail-pa0-f48.google.com with SMTP id zm5so79697390pac.0
        for <linux-mm@kvack.org>; Thu, 31 Mar 2016 19:35:14 -0700 (PDT)
Received: from mail-pa0-x230.google.com (mail-pa0-x230.google.com. [2607:f8b0:400e:c03::230])
        by mx.google.com with ESMTPS id q26si17905867pfi.106.2016.03.31.19.35.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 Mar 2016 19:35:13 -0700 (PDT)
Received: by mail-pa0-x230.google.com with SMTP id fe3so79625993pab.1
        for <linux-mm@kvack.org>; Thu, 31 Mar 2016 19:35:13 -0700 (PDT)
Date: Thu, 31 Mar 2016 18:35:10 -0800
From: Kent Overstreet <kent.overstreet@gmail.com>
Subject: Re: [PATCH] mm: Refactor find_get_pages() & friends
Message-ID: <20160401023510.GA28762@kmo-pixel>
References: <20160309011643.GA23179@kmo-pixel>
 <20160329142911.f2b069c8af06f649b86ec993@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160329142911.f2b069c8af06f649b86ec993@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Al Viro <viro@zeniv.linux.org.uk>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Mar 29, 2016 at 02:29:11PM -0700, Andrew Morton wrote:
> On Tue, 8 Mar 2016 16:16:43 -0900 Kent Overstreet <kent.overstreet@gmail.com> wrote:
> 
> > Collapse redundant implementations of various gang pagecache lookup - this is
> > also prep work for pagecache iterator work
> 
> Patch looks nice.  Unfortunately filemap.c has changed rather a lot
> since 4.5.  Can you please redo the patch some time?
> 
> And a more informative changelog would be appropriate, although it's
> all pretty obvious.  I don't know what "pagecache iterator work" is
> and I doubt if many other readers do either, so some illumination there
> wouldn't hurt.

Can do - sending you the pagecache iterator patch too:

Kent Overstreet (2):
  mm: Refactor find_get_pages() & friends
  mm: Real pagecache iterators

 fs/ext4/inode.c            | 261 +++++++++++++------------------
 include/linux/pagemap.h    | 142 +++++++++++++++--
 include/linux/pagevec.h    |  67 +++++++-
 include/linux/radix-tree.h |  49 ++----
 mm/filemap.c               | 376 ++++++++++-----------------------------------
 mm/page-writeback.c        | 148 ++++++++----------
 mm/swap.c                  |  33 +---
 mm/truncate.c              | 259 ++++++++++++-------------------
 8 files changed, 546 insertions(+), 789 deletions(-)

-- 
2.8.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
