Date: Mon, 1 May 2000 22:28:51 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Reply-To: riel@nl.linux.org
Subject: Re: [PATCH] pre7-1 semicolon & nicely readableB
In-Reply-To: <Pine.SOL.3.96.1000501190034.4093K-100000@sexsmith.cs.ualberta.ca>
Message-ID: <Pine.LNX.4.21.0005012222540.7508-100000@duckman.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Roel van der Goot <roel@cs.ualberta.ca>
Cc: linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

On Mon, 1 May 2000, Roel van der Goot wrote:

> I want to inform you that there is a subtle difference between
> the following two loops:
> 
> (i)
> 
>    while ((mm->swap_cnt << 2 * (i + 1) < max_cnt)
>                    && i++ < 10);
> 
> (ii)
> 
>    while ((mm->swap_cnt << 2 * (i + 1) < max_cnt)
>                    && i < 10)
>            i++;

I want to inform you that you're wrong. The only difference is
in readability.

If the first test fails, the clause behind the && won't be run.

Furthermore, i will only reach 10 if the RSS difference between
the current process and the biggest process is more than a factor
2^21 ... which can never happen on 32-bit hardware, unless the
RSS of the current process is 0.

In fact, the <10 test is only there to prevent infinite looping
for when a process with 0 swap_cnt "slips through" the tests above.

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
