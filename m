Date: Fri, 6 Aug 1999 17:00:58 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [PATCH] Fix sys_mount not to free_page(0)
In-Reply-To: <199908062351.QAA42123@google.engr.sgi.com>
Message-ID: <Pine.LNX.4.10.9908061658390.1889-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Cc: alan@lxorguk.ukuu.org.uk, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>


On Fri, 6 Aug 1999, Kanoj Sarcar wrote:
> > 
> > free_page(0) is actually supposed to work. Doesn't it?
> 
> Umm, it does ... I was thinking it was happenstance, and not by design.

It's by design - I am of the religion that thinks that

	free(malloc());

is always legal, even when the malloc() fails.

> Is it worthwhile to clean this up, or do other places in the code rely
> on this behavior of free_page?

There might be any number of places who just free a page, it doesn't even
slow down free_page(), because the 0 case just falls out quite naturally
from having to test for out-of-range and reserved pages anyway.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
