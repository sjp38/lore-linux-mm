Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 632AE6B003D
	for <linux-mm@kvack.org>; Wed,  4 Feb 2009 15:14:33 -0500 (EST)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 3FA5E82C522
	for <linux-mm@kvack.org>; Wed,  4 Feb 2009 15:17:06 -0500 (EST)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id CNOuWPwKbOvR for <linux-mm@kvack.org>;
	Wed,  4 Feb 2009 15:17:06 -0500 (EST)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 4688982C523
	for <linux-mm@kvack.org>; Wed,  4 Feb 2009 15:17:00 -0500 (EST)
Date: Wed, 4 Feb 2009 15:09:15 -0500 (EST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [patch] SLQB slab allocator
In-Reply-To: <200902041522.01307.nickpiggin@yahoo.com.au>
Message-ID: <alpine.DEB.1.10.0902041507050.8154@qirst.com>
References: <20090114155923.GC1616@wotan.suse.de> <84144f020902031042i31eaec14v53a0e7a203acd28b@mail.gmail.com> <84144f020902031047o2e117652w28886efb495688c4@mail.gmail.com> <200902041522.01307.nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Nick Piggin <npiggin@suse.de>, "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>, Lin Ming <ming.m.lin@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, 4 Feb 2009, Nick Piggin wrote:

> That's very true, and we touched on this earlier. It is I guess
> you can say a downside of queueing. But an analogous situation
> in SLUB would be that lots of pages on the partial list with
> very few free objects, or freeing objects to pages with few
> objects in them. Basically SLUB will have to do the extra work
> in the fastpath.

But these are pages with mostly allocated objects and just a few objects
free. The SLAB case is far worse: You have N objects on a queue and they
are keeping possibly N pages away from the page allocator and in those
pages *nothing* is used.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
