Date: Sat, 13 Jan 2001 01:28:38 -0200 (BRST)
From: Marcelo Tosatti <marcelo@conectiva.com.br>
Subject: swapout selection change in pre1
Message-ID: <Pine.LNX.4.21.0101130122440.11154-100000@freak.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Linus,

The swapout selection change in pre1 will make the kernel swapout behavior
not fair anymore to tasks which are sharing the VM (vfork()).

I dont see any clean fix for that problem. Do you? 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
