Date: Sun, 14 May 2000 14:12:53 +0200 (CEST)
From: Ingo Molnar <mingo@elte.hu>
Reply-To: mingo@elte.hu
Subject: Re: pre8: where has the anti-hog code gone?
In-Reply-To: <Pine.LNX.4.21.0005140855260.16064-100000@duckman.distro.conectiva>
Message-ID: <Pine.LNX.4.10.10005141410190.2201-100000@elte.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Linus Torvalds <torvalds@transmeta.com>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

On Sun, 14 May 2000, Rik van Riel wrote:

> Mark the zone as a "steal-before-allocate" zone while
> one user process is in the page stealer because it
> could not find an easy page.

this i believe is fundamentally single-threaded (and now with the latest
Linus VM we have massively parallel allocation points). The problem is not
to notice low memory situations (we already have the low_on_memory flag),
the problem is to un-anonymize resulting free pages. Anonym freeing ==
unfairness, which unfairness ultimately leads to NULL gfp and bad
allocation latency.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
