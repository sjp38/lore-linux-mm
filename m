Date: Mon, 27 Jun 2005 00:46:24 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [rfc] lockless pagecache
Message-Id: <20050627004624.53f0415e.akpm@osdl.org>
In-Reply-To: <42BF9CD1.2030102@yahoo.com.au>
References: <42BF9CD1.2030102@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Nick Piggin <nickpiggin@yahoo.com.au> wrote:
>
> First I'll put up some numbers to get you interested - of a 64-way Altix
>  with 64 processes each read-faulting in their own 512MB part of a 32GB
>  file that is preloaded in pagecache (with the proper NUMA memory
>  allocation).

I bet you can get a 5x to 10x reduction in ->tree_lock traffic by doing
16-page faultahead.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
