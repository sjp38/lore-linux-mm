Message-ID: <418CAD0C.3030109@cyberone.com.au>
Date: Sat, 06 Nov 2004 21:53:00 +1100
From: Nick Piggin <piggin@cyberone.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH] Remove OOM killer from try_to_free_pages /    all_unreclaimable
 braindamage
References: <Pine.LNX.4.44.0411060944150.2721-100000@localhost.localdomain>
In-Reply-To: <Pine.LNX.4.44.0411060944150.2721-100000@localhost.localdomain>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Andrea Arcangeli <andrea@novell.com>, Jesse Barnes <jbarnes@sgi.com>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>, Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


Hugh Dickins wrote:

>On Sat, 6 Nov 2004, Andrea Arcangeli wrote:
>
>>all allocations should have a failure path to avoid deadlocks. But in
>>the meantime __GFP_REPEAT is at least localizing the problematic places ;)
>>
>
>Problematic, yes: don't overlook that GFP_REPEAT and GFP_NOFAIL _can_
>fail, returning NULL: when the process is being OOM-killed (PF_MEMDIE).
>
>

Yeah right you are. I think NOFAIL is a bug and should really not fail.
It looks like it is only used in fs/jbd/*, and things will crash if it
fails. Maybe they're only called from the kjournald threads and can't
be OOM killed, but that is still a pretty subtle dependancy.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
