Received: (from john@localhost)
	by boreas.southchinaseas (8.9.3/8.9.3) id CAA00831
	for <linux-mm@kvack.org>; Fri, 23 Jun 2000 02:09:14 +0100
Subject: Re: [PATCH] Re: latancy test of -ac22-riel
References: <Pine.LNX.4.21.0006221644310.1170-100000@duckman.distro.conectiva>
From: "John Fremlin" <vii@penguinpowered.com>
In-Reply-To: Rik van Riel's message of "Thu, 22 Jun 2000 16:47:50 -0300 (BRST)"
Date: 23 Jun 2000 02:09:13 +0100
Message-ID: <m2aegdqk3q.fsf@boreas.southchinaseas>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Rik van Riel <riel@conectiva.com.br> writes:

> You're confusing things here.

It wouldn't come as great shock to me :-)

But OTOH the patch does stop the annoying stalls so it must be doing
something right.

> If kswapd was too slow in freeing up memory, but there is
> still more memory available, then we should NOT kill a
> process but just stall the process until more memory is
> available.

Yes. What I was trying to get across was that we shouldn't waste a
timeslice trying to find pages to evict which are going to be read
back in next process switch (because most pages are impossible to swap
out).

[...]

Your solution (which is what they do in FreeBSD?) would be ideal, but
it wasn't in my kernel source (test1-ac22-riel).

[...]

-- 

	http://altern.org/vii
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
