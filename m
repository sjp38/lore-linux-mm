Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 429696B0099
	for <linux-mm@kvack.org>; Tue, 17 Feb 2009 11:28:32 -0500 (EST)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id D485382C2D7
	for <linux-mm@kvack.org>; Tue, 17 Feb 2009 11:32:25 -0500 (EST)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id HIaDs2tjs3rk for <linux-mm@kvack.org>;
	Tue, 17 Feb 2009 11:32:25 -0500 (EST)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 195F282C4D1
	for <linux-mm@kvack.org>; Tue, 17 Feb 2009 11:31:54 -0500 (EST)
Date: Tue, 17 Feb 2009 11:20:40 -0500 (EST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [patch] SLQB slab allocator (try 2)
In-Reply-To: <4999BBE6.2080003@cs.helsinki.fi>
Message-ID: <alpine.DEB.1.10.0902171120040.27813@qirst.com>
References: <20090123154653.GA14517@wotan.suse.de> <200902041748.41801.nickpiggin@yahoo.com.au> <20090204152709.GA4799@csn.ul.ie> <200902051459.30064.nickpiggin@yahoo.com.au> <20090216184200.GA31264@csn.ul.ie> <4999BBE6.2080003@cs.helsinki.fi>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Mel Gorman <mel@csn.ul.ie>, Nick Piggin <nickpiggin@yahoo.com.au>, Nick Piggin <npiggin@suse.de>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Lin Ming <ming.m.lin@intel.com>, "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
List-ID: <linux-mm.kvack.org>

On Mon, 16 Feb 2009, Pekka Enberg wrote:

> Btw, Yanmin, do you have access to the tests Mel is running (especially the
> ones where slub-rvrt seems to do worse)? Can you see this kind of regression?
> The results make we wonder whether we should avoid reverting all of the page
> allocator pass-through and just add a kmalloc cache for 8K allocations. Or not
> address the netperf regression at all. Double-hmm.


Going to 8k for the limit beyond we pass through to the page allocator may
be the simplest and best solution. Someone please work on the page
allocator...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
