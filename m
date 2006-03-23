Date: Thu, 23 Mar 2006 20:51:20 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: Lockless pagecache perhaps for 2.6.18?
In-Reply-To: <20060323081100.GE26146@wotan.suse.de>
Message-ID: <Pine.LNX.4.61.0603232044330.8050@goblin.wat.veritas.com>
References: <20060323081100.GE26146@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Andrew Morton <akpm@osdl.org>, Andrea Arcangeli <andrea@suse.de>, Linux Memory Management List <linux-mm@kvack.org>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

On Thu, 23 Mar 2006, Nick Piggin wrote:
> 
> Would there be any objection to having my lockless pagecache patches
> merged into -mm, for a possible mainline merge after 2.6.17 (ie. if/
> when the mm hackers feel comfortable with it).

No objection from me (though I've still to study it).
But the timing should be as suits Andrew and state of -mm tree.

> There are now just 3 patches: 15 files, 312 insertions, 81 deletions
> for the core changes, including RCU radix-tree. (not counting those
> last two I just sent you Andrew (VM_BUG_ON, find_trylock_page))

Sounds reasonable (and I've come to prefer 3 patches to 141).

> It is fairly well commented, and not overly complex (IMO) compared
> with other lockless stuff in the tree now.
> 
> My main motivation is to get more testing and more serious reviews,
> rather than trying to clear a fast path into mainline.

Yes, please let's not presuppose it'll go into 2.6.18:
that will depend on what confidence it acquires in -mm.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
