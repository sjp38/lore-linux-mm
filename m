Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 3EEB76B004D
	for <linux-mm@kvack.org>; Wed, 10 Jun 2009 15:01:06 -0400 (EDT)
Date: Wed, 10 Jun 2009 11:59:29 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH 3/3] vmalloc: use kzalloc() instead of alloc_bootmem()
In-Reply-To: <Pine.LNX.4.64.0906102058060.28361@melkki.cs.Helsinki.FI>
Message-ID: <alpine.LFD.2.01.0906101158440.6847@localhost.localdomain>
References: <Pine.LNX.4.64.0906102058060.28361@melkki.cs.Helsinki.FI>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Pekka J Enberg <penberg@cs.helsinki.fi>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, cl@linux-foundation.com, mingo@elte.hu, hannes@cmpxchg.org, mpm@selenic.com, npiggin@suse.de, yinghai@kernel.org
List-ID: <linux-mm.kvack.org>



ACK on the whole series. Feel free to push it to me asap, so that we can 
get any potential issues found and sorted out early.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
