Date: Mon, 24 Jan 2000 14:21:36 +0100 (CET)
From: Ingo Oeser <ingo.oeser@informatik.tu-chemnitz.de>
Subject: GFP_XXX semantics (was: Re: [PATCH] 2.2.1{3,4,5} VM fix)
In-Reply-To: <Pine.LNX.4.21.0001221445150.440-100000@alpha.random>
Message-ID: <Pine.LNX.4.10.10001241411310.24852-100000@nightmaster.csn.tu-chemnitz.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Rik van Riel <riel@nl.linux.org>, Linux Kernel <linux-kernel@vger.rutgers.edu>, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Sat, 22 Jan 2000, Andrea Arcangeli wrote:

[GFP-Mask semantics discussion]

ok, once we are about it here, could you please explain the
_exact_ semantics for the GFP_XXX constants?

GFP_BUFFER
GFP_ATOMIC
GFP_BIGUSER
GFP_USER
GFP_KERNEL
GFP_NFS
GFP_KSWAPD

So which steps are tried to allocate these pages (freeing
process, freeing globally, waiting, failing, kswapd-wakeup)? 

Because it is not easy to decide from a driver writers point of
view, which one to use for which requests :(

Thanks and Regards

Ingo Oeser
-- 
Feel the power of the penguin - run linux@your.pc
<esc>:x

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
