Date: Mon, 2 Oct 2000 11:20:30 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: TODO list for new VM  (oct 2000)
In-Reply-To: <Pine.LNX.4.21.0010021447430.22539-100000@duckman.distro.conectiva>
Message-ID: <Pine.LNX.4.10.10010021117540.828-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: linux-kernel@vger.redhat.com, linux-mm@kvack.org, Matthew Dillon <dillon@apollo.backplane.com>
List-ID: <linux-mm.kvack.org>

Why do you apparently ignore the fact that page-out write-back performance
is horribly crappy because it always starts out doing synchronous writes?

I pointed out previously in a private email that page_launder() must be
buggy as it stands now, you seem to have ignored that part (and the
test-program that shows 1MB/s writeout speeds due to it) completely.

The whole _point_ of the new VM was performance. Without that, the new VM
is pointless, and discussing TODO features is equally pointless.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
