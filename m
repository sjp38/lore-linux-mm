Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id C13516B005A
	for <linux-mm@kvack.org>; Thu, 23 Aug 2012 14:33:16 -0400 (EDT)
Date: Thu, 23 Aug 2012 14:33:14 -0400
From: Matthew Wilcox <willy@linux.intel.com>
Subject: Re: [RFC PATCH 2/2] mm: Batch page_check_references in
 shrink_page_list sharing the same i_mmap_mutex
Message-ID: <20120823183314.GD6960@linux.intel.com>
References: <1345251998.13492.235.camel@schen9-DESK>
 <1345480982.13492.239.camel@schen9-DESK>
 <20120821132129.GC6960@linux.intel.com>
 <1345596500.13492.264.camel@schen9-DESK>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1345596500.13492.264.camel@schen9-DESK>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andi Kleen <ak@linux.intel.com>, linux-mm@kvack.org, linux-kernel <linux-kernel@vger.kernel.org>, Alex Shi <alex.shi@intel.com>

On Tue, Aug 21, 2012 at 05:48:20PM -0700, Tim Chen wrote:
> Thanks to Matthew's suggestions on improving the patch. Here's the
> updated version.  It seems to be sane when I booted my machine up.  I
> will put it through more testing when I get a chance.

Looks good.

> +int __try_to_munlock(struct page *page)

Nit: I think this can be static.  There aren't any users of it other
than try_to_munlock() itself.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
