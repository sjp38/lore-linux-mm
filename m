Date: Tue, 16 May 2000 16:21:03 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: [dirtypatch] quickhack to make pre8/9 behave
Message-ID: <Pine.LNX.4.21.0005161604100.32026-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Linus Torvalds <torvalds@transmeta.com>, "Stephen C. Tweedie" <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi,

with the quick&dirty patch below the system:
- gracefully (more or less) survives mmap002
- has good performance on mmap002

To me this patch shows that we really want to wait
for dirty page IO to finish before randomly evicting
the (wrong) clean pages and dying horribly.

This is a dirty hack which should be replaced by whichever
solution people thing should be implemented to have the
allocator waiting for dirty pages to be flushed out.

regards,

Rik
--
The Internet is not a network of computers. It is a network
of people. That is its real strength.

Wanna talk about the kernel?  irc.openprojects.net / #kernelnewbies
http://www.conectiva.com/		http://www.surriel.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
