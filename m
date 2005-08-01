Date: Mon, 1 Aug 2005 12:48:40 -0700 (PDT)
From: Linus Torvalds <torvalds@osdl.org>
Subject: Re: [patch 2.6.13-rc4] fix get_user_pages bug
In-Reply-To: <Pine.LNX.4.61.0508012024330.5373@goblin.wat.veritas.com>
Message-ID: <Pine.LNX.4.58.0508011238330.3341@g5.osdl.org>
References: <20050801032258.A465C180EC0@magilla.sf.frob.com>
 <42EDDB82.1040900@yahoo.com.au> <Pine.LNX.4.58.0508010833250.14342@g5.osdl.org>
 <Pine.LNX.4.61.0508012024330.5373@goblin.wat.veritas.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Robin Holt <holt@sgi.com>, Andrew Morton <akpm@osdl.org>, Roland McGrath <roland@redhat.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, linux-mm@kvack.org, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>


On Mon, 1 Aug 2005, Hugh Dickins wrote:
> 
> Attractive, I very much wanted to do that rather than change all the
> arches, but I think s390 rules it out: its pte_mkdirty does nothing,
> its pte_dirty just says no.

How does s390 work at all?

> Or should we change s390 to set a flag in the pte just for this purpose?

If the choice is between a broken and ugly implementation for everybody 
else, then hell yes. Even if it's a purely sw bit that nothing else 
actually cares about.. I hope they have an extra bit around somewhere.

			Linus
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
