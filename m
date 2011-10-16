Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 7B0456B002C
	for <linux-mm@kvack.org>; Sun, 16 Oct 2011 04:28:51 -0400 (EDT)
Received: by pzd13 with SMTP id 13so5504623pzd.6
        for <linux-mm@kvack.org>; Sun, 16 Oct 2011 01:28:49 -0700 (PDT)
Date: Sun, 16 Oct 2011 01:31:16 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/9] mm: alloc_contig_freed_pages() added
Message-Id: <20111016013116.53032449.akpm@linux-foundation.org>
In-Reply-To: <op.v3fpwyxc3l0zgt@mpn-glaptop>
References: <1317909290-29832-1-git-send-email-m.szyprowski@samsung.com>
	<1317909290-29832-3-git-send-email-m.szyprowski@samsung.com>
	<20111014162933.d8fead58.akpm@linux-foundation.org>
	<op.v3fpwyxc3l0zgt@mpn-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Nazarewicz <mina86@mina86.com>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, Kyungmin Park <kyungmin.park@samsung.com>, Russell King <linux@arm.linux.org.uk>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Ankita Garg <ankita@in.ibm.com>, Daniel Walker <dwalker@codeaurora.org>, Mel Gorman <mel@csn.ul.ie>, Arnd Bergmann <arnd@arndb.de>, Jesse Barker <jesse.barker@linaro.org>, Jonathan Corbet <corbet@lwn.net>, Shariq Hasnain <shariq.hasnain@linaro.org>, Chunsang Jeong <chunsang.jeong@linaro.org>, Dave Hansen <dave@linux.vnet.ibm.com>

On Sun, 16 Oct 2011 10:01:36 +0200 "Michal Nazarewicz" <mina86@mina86.com> wrote:

> Still, as I think of it now, maybe alloc_contig_free_range() would be
> better?

Nope.  Of *course* the pages were free.  Otherwise we couldn't
(re)allocate them.  I still think the "free" part is redundant.

What could be improved is the "alloc" part.  This really isn't an
allocation operation.  The pages are being removed from buddy then
moved into the free arena of a different memory manager from where they
will _later_ be "allocated".

So we should move away from the alloc/free naming altogether for this
operation and think up new terms.  How about "claim" and "release"? 
claim_contig_pages, claim_contig_range, release_contig_pages, etc?
Or we could use take/return.

Also, if we have no expectation that anything apart from CMA will use
these interfaces (?), the names could/should be prefixed with "cma_".

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
