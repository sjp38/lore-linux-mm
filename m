Date: Thu, 5 Apr 2001 11:46:58 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: Fwd: Re: [PATCH][RFC] appling preasure to icache and dcache
In-Reply-To: <01040507350800.00699@oscar>
Message-ID: <Pine.LNX.4.21.0104051145360.27736-100000@imladris.rielhome.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ed Tomlinson <tomlins@cam.org>
Cc: sfkaplan@cs.amherst.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 5 Apr 2001, Ed Tomlinson wrote:

> I am very aware that heavy paging, which is ok _if_ you have the
> bandwidth, and thrashing are different.

So can we conclude that for a simple "thrashing approximation"
we should at least measure if we're loading the disk subsystem
heavily ?

(heavy disk load -> more disk seeks -> self-perpetuating situation)

regards,

Rik
--
Virtual memory is like a game you can't win;
However, without VM there's truly nothing to lose...

		http://www.surriel.com/
http://www.conectiva.com/	http://distro.conectiva.com.br/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
