Date: Sat, 29 Apr 2000 06:55:28 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Reply-To: riel@nl.linux.org
Subject: Re: [PATCH] 2.3.99-pre6 vm fix
In-Reply-To: <Pine.SOL.3.96.1000429002847.29350A-100000@sexsmith.cs.ualberta.ca>
Message-ID: <Pine.LNX.4.21.0004290654390.23622-100000@duckman.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Roel van der Goot <roel@cs.ualberta.ca>
Cc: linux-mm@kvack.org, linux-kernel@vger.rutgers.edu, "Stephen C. Tweedie" <sct@redhat.com>, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

On Sat, 29 Apr 2000, Roel van der Goot wrote:

> I think that the shift left loop in your code needs a semicolon
> to keep similar semantics as before:
> 
>    while ((mm->swap_cnt << 2 * (i + 1) < max_cnt)
>                    && i++ < 10)
>            ;
>           ^^^

Indeed, you're right. Thanks for pointing this out; a small
incremental patch has been sent.

regards,

Rik
--
The Internet is not a network of computers. It is a network
of people. That is its real strength.

Wanna talk about the kernel?  irc.openprojects.net / #kernelnewbies
http://www.conectiva.com/		http://www.surriel.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
