Date: Mon, 19 Jun 2000 11:02:22 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH] ramfs fixes
In-Reply-To: <20000619182802.B22551@tweedle.linuxcare.com.au>
Message-ID: <Pine.LNX.4.21.0006191059080.13200-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Gibson <dgibson@linuxcare.com>
Cc: linux-fsdevel@vger.rutgers.edu, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 19 Jun 2000, David Gibson wrote:

> The PG_dirty bit is cleared in add_to_swap_cache() and
> __add_to_page_cache() so this is kind of redundant, but the
> detach_page hook is good news in general.

Oww, good that you alert me to this bug. It makes no sense to
clear the bit there since we may have dirty pages in both the
filecache and the swapcache...

(well, it doesn't cause any bugs, but it could add some nasty
surprises later when we change the code so we can have dirty
pages in all the caches)

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
