Date: Wed, 14 Jul 1999 11:12:17 -0400 (EDT)
From: "Benjamin C.R. LaHaise" <blah@kvack.org>
Subject: vm_store patches
Message-ID: <Pine.LNX.3.96.990714110014.11342A-100000@mole.spellcast.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hello Eric (and all),

What's the state of your vm_store patches from the series you posted a
while back?  There are a couple of things I'd like to play with along
their lines: using vm_stores for ext2 metadata to make prefetching of
indirect blocks 'just happen' during truncate, rather than making it
explicite as would currently be the case.

		-ben

--
Hi!  I'm Signature Virus 99!  Copy me into your .signature and join the fun!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
