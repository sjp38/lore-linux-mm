From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <199908062351.QAA42123@google.engr.sgi.com>
Subject: Re: [PATCH] Fix sys_mount not to free_page(0)
Date: Fri, 6 Aug 1999 16:51:53 -0700 (PDT)
In-Reply-To: <Pine.LNX.4.10.9908061618260.1889-100000@penguin.transmeta.com> from "Linus Torvalds" at Aug 6, 99 04:18:50 pm
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: alan@lxorguk.ukuu.org.uk, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

> 
> 
> 
> On Fri, 6 Aug 1999, Kanoj Sarcar wrote:
> > 
> > Could you please take this patch into the 2.2 and 2.3 streams? It
> > basically prevents sys_mount() from trying to invoke free_page(0).
> 
> Hmm..
> 
> free_page(0) is actually supposed to work. Doesn't it?
> 
> 		Linus
> 

Umm, it does ... I was thinking it was happenstance, and not by design.
I ran into a panic with some code I am trying to write and ran into 
this ... maybe I should fix my code ...

Is it worthwhile to clean this up, or do other places in the code rely
on this behavior of free_page?

Kanoj
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
