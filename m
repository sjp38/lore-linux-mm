Received: from imperial.edgeglobal.com (imperial.edgeglobal.com [208.197.226.14])
	by edgeglobal.com (8.9.1/8.9.1) with ESMTP id KAA20327
	for <linux-mm@kvack.org>; Sun, 29 Aug 1999 10:48:47 -0400
Date: Sun, 29 Aug 1999 10:52:29 -0400 (EDT)
From: James Simmons <jsimmons@edgeglobal.com>
Subject: accel handling
Message-ID: <Pine.LNX.4.10.9908291037120.28136-100000@imperial.edgeglobal.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi!

 My name is James Simmons and I'm one of the new core designers for the
framebuffer devices for linux. Well I have redesigned the framebuffer
system and now it takes advantages of accels. Now the problem is that alot
of cards can't have simulanteous access to the framebuffer and the accel
engine. What I need to a way to put any process to sleep when they access
the framebuffer while the accel engine is active. This is for both read
and write access. Then once the accel engine is idle wake up the process.
MM is beyond me. Trust me I tried to find a solution. Anyone have a idea
what needs to be done? Thank you.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
