Subject: Re: [patch] vmfixes-2.4.0-test9-B2 - fixing deadlocks
References: <Pine.LNX.4.21.0009281704430.9445-100000@elte.hu>
From: "Juan J. Quintela" <quintela@fi.udc.es>
In-Reply-To: Ingo Molnar's message of "Thu, 28 Sep 2000 17:13:59 +0200 (CEST)"
Date: 28 Sep 2000 18:16:03 +0200
Message-ID: <yttsnqkfq64.fsf@serpe.mitica>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: mingo@elte.hu
Cc: Andrea Arcangeli <andrea@suse.de>, Rik van Riel <riel@conectiva.com.br>, Christoph Rohland <cr@sap.com>, "Stephen C. Tweedie" <sct@redhat.com>, Linus Torvalds <torvalds@transmeta.com>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

>>>>> "ingo" == Ingo Molnar <mingo@elte.hu> writes:

Hi

ingo> 2) introducing sys_flush(), which flushes pages from the pagecache.

It is not supposed that mincore can do that (yes, just now it is not
implemented, but the interface is there to do that)?

Just curious.

-- 
In theory, practice and theory are the same, but in practice they 
are different -- Larry McVoy
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
