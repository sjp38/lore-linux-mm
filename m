Date: Fri, 7 Apr 2000 08:29:23 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Reply-To: riel@nl.linux.org
Subject: Re: [patch] take 2 Re: PG_swap_entry bug in recent kernels
In-Reply-To: <Pine.LNX.4.21.0004071205300.737-100000@alpha.random>
Message-ID: <Pine.LNX.4.21.0004070826350.23401-100000@duckman.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Ben LaHaise <bcrl@redhat.com>, Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 7 Apr 2000, Andrea Arcangeli wrote:

>  			spin_unlock(&pagecache_lock);
>  			__delete_from_swap_cache(page);
> +			/* the page is local to us now */
> +			page->flags &= ~(1UL << PG_swap_entry);
>  			goto made_inode_progress;
>  		}	

Please use the clear_bit() macro for this, the code is
unreadable enough in its current state...

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
