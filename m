Received: from burns.conectiva (burns.conectiva [10.0.0.4])
	by perninha.conectiva.com.br (Postfix) with SMTP id 92EBB38C12
	for <linux-mm@kvack.org>; Mon, 26 Nov 2001 18:49:36 -0300 (EST)
Date: Mon, 26 Nov 2001 19:49:22 -0200 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: [PATCH *] VM for 2.4.16
Message-ID: <Pine.LNX.4.33L.0111261943370.1491-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: kernelnewbies@nl.linux.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

here's a patch which forward-ports my VM to 2.4.16,
integrating the good stuff like blkdev-in-pagecache,
rbtree, smoother zone fallback, etc...

My 64 MB test box seems to be pretty happy doing a
'make -j bzImage' over NFS, so I suspect it's quite
stable now. Please give it a beating.

http://www.surriel.com/patches/2.4/2.4.16-vm

I'll look into making my bitkeeper tree available for
general pulling so everybody can see the detailed
changelog of each file, instead of just the comments
in the patches.

cheers,

Rik
-- 
DMCA, SSSCA, W3C?  Who cares?  http://thefreeworld.net/

http://www.surriel.com/		http://distro.conectiva.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
