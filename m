Date: Sun, 14 May 2000 13:28:54 +0200 (CEST)
From: Ingo Molnar <mingo@elte.hu>
Reply-To: mingo@elte.hu
Subject: Re: pre8: where has the anti-hog code gone?
In-Reply-To: <Pine.LNX.4.10.10005141245510.1494-100000@elte.hu>
Message-ID: <Pine.LNX.4.10.10005141319450.1494-100000@elte.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Rik van Riel <riel@conectiva.com.br>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

> i believe the reason for gfp-NULL failures is the following:
> do_try_to_free_pages() _does_ free pages, but we do the sync in the
> writeback case _after_ releasing a particular page. This means other
> processes can steal our freshly freed pages - rmqueue fails easily. So i'd
> suggest the following workaround:
> 
> 	if (try_to_free_pages() was succesful && final rmqueue() failed)
> 		goto repeat;

this seems to have done the trick here - no more NULL gfps. Any better
generic suggestion than the explicit 'page transport' path between freeing
and allocation points?

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
