Message-ID: <3D4D87CE.25198C28@zip.com.au>
Date: Sun, 04 Aug 2002 13:00:14 -0700
From: Andrew Morton <akpm@zip.com.au>
MIME-Version: 1.0
Subject: Re: how not to write a search algorithm
References: <3D4CE74A.A827C9BC@zip.com.au> <Pine.LNX.4.44L.0208041015350.23404-100000@imladris.surriel.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Rik van Riel wrote:
> 
> ...
> > Alan's kernel has a nice-looking implementation.  I'll lift that out
> > next week unless someone beats me to it.
> 
> Good to hear that you found this one ;)

The same test panics Alan's kernel with pte_chain oom, so I can't
check whether/how well it fixes it :(

2.5 is no better off wrt pte_chain oom, and I expect it'll oops
with this test when per-zone-LRUs are implemented.

Is there a proposed way of recovering from pte_chain oom?
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
