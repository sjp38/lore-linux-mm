Received: from burns.conectiva (burns.conectiva [10.0.0.4])
	by perninha.conectiva.com.br (Postfix) with SMTP id DBDA738FF3
	for <linux-mm@kvack.org>; Mon,  8 Oct 2001 20:38:41 -0300 (EST)
Date: Mon, 8 Oct 2001 20:38:27 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: [CFT][PATCH *] faster cache reclaim
Message-ID: <Pine.LNX.4.33L.0110082032070.26495-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: kernelnewbies@nl.linux.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi,

after looking at some other things for a while, I made a patch to
get 2.4.10-ac* to correctly eat pages from the cache when it is
about pages belonging to files which aren't currently in use. This
should also give some of the benefits of use-once, but without the
flaw of not putting pressure on the working set when a streaming IO
load is going on.

It also reduces the distance between inactive_shortage and
inactive_plenty, so kswapd should spend much less time rolling
over pages from zones we're not interested in.

This patch is meant to fix the problems where heavy cache
activity flushes out pages from the working set, while still
allowing the cache to put some pressure on the working set.

I've only done a few tests with this patch, reports on how
different workloads are handled are very much welcome:

http://www.surriel.com/patches/2.4/2.4.10-ac9-eatcache

regards,

Rik
-- 
DMCA, SSSCA, W3C?  Who cares?  http://thefreeworld.net/  (volunteers needed)

http://www.surriel.com/		http://distro.conectiva.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
