Date: Wed, 10 May 2000 11:21:06 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: A possible winner in pre7-8
In-Reply-To: <Pine.LNX.4.21.0005101509260.6894-100000@duckman.conectiva>
Message-ID: <Pine.LNX.4.10.10005101119420.820-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: "Juan J. Quintela" <quintela@fi.udc.es>, Rajagopal Ananthanarayanan <ananth@sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Wed, 10 May 2000, Rik van Riel wrote:
> 
> I'm sorry to dissapoint you, but I'm afraid this isn't
> the bug. Please look at this code from vmscan.c...

Oh, I overlooked that. And I'm definitely not disappointed: that would
have been a brown-paper-bag bug indeed.

I started trying mmap002 again, and can easily reproduce the failures, and
also see the performance problems. I think I've fixed the performance
issue, now I just need to fix the failure ;)

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
