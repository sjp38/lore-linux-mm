Received: from burns.conectiva (burns.conectiva [10.0.0.4])
	by perninha.conectiva.com.br (Postfix) with SMTP id CC10E16B4A
	for <linux-mm@kvack.org>; Thu, 19 Apr 2001 14:51:22 -0300 (EST)
Date: Thu, 19 Apr 2001 14:51:22 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: Want to allocate almost all the memory with no swap
In-Reply-To: <Pine.LNX.4.21.0104191851180.10083-100000@guarani.imag.fr>
Message-ID: <Pine.LNX.4.33.0104191450290.17635-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Simon Derr <Simon.Derr@imag.fr>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 19 Apr 2001, Simon Derr wrote:

> Actually this is what happens under 2.4.2 :
> when I launch the program, during about one minute kswapd eats 50% cpu,
> and bdflush takes 2-5% cpu,
> One minute later approx, they both stop eating the cpu and my process gets
> almost 100% of the cpu (a PIII 733).
>
> The same happens if I kill and launch my program a second time.
>
> Sorry for the pollution I bring to your mailing list...

No. Thanks for telling us.  It is good to know that kswapd
exhibits this strange behaviour. It's admiteddly not a high
priority thing to fix, but it IS something to keep in mind.

thanks,

Rik
--
Linux MM bugzilla: http://linux-mm.org/bugzilla.shtml

Virtual memory is like a game you can't win;
However, without VM there's truly nothing to lose...

		http://www.surriel.com/
http://www.conectiva.com/	http://distro.conectiva.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
