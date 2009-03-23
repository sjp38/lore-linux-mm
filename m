Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id BAA426B009F
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 08:28:36 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 54EAA82CFCF
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 09:41:47 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id p1zG4KoJt+MU for <linux-mm@kvack.org>;
	Mon, 23 Mar 2009 09:41:41 -0400 (EDT)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 7A03682CFCE
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 09:41:35 -0400 (EDT)
Date: Mon, 23 Mar 2009 09:30:26 -0400 (EDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 00/25] Cleanup and optimise the page allocator V5
In-Reply-To: <20090323115213.GC6484@csn.ul.ie>
Message-ID: <alpine.DEB.1.10.0903230929440.7254@qirst.com>
References: <1237543392-11797-1-git-send-email-mel@csn.ul.ie> <alpine.DEB.1.10.0903201059240.3740@qirst.com> <20090320153723.GO24586@csn.ul.ie> <alpine.DEB.1.10.0903201205260.18010@qirst.com> <20090320162716.GP24586@csn.ul.ie> <alpine.DEB.1.10.0903201503040.11746@qirst.com>
 <20090323115213.GC6484@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Linux Memory Management List <linux-mm@kvack.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, 23 Mar 2009, Mel Gorman wrote:

> This came up again. There was some evidence when it was introduced that
> it worked and micro-benchmarks can show it to be of some use. It's
> not-obvious-enough that I'd be wary of deleting it.

Certainly there is some minimal benefit. But maybe that benefit will
vanish if you drop the doubly linked list?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
