Received: from burns.conectiva (burns.conectiva [10.0.0.4])
	by perninha.conectiva.com.br (Postfix) with SMTP id 8D4ED16B5E
	for <linux-mm@kvack.org>; Wed, 16 May 2001 20:00:03 -0300 (EST)
Date: Wed, 16 May 2001 19:59:55 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: inode/dentry pressure
Message-ID: <Pine.LNX.4.33.0105161953170.5251-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ben LaHaise <bcrl@redhat.com>
Cc: linux-mm@kvack.org, Alexander Viro <viro@math.psu.edu>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

Hi,

since the inode and dentry cache memory usage and the way this
memory is reaped by kswapd are still very fragile and these
caches often eat as much as 50% of system memory on normal
desktop systems I think we need to come up with a real solution
to this problem.

A quick fix would be to always try and reap inode and dentry
cache memory whenever these two eat over 10% of memory and let
the normal VM path eat from them when they're consuming less,
but since this could break in other situations I'm asking here
if anybody else has a real solution...

If we cannot find an easy to implement Real Solution(tm) we
should probably go for the 10% limit in 2.4 and implement the
real solution in 2.5; if anybody has a 2.4-attainable idea
I'd like to hear about it ;)

regards,

Rik
--
Linux MM bugzilla: http://linux-mm.org/bugzilla.shtml

Virtual memory is like a game you can't win;
However, without VM there's truly nothing to lose...

		http://www.surriel.com/
http://www.conectiva.com/	http://distro.conectiva.com/


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
