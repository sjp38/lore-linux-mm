Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id AD0446B02A1
	for <linux-mm@kvack.org>; Wed,  2 Nov 2016 05:04:48 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id ro13so4867768pac.7
        for <linux-mm@kvack.org>; Wed, 02 Nov 2016 02:04:48 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id 13si1802168pfv.89.2016.11.02.02.04.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Nov 2016 02:04:47 -0700 (PDT)
Date: Wed, 2 Nov 2016 12:04:43 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCH 2/2] mm: add PageWaiters bit to indicate waitqueue should
 be checked
Message-ID: <20161102090443.xa5223fn3avimswa@black.fi.intel.com>
References: <20161102070346.12489-1-npiggin@gmail.com>
 <20161102070346.12489-3-npiggin@gmail.com>
 <20161102073156.GA13949@node.shutemov.name>
 <20161102185035.03f282c0@roar.ozlabs.ibm.com>
 <20161102075855.lt3323biol4cbfin@black.fi.intel.com>
 <20161102191248.5b1dd6cd@roar.ozlabs.ibm.com>
 <20161102083351.bwl744znpacfkk52@black.fi.intel.com>
 <20161102194024.57f2d3c7@roar.ozlabs.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161102194024.57f2d3c7@roar.ozlabs.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nicholas Piggin <npiggin@gmail.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Hugh Dickins <hughd@google.com>

On Wed, Nov 02, 2016 at 07:40:24PM +1100, Nicholas Piggin wrote:
> On Wed, 2 Nov 2016 11:33:51 +0300
> "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> wrote:
> > On Wed, Nov 02, 2016 at 07:12:48PM +1100, Nicholas Piggin wrote:
> > > On Wed, 2 Nov 2016 10:58:55 +0300
> > > "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> wrote:
> > > 
> > > Oh my mistake, that should be something like PF_ONLY_HEAD, where
> > > 
> > > #define PF_ONLY_HEAD(page, enforce) ({                                    \
> > >                 VM_BUG_ON_PGFLAGS(PageTail(page), page);                  \
> > >                 page; })  
> > 
> > Feel free to rename PF_NO_TAIL :)
> > 
> 
> I think we don't need tests on non-head pages, so it's slightly different.

Ah. Okay, fair enough.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
