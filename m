Received: from max.phys.uu.nl (max.phys.uu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id KAA25976
	for <linux-mm@kvack.org>; Thu, 25 Jun 1998 10:00:54 -0400
Received: from mirkwood.dummy.home (root@anx1p7.phys.uu.nl [131.211.33.96])
	by max.phys.uu.nl (8.8.7/8.8.7/hjm) with ESMTP id QAA19412
	for <linux-mm@kvack.org>; Thu, 25 Jun 1998 16:00:47 +0200 (MET DST)
Received: from localhost (riel@localhost) by mirkwood.dummy.home (8.9.0/8.8.3) with SMTP id PAA32116 for <linux-mm@kvack.org>; Thu, 25 Jun 1998 15:58:17 +0200
Date: Thu, 25 Jun 1998 15:58:12 +0200 (CEST)
From: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Subject: glibc and kernel update
Message-ID: <Pine.LNX.3.96.980625155639.31988C-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

I still haven't resolved the problems between glibc, the
2.1 kernel series and pppd :(

Now I got a new idea: Since most of the kernel interfaces
go through glibc, does this mean that I have to get the
glibc source and recompile the whole thing in order to get
working ppp with a 2.1 kernel?

Rik.
+-------------------------------------------------------------------+
| Linux memory management tour guide.        H.H.vanRiel@phys.uu.nl |
| Scouting Vries cubscout leader.      http://www.phys.uu.nl/~riel/ |
+-------------------------------------------------------------------+
