Date: Mon, 20 Jan 2003 19:34:46 -0200 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: 2.4.20-rmap15b does not build on sparc
In-Reply-To: <200301181559.53654.brendy33@attbi.com>
Message-ID: <Pine.LNX.4.50L.0301201933360.18171-100000@imladris.surriel.com>
References: <200301181559.53654.brendy33@attbi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Brendon and Wendy <brendy33@attbi.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 18 Jan 2003, Brendon and Wendy wrote:

> Just a quick compilation failure report on the sparc64 architecture. rmap15a
> builds & works just fine.

Looks like the pte-highmem stuff is breaking the other
architectures.

> In file included from /usr/src/linux-2.4.20/include/linux/slab.h:14,
>                  from /usr/src/linux-2.4.20/include/linux/proc_fs.h:5,
>                  from init/main.c:15:
> /usr/src/linux-2.4.20/include/linux/mm.h:188: parse error before `pte_addr_t'
> /usr/src/linux-2.4.20/include/linux/mm.h:188: warning: no semicolon at end of
> struct or union

Rik
-- 
Bravely reimplemented by the knights who say "NIH".
http://www.surriel.com/		http://guru.conectiva.com/
Current spamtrap:  <a href=mailto:"october@surriel.com">october@surriel.com</a>
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
