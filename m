Subject: Re: [PATCH] VM bugfix + rebalanced + code beauty
References: <Pine.LNX.4.21.0005311817190.30221-100000@duckman.distro.conectiva>
From: Christoph Rohland <cr@sap.com>
Date: 01 Jun 2000 19:18:05 +0200
In-Reply-To: Rik van Riel's message of "Wed, 31 May 2000 18:19:55 -0300 (BRST)"
Message-ID: <qwwu2fd1fsi.fsf@sap.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

Rik van Riel <riel@conectiva.com.br> writes:

> > I would love to integrate the whole shm page handling into the
> > page cache.
> 
> That would be great. If we have this we can weigh page cache,
> swap cache and shm pages equally. Not only will this result in
> better page replacement, but it will also save on kswapd cpu
> usage.
> 
> Even better, having this will allow us to (trivially) insert
> the active/inactive queue idea into the kernel, fixing the
> "write stall" problems for a lot of situations.

And it will make shm trivial with respect to page handling. We will be
able to make the shm fs a real in memory fs which would be used
occasionally by SYSV shm.

Greetings
		Christoph
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
