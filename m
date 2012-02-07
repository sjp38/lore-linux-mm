Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id 9974F6B13F0
	for <linux-mm@kvack.org>; Tue,  7 Feb 2012 11:27:59 -0500 (EST)
Date: Tue, 7 Feb 2012 10:27:56 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 02/15] mm: sl[au]b: Add knowledge of PFMEMALLOC reserve
 pages
In-Reply-To: <1328568978-17553-3-git-send-email-mgorman@suse.de>
Message-ID: <alpine.DEB.2.00.1202071025050.30652@router.home>
References: <1328568978-17553-1-git-send-email-mgorman@suse.de> <1328568978-17553-3-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Linux-Netdev <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>, Neil Brown <neilb@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>

On Mon, 6 Feb 2012, Mel Gorman wrote:

> Pages allocated from the reserve are returned with page->pfmemalloc
> set and it is up to the caller to determine how the page should be
> protected.  SLAB restricts access to any page with page->pfmemalloc set

pfmemalloc sounds like a page flag. If you would use one then the
preservation of the flag by copying it elsewhere may not be necessary and
the patches would be less invasive. Also you would not need to extend
and modify many of the structures.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
