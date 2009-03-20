Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id B5B0A6B004D
	for <linux-mm@kvack.org>; Fri, 20 Mar 2009 15:42:19 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 8E8D582C916
	for <linux-mm@kvack.org>; Fri, 20 Mar 2009 15:53:38 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id ULoxs9Xpa7PQ for <linux-mm@kvack.org>;
	Fri, 20 Mar 2009 15:53:32 -0400 (EDT)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 72DF882C922
	for <linux-mm@kvack.org>; Fri, 20 Mar 2009 15:53:32 -0400 (EDT)
Date: Fri, 20 Mar 2009 15:43:23 -0400 (EDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 00/25] Cleanup and optimise the page allocator V5
In-Reply-To: <20090320162716.GP24586@csn.ul.ie>
Message-ID: <alpine.DEB.1.10.0903201503040.11746@qirst.com>
References: <1237543392-11797-1-git-send-email-mel@csn.ul.ie> <alpine.DEB.1.10.0903201059240.3740@qirst.com> <20090320153723.GO24586@csn.ul.ie> <alpine.DEB.1.10.0903201205260.18010@qirst.com> <20090320162716.GP24586@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Linux Memory Management List <linux-mm@kvack.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Fri, 20 Mar 2009, Mel Gorman wrote:

> > Is it possible to go to a simple
> > linked list (one cacheline to be touched)?
>
> I considered it but it breaks the hot/cold allocation/freeing logic and
> the search code became weird enough looking fast enough that I dropped
> it.

Maybe it would be workable if we drop the cold queue stuff (dubious
anyways)?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
