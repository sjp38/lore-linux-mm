Received: from burns.conectiva (burns.conectiva [10.0.0.4])
	by perninha.conectiva.com.br (Postfix) with SMTP id C0A6C38CF1
	for <linux-mm@kvack.org>; Thu, 23 Aug 2001 15:55:50 -0300 (EST)
Date: Thu, 23 Aug 2001 15:55:39 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH NG] alloc_pages_limit & pages_min
In-Reply-To: <200108231849.f7NIns005651@maila.telia.com>
Message-ID: <Pine.LNX.4.33L.0108231554330.31410-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Roger Larsson <roger.larsson@norran.net>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 23 Aug 2001, Roger Larsson wrote:

> > Why did you introduce this piece of code?
> > What is it supposed to achieve ?
>
> A lighter alternative would be to reclaim just one extra page...
> Then it will move in the right direction but not more, quite
> nice actually!

Why ?

Or, to be more specific, why would we want to throw away
data from the cache all the way up to pages_min when we
know we're running a workload with allocations which can
eat directly from the cache ?

Rik
--
IA64: a worthy successor to the i860.

		http://www.surriel.com/
http://www.conectiva.com/	http://distro.conectiva.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
