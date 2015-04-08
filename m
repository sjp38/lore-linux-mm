Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id AF1DA6B0032
	for <linux-mm@kvack.org>; Wed,  8 Apr 2015 05:45:48 -0400 (EDT)
Received: by pdea3 with SMTP id a3so109938253pde.3
        for <linux-mm@kvack.org>; Wed, 08 Apr 2015 02:45:48 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id a8si15409129pbu.153.2015.04.08.02.45.47
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Apr 2015 02:45:47 -0700 (PDT)
Date: Wed, 8 Apr 2015 11:45:25 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 2/5] mm: Refactor remap_pfn_range()
Message-ID: <20150408094525.GZ23123@twins.programming.kicks-ass.net>
References: <1428424299-13721-1-git-send-email-chris@chris-wilson.co.uk>
 <1428424299-13721-3-git-send-email-chris@chris-wilson.co.uk>
 <20150407132721.7dbeee3218b8f185794b4f37@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150407132721.7dbeee3218b8f185794b4f37@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Chris Wilson <chris@chris-wilson.co.uk>, Joonas Lahtinen <joonas.lahtinen@linux.intel.com>, intel-gfx@lists.freedesktop.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Cyrill Gorcunov <gorcunov@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org

On Tue, Apr 07, 2015 at 01:27:21PM -0700, Andrew Morton wrote:
> On Tue,  7 Apr 2015 17:31:36 +0100 Chris Wilson <chris@chris-wilson.co.uk> wrote:
> 
> > In preparation for exporting very similar functionality through another
> > interface, gut the current remap_pfn_range(). The motivating factor here
> > is to reuse the PGB/PUD/PMD/PTE walker, but allow back progation of
> > errors rather than BUG_ON.
> 
> I'm not on intel-gfx and for some reason these patches didn't show up on
> linux-mm.  I wanted to comment on "mutex: Export an interface to wrap a
> mutex lock" but
> http://lists.freedesktop.org/archives/intel-gfx/2015-April/064063.html
> doesn't tell me which mailing lists were cc'ed and I can't find that
> patch on linux-kernel.
> 
> Can you please do something to make this easier for us??
> 
> And please fully document all the mutex interfaces which you just
> added.

Also, please Cc locking people if you poke at mutexes..

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
