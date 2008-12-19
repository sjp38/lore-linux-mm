Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 4950B6B0044
	for <linux-mm@kvack.org>; Fri, 19 Dec 2008 02:34:14 -0500 (EST)
Date: Thu, 18 Dec 2008 23:35:49 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [rfc][patch] unlock_page speedup
Message-Id: <20081218233549.cb451bc8.akpm@linux-foundation.org>
In-Reply-To: <20081219072909.GC26419@wotan.suse.de>
References: <20081219072909.GC26419@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Fri, 19 Dec 2008 08:29:09 +0100 Nick Piggin <npiggin@suse.de> wrote:

> Introduce a new page flag, PG_waiters

Leaving how many?  fs-cache wants to take two more.

How's about we actually work this out, then make PG_waiters the
highest-numbered free one?

	PG_free1,
	PG_free2,
	...
	PG_waiters
};

(or even something really sensitive, like PG_lru)

So that

a) we can see how many are left in a robust fashion and

b) we find out whether PG_waiters (PG_lru?) gets scribbled on by architectures
   which borrow upper bits from page.flags for other nefarious purposes.

?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
