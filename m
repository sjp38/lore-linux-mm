Date: Mon, 2 Jul 2001 16:02:42 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: Can reverse VM locks?
In-Reply-To: <Pine.LNX.4.33.0107021917250.9756-100000@alloc.wat.veritas.com>
Message-ID: <Pine.LNX.4.33L.0107021601240.14332-100000@imladris.rielhome.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: markhe@veritas.com
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 2 Jul 2001 markhe@veritas.com wrote:

>   Anyone know of any places where reversing the lock ordering would break?

Basically add_to_page_cache and remove_from_page cache and friends ;)

Rik
--
Virtual memory is like a game you can't win;
However, without VM there's truly nothing to lose...

http://www.surriel.com/		http://distro.conectiva.com/

Send all your spam to aardvark@nl.linux.org (spam digging piggy)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
