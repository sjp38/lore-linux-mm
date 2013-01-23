Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id 821566B000C
	for <linux-mm@kvack.org>; Wed, 23 Jan 2013 16:56:14 -0500 (EST)
Date: Wed, 23 Jan 2013 13:56:12 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 5/6] mm: Fold page->_last_nid into page->flags where
 possible
Message-Id: <20130123135612.4b383fa7.akpm@linux-foundation.org>
In-Reply-To: <20130123142507.GI13304@suse.de>
References: <1358874762-19717-1-git-send-email-mgorman@suse.de>
	<1358874762-19717-6-git-send-email-mgorman@suse.de>
	<20130122144659.d512e05c.akpm@linux-foundation.org>
	<20130123142507.GI13304@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Ingo Molnar <mingo@kernel.org>, Simon Jeons <simon.jeons@gmail.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Hugh Dickins <hughd@google.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, 23 Jan 2013 14:25:07 +0000
Mel Gorman <mgorman@suse.de> wrote:

> On Tue, Jan 22, 2013 at 02:46:59PM -0800, Andrew Morton wrote:
> > 
> > reset_page_last_nid() is poorly named.  page_reset_last_nid() would be
> > better, and consistent.
> > 
> 
> Look at this closer, are you sure you want? Why is page_reset_last_nid()
> better or more consistent?

I was looking at this group:

static inline int page_xchg_last_nid(struct page *page, int nid)
static inline int page_last_nid(struct page *page)
static inline void reset_page_last_nid(struct page *page)

IMO the best naming for these would be page_nid_xchg_last(),
page_nid_last() and page_nid_reset_last().

> The getter functions for page-related fields start with page (page_count,
> page_mapcount etc.) but the setters begin with set (set_page_section,
> set_page_zone, set_page_links etc.). For mapcount, we also have
> reset_page_mapcount() so to me reset_page_last_nid() is already
> consistent.

But those schemes make no sense.

I don't see any benefit in being consistent with existing
inconsistency.  It's better to use good naming for new things and to
fix up the old things where practical.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
