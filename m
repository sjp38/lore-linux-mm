Date: Mon, 29 May 2006 21:20:59 -0700 (PDT)
From: Linus Torvalds <torvalds@osdl.org>
Subject: Re: [rfc][patch] remove racy sync_page?
In-Reply-To: <447BB3FD.1070707@yahoo.com.au>
Message-ID: <Pine.LNX.4.64.0605292117310.5623@g5.osdl.org>
References: <447AC011.8050708@yahoo.com.au> <20060529121556.349863b8.akpm@osdl.org>
 <447B8CE6.5000208@yahoo.com.au> <20060529183201.0e8173bc.akpm@osdl.org>
 <447BB3FD.1070707@yahoo.com.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mason@suse.com, andrea@suse.de, hugh@veritas.com, axboe@suse.de
List-ID: <linux-mm.kvack.org>


On Tue, 30 May 2006, Nick Piggin wrote:
> 
> I guess so. Is plugging still needed now that the IO layer should
> get larger requests?

Why do you think the IO layer should get larger requests?

I really don't understand why people dislike plugging. It's obviously 
superior to non-plugged variants, exactly because it starts the IO only 
when _needed_, not at some random "IO request feeding point" boundary.

In other words, plugging works _correctly_ regardless of any random 
up-stream patterns. That's the kind of algorithms we want, we do NOT want 
to have the IO layer depend on upstream always doing the "Right 
Thing(tm)".

So exactly why would you want to remove it?

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
