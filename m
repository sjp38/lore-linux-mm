Subject: Re: [PATCH] VM bugfix + rebalanced + code beauty
References: <Pine.LNX.4.21.0005311629160.30221-100000@duckman.distro.conectiva>
From: Christoph Rohland <cr@sap.com>
Date: 31 May 2000 22:58:08 +0200
In-Reply-To: Rik van Riel's message of "Wed, 31 May 2000 16:30:22 -0300 (BRST)"
Message-ID: <qwwg0qy309r.fsf@sap.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

Rik van Riel <riel@conectiva.com.br> writes:

> I'm testing stuff now, but seem unable to reproduce your
> observation. However, I *am* seeing high cpu usage by
> kswapd ;)

I do these tests regularly 8way/8GB and the latest kernel is
definitely a step back.

> I guess we really want to integrate the SHM swapout routine
> with shrink_mmap...

I would love to integrate the whole shm page handling into the page
cache.

Greetings
		Christoph
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
