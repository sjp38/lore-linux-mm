Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 7D43D6B00C6
	for <linux-mm@kvack.org>; Mon, 16 Feb 2009 14:59:43 -0500 (EST)
Date: Mon, 16 Feb 2009 11:59:31 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 0/8] kzfree()
Message-Id: <20090216115931.12d9b7ed.akpm@linux-foundation.org>
In-Reply-To: <20090216142926.440561506@cmpxchg.org>
References: <20090216142926.440561506@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 16 Feb 2009 15:29:26 +0100 Johannes Weiner <hannes@cmpxchg.org> wrote:

> This series introduces kzfree() and converts callsites which do
> memset() + kfree() explicitely.

I dunno, this looks like putting lipstick on a pig.

What is the point in zeroing memory just before freeing it?  afacit
this is always done as a poor-man's poisoning operation.

But the slab allocators _already_ do poisoning, and they do it better. 
And they do it configurably, whereas those sites you've been looking at
are permanently slowing the kernel down.

So I would cheerily merge and push patches titled "remove pointless
memset before kfree".

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
