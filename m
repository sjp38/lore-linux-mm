Date: Tue, 19 Feb 2002 20:47:17 -0300 (BRT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: [PATCH] struct page, new bk tree
Message-ID: <Pine.LNX.4.33L.0202192044140.7820-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Larry McVoy <lm@bitmover.com>
List-ID: <linux-mm.kvack.org>

Hi Linus,

I've removed the old (broken) bitkeeper tree with the
struct page changes and have put a new one in the same
place ... with the struct page changes in one changeset
with ready checkin comment.

You can resync from bk://linuxvm.bkbits.net/linux-2.5-struct_page
and you'll see that the stupid etc/config change is no longer there.

If you want to wait a version with pulling this change because
of the pte_highmem changes by Ingo and Arjan I can understand
that and will just bug you again in a version or so ;)

kind regards,

Rik
-- 
"Linux holds advantages over the single-vendor commercial OS"
    -- Microsoft's "Competing with Linux" document

http://www.surriel.com/		http://distro.conectiva.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
