Date: Mon, 19 Jun 2000 20:06:07 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [PATCH] -ac21 don't set referenced bit
In-Reply-To: <Pine.LNX.4.21.0006191450100.13200-100000@duckman.distro.conectiva>
Message-ID: <Pine.LNX.4.21.0006192001010.497-100000@inspiron.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org, los@lsdb.bwl.uni-mannheim.de
List-ID: <linux-mm.kvack.org>

On Mon, 19 Jun 2000, Rik van Riel wrote:

>My approach is a bit simpler. Since we *always* want to clear
>the bit when we put the page in the LRU list, we can simply
>remove that piece of code duplication from elsewhere in the
>code.

I do the clear of the bit in __add_to_page_cache at zero cost. You do it
with a cost inside lru_cache_add. That's the only difference between the
two approchs.

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
