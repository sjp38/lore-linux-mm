Date: Sun, 5 Feb 2006 11:39:43 -0500 (EST)
From: Rik van Riel <riel@surriel.com>
Subject: Re: [VM PATCH] rotate_reclaimable_page fails frequently
In-Reply-To: <20060205150259.1549.qmail@web33007.mail.mud.yahoo.com>
Message-ID: <Pine.LNX.4.61L.0602051138260.26086@imladris.surriel.com>
References: <20060205150259.1549.qmail@web33007.mail.mud.yahoo.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; CHARSET=US-ASCII
Content-ID: 
Content-Disposition: INLINE
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Shantanu Goel <sgoel01@yahoo.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 5 Feb 2006, Shantanu Goel wrote:

> It seems rotate_reclaimable_page fails most of the
> time due the page not being on the LRU when kswapd
> calls writepage().

The question is, why is the page not yet back on the
LRU by the time the data write completes ?

Surely a disk IO is slow enough that the page will
have been put on the LRU milliseconds before the IO
completes ?

In what kind of configuration do you run into this
problem ?

-- 
"Debugging is twice as hard as writing the code in the first place.
Therefore, if you write the code as cleverly as possible, you are,
by definition, not smart enough to debug it." - Brian W. Kernighan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
