Date: Wed, 15 Aug 2001 18:41:03 -0400 (EDT)
From: Ben LaHaise <bcrl@redhat.com>
Subject: [PATCH] mmap tail merging
In-Reply-To: <Pine.LNX.4.33.0108151539240.28240-100000@touchme.toronto.redhat.com>
Message-ID: <Pine.LNX.4.33.0108151837050.12167-100000@touchme.toronto.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: alan@redhat.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hello,

Here's a patch to mmap.c that performs tail merging on mmap.  In testing,
ld tends to hit it a few times during linking, and mozilla hit it a couple
of dozen times.  This probably comes from larger blocks of memory that
were malloc'd and later free'd with the following memory segment still in
use.  Alas, that doesn't solve all of the excess vma's in mozilla.

		-ben

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
