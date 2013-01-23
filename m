Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id D722E6B0008
	for <linux-mm@kvack.org>; Wed, 23 Jan 2013 09:25:06 -0500 (EST)
Date: Wed, 23 Jan 2013 14:25:07 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 5/6] mm: Fold page->_last_nid into page->flags where
 possible
Message-ID: <20130123142507.GI13304@suse.de>
References: <1358874762-19717-1-git-send-email-mgorman@suse.de>
 <1358874762-19717-6-git-send-email-mgorman@suse.de>
 <20130122144659.d512e05c.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20130122144659.d512e05c.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Ingo Molnar <mingo@kernel.org>, Simon Jeons <simon.jeons@gmail.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Hugh Dickins <hughd@google.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, Jan 22, 2013 at 02:46:59PM -0800, Andrew Morton wrote:
> 
> reset_page_last_nid() is poorly named.  page_reset_last_nid() would be
> better, and consistent.
> 

Look at this closer, are you sure you want? Why is page_reset_last_nid()
better or more consistent?

The getter functions for page-related fields start with page (page_count,
page_mapcount etc.) but the setters begin with set (set_page_section,
set_page_zone, set_page_links etc.). For mapcount, we also have
reset_page_mapcount() so to me reset_page_last_nid() is already
consistent.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
