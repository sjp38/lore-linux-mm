Date: Tue, 15 May 2007 23:39:40 -0700 (PDT)
Message-Id: <20070515.233940.48528771.davem@davemloft.net>
Subject: Re: Slab allocators: Define common size limitations
From: David Miller <davem@davemloft.net>
In-Reply-To: <20070515233239.335bd4ed.akpm@linux-foundation.org>
References: <Pine.LNX.4.64.0705152313490.5832@schroedinger.engr.sgi.com>
	<20070515233239.335bd4ed.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: Andrew Morton <akpm@linux-foundation.org>
Date: Tue, 15 May 2007 23:32:39 -0700
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: clameter@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> rofl. Really we shouldn't put this into 2.6.22, but it turfs out so much
> crap that it's hard to justify holding it back.

If fixes sparc64 with SLAB for one thing.  I was going to put
LARGE_ALLOCS back into sparc64/Kconfig but this is just soooo
much better.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
