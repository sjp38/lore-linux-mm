Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id CC43C6B004A
	for <linux-mm@kvack.org>; Mon, 26 Jan 2009 21:49:34 -0500 (EST)
Date: Mon, 26 Jan 2009 18:48:42 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] Avoid lost wakeups in lock_page_killable()
Message-Id: <20090126184842.e3443e45.akpm@linux-foundation.org>
In-Reply-To: <20090126184112.32eb4450.akpm@linux-foundation.org>
References: <1232116107.21473.14.camel@think.oraclecorp.com>
	<20090117124821.GA1859@cmpxchg.org>
	<20090117163236.GA2660@cmpxchg.org>
	<20090126184112.32eb4450.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>, Chris Mason <chris.mason@oracle.com>, linux-mm@kvack.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Matthew Wilcox <matthew@wil.cx>, "chuck.lever" <chuck.lever@oracle.com>, stable@kernel.org, Oleg Nesterov <oleg@redhat.com>
List-ID: <linux-mm.kvack.org>

On Mon, 26 Jan 2009 18:41:12 -0800 Andrew Morton <akpm@linux-foundation.org> wrote:

> >  EXPORT_SYMBOL(__wait_on_bit_lock);
> > 
> 
> So.. what's happening with this?

err, ignore.  The Subject: rewrite fooled me.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
