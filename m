Date: Fri, 3 Aug 2001 20:38:49 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [RFC][DATA] re "ongoing vm suckage"
In-Reply-To: <Pine.LNX.4.33.0108032318330.14842-100000@touchme.toronto.redhat.com>
Message-ID: <Pine.LNX.4.33.0108032036120.15155-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ben LaHaise <bcrl@redhat.com>
Cc: Daniel Phillips <phillips@bonn-fries.net>, Rik van Riel <riel@conectiva.com.br>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 3 Aug 2001, Ben LaHaise wrote:
>
> No.  Here's the bug in the block layer that was causing the throttling not
> to work.  Leave the logic in, it has good reason -- think of batching of
> io, where you don't want to add just one page at a time.

I absolutely agree on the batching, but this has nothing to do with
batching. The batching code uses "batch_requests", and the fact that we
free the finished requests to another area.

The ll_rw_block() code really _is_ broken. As proven by the fact that it
doesn't even get invoced most of the time.. And the times it _does_ get
invoced is exactly when it shouldn't (guess what the biggest user of
"ll_rw_block()" tends to be? "bread()")

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
