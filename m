Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 623186B003D
	for <linux-mm@kvack.org>; Wed,  4 Feb 2009 15:15:33 -0500 (EST)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 4910282C4EA
	for <linux-mm@kvack.org>; Wed,  4 Feb 2009 15:18:08 -0500 (EST)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id Kxl78KfbaWyZ for <linux-mm@kvack.org>;
	Wed,  4 Feb 2009 15:18:08 -0500 (EST)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id BB32882C4EB
	for <linux-mm@kvack.org>; Wed,  4 Feb 2009 15:18:00 -0500 (EST)
Date: Wed, 4 Feb 2009 15:10:31 -0500 (EST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [patch] SLQB slab allocator
In-Reply-To: <84144f020902031042i31eaec14v53a0e7a203acd28b@mail.gmail.com>
Message-ID: <alpine.DEB.1.10.0902041509320.8154@qirst.com>
References: <20090114155923.GC1616@wotan.suse.de>  <20090123155307.GB14517@wotan.suse.de>  <alpine.DEB.1.10.0901261225240.1908@qirst.com>  <200902031253.28078.nickpiggin@yahoo.com.au>  <alpine.DEB.1.10.0902031217390.17910@qirst.com>
 <84144f020902031042i31eaec14v53a0e7a203acd28b@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Nick Piggin <npiggin@suse.de>, "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>, Lin Ming <ming.m.lin@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, 3 Feb 2009, Pekka Enberg wrote:

> Well, the slab_hiwater() check in __slab_free() of mm/slqb.c will cap
> the size of the queue. But we do the same thing in SLAB with
> alien->limit in cache_free_alien() and ac->limit in __cache_free(). So
> I'm not sure what you mean when you say that the queues will "grow
> unconstrained" (in either of the allocators). Hmm?

Nick said he wanted to defer queue processing. If the water marks are
checked and queue processing run then of course queue processing is not
deferred and the queue does not build up further.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
