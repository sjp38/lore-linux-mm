Date: Mon, 23 Jul 2001 00:08:56 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: Large PAGE_SIZE
In-Reply-To: <Pine.LNX.4.21.0107181940400.1080-100000@localhost.localdomain>
Message-ID: <Pine.LNX.4.21.0107222359240.1121-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Ben LaHaise <bcrl@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Large i386 PAGE_SIZE patch is now updated to 2.4.7:

ftp://ftp.veritas.com/linux/larpage-2.4.7.patch.bz2

To try these large pages, edit include/asm-i386/page.h
PAGE_MMUSHIFT from 0 to 1 or 2 or 3: no configuration yet.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
