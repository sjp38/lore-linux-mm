Date: Thu, 4 May 2000 16:24:57 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Reply-To: riel@nl.linux.org
Subject: Re: classzone-VM + mapped pages out of lru_cache
In-Reply-To: <Pine.LNX.4.21.0005041952280.3416-100000@alpha.random>
Message-ID: <Pine.LNX.4.21.0005041624090.23740-100000@duckman.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: "Juan J. Quintela" <quintela@fi.udc.es>, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu, trond.myklebust@fys.uio.no
List-ID: <linux-mm.kvack.org>

On Thu, 4 May 2000, Andrea Arcangeli wrote:
> On Thu, 4 May 2000, Rik van Riel wrote:
> 
> >On Thu, 4 May 2000, Andrea Arcangeli wrote:
> >
> >> --- 2.2.15/mm/filemap.c	Thu May  4 13:00:40 2000
>        ^^^^^^
> You're obviously wrong:
> 
> 1) the other cpu on 2.2.15 were spinning on the big kernel lock

Ooops, sorry.

I had my mind wrapped around the 2.3 code so tight that
I looked at the Subject and the code only and didn't
spot the kernel version in the diff header ;)

cheers,

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
