Date: Mon, 1 Aug 2005 20:45:29 -0700 (PDT)
From: Linus Torvalds <torvalds@osdl.org>
Subject: Re: [patch 2.6.13-rc4] fix get_user_pages bug
In-Reply-To: <42EECC1F.9000902@yahoo.com.au>
Message-ID: <Pine.LNX.4.58.0508012039120.3341@g5.osdl.org>
References: <20050801032258.A465C180EC0@magilla.sf.frob.com>
 <42EDDB82.1040900@yahoo.com.au> <Pine.LNX.4.58.0508010833250.14342@g5.osdl.org>
 <42EECC1F.9000902@yahoo.com.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Robin Holt <holt@sgi.com>, Andrew Morton <akpm@osdl.org>, Roland McGrath <roland@redhat.com>, Hugh Dickins <hugh@veritas.com>, linux-mm@kvack.org, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>


On Tue, 2 Aug 2005, Nick Piggin wrote:
> 
> Surely this introduces integrity problems when `force` is not set?

"force" changes how we test the vma->vm_flags, that was always the 
meaning from a security standpoint (and that hasn't changed).

The old code had this "lookup_write = write && !force;" thing because
there it used "force" to _clear_ the write bit test, and that was what
caused the race in the first place - next time around we would accept a
non-writable page, even if it hadn't actually gotten COW'ed.

So no, the patch doesn't introduce integrity problems by ignoring "force".  
Quite the reverse - it _removes_ the integrity problems by ignoring it
there. That's kind of the whole point.

		Linus
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
