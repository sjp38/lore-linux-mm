Date: Tue, 20 Jun 2000 13:20:19 +1000
From: David Gibson <dgibson@linuxcare.com>
Subject: Re: [PATCH] ramfs fixes
Message-ID: <20000620132019.A28309@tweedle.linuxcare.com.au>
References: <20000619182802.B22551@tweedle.linuxcare.com.au> <Pine.LNX.4.21.0006191059080.13200-100000@duckman.distro.conectiva>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <Pine.LNX.4.21.0006191059080.13200-100000@duckman.distro.conectiva>; from riel@conectiva.com.br on Mon, Jun 19, 2000 at 11:02:22AM -0300
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: David Gibson <dgibson@linuxcare.com>, linux-fsdevel@vger.rutgers.edu, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 19, 2000 at 11:02:22AM -0300, Rik van Riel wrote:
> On Mon, 19 Jun 2000, David Gibson wrote:
> 
> > The PG_dirty bit is cleared in add_to_swap_cache() and
> > __add_to_page_cache() so this is kind of redundant, but the
> > detach_page hook is good news in general.
> 
> Oww, good that you alert me to this bug. It makes no sense to
> clear the bit there since we may have dirty pages in both the
> filecache and the swapcache...
> 
> (well, it doesn't cause any bugs, but it could add some nasty
> surprises later when we change the code so we can have dirty
> pages in all the caches)

This actually went in somewhat recently, in 2.3.99pre something (where
something is around 4 IIRC). This fixed a bug in ramfs, since
previously the dirty bit was never being cleared.

At the time ramfs was the *only* place using PG_dirty - it looked like
it was just a misleading name for something analagous to BH_protected.

Obviously that's not true any more. What does the PG_dirty bit mean
these days?

-- 
David Gibson, Technical Support Engineer, Linuxcare, Inc.
+61 2 6262 8990
dgibson@linuxcare.com, http://www.linuxcare.com/ 
Linuxcare. Support for the revolution.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
