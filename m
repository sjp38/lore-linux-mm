Date: Sat, 6 Nov 2004 09:47:56 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [PATCH] Remove OOM killer from try_to_free_pages /
    all_unreclaimable braindamage
In-Reply-To: <20041106015051.GU8229@dualathlon.random>
Message-ID: <Pine.LNX.4.44.0411060944150.2721-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@novell.com>
Cc: Nick Piggin <piggin@cyberone.com.au>, Jesse Barnes <jbarnes@sgi.com>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>, Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 6 Nov 2004, Andrea Arcangeli wrote:
> 
> all allocations should have a failure path to avoid deadlocks. But in
> the meantime __GFP_REPEAT is at least localizing the problematic places ;)

Problematic, yes: don't overlook that GFP_REPEAT and GFP_NOFAIL _can_
fail, returning NULL: when the process is being OOM-killed (PF_MEMDIE).

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
