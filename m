Date: Sat, 29 Apr 2000 00:37:27 -0600 (MDT)
From: Roel van der Goot <roel@cs.ualberta.ca>
Subject: Re: [PATCH] 2.3.99-pre6 vm fix
Message-ID: <Pine.SOL.3.96.1000429002847.29350A-100000@sexsmith.cs.ualberta.ca>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@nl.linux.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.rutgers.edu, "Stephen C. Tweedie" <sct@redhat.com>, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

Hi Rik,

I think that the shift left loop in your code needs a semicolon
to keep similar semantics as before:

   while ((mm->swap_cnt << 2 * (i + 1) < max_cnt)
                   && i++ < 10)
           ;
          ^^^

Cheers,
Roel.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
