Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 12D1A6B02A1
	for <linux-mm@kvack.org>; Wed,  2 Nov 2016 04:40:36 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id a136so2552800pfa.5
        for <linux-mm@kvack.org>; Wed, 02 Nov 2016 01:40:36 -0700 (PDT)
Received: from mail-pf0-x243.google.com (mail-pf0-x243.google.com. [2607:f8b0:400e:c00::243])
        by mx.google.com with ESMTPS id 3si1719810pfd.50.2016.11.02.01.40.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Nov 2016 01:40:35 -0700 (PDT)
Received: by mail-pf0-x243.google.com with SMTP id y68so1162903pfb.1
        for <linux-mm@kvack.org>; Wed, 02 Nov 2016 01:40:35 -0700 (PDT)
Date: Wed, 2 Nov 2016 19:40:24 +1100
From: Nicholas Piggin <npiggin@gmail.com>
Subject: Re: [PATCH 2/2] mm: add PageWaiters bit to indicate waitqueue
 should be checked
Message-ID: <20161102194024.57f2d3c7@roar.ozlabs.ibm.com>
In-Reply-To: <20161102083351.bwl744znpacfkk52@black.fi.intel.com>
References: <20161102070346.12489-1-npiggin@gmail.com>
	<20161102070346.12489-3-npiggin@gmail.com>
	<20161102073156.GA13949@node.shutemov.name>
	<20161102185035.03f282c0@roar.ozlabs.ibm.com>
	<20161102075855.lt3323biol4cbfin@black.fi.intel.com>
	<20161102191248.5b1dd6cd@roar.ozlabs.ibm.com>
	<20161102083351.bwl744znpacfkk52@black.fi.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Hugh Dickins <hughd@google.com>

On Wed, 2 Nov 2016 11:33:51 +0300
"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> wrote:
> On Wed, Nov 02, 2016 at 07:12:48PM +1100, Nicholas Piggin wrote:
> > On Wed, 2 Nov 2016 10:58:55 +0300
> > "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> wrote:
> > 
> > Oh my mistake, that should be something like PF_ONLY_HEAD, where
> > 
> > #define PF_ONLY_HEAD(page, enforce) ({                                    \
> >                 VM_BUG_ON_PGFLAGS(PageTail(page), page);                  \
> >                 page; })  
> 
> Feel free to rename PF_NO_TAIL :)
> 

I think we don't need tests on non-head pages, so it's slightly different.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
