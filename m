Date: Tue, 2 Aug 2005 08:30:37 -0700 (PDT)
From: Linus Torvalds <torvalds@osdl.org>
Subject: Re: [patch 2.6.13-rc4] fix get_user_pages bug
In-Reply-To: <OF3BCB86B7.69087CF8-ON42257051.003DCC6C-42257051.00420E16@de.ibm.com>
Message-ID: <Pine.LNX.4.58.0508020829010.3341@g5.osdl.org>
References: <OF3BCB86B7.69087CF8-ON42257051.003DCC6C-42257051.00420E16@de.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: Andrew Morton <akpm@osdl.org>, Robin Holt <holt@sgi.com>, Hugh Dickins <hugh@veritas.com>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Ingo Molnar <mingo@elte.hu>, Nick Piggin <nickpiggin@yahoo.com.au>, Roland McGrath <roland@redhat.com>
List-ID: <linux-mm.kvack.org>


On Tue, 2 Aug 2005, Martin Schwidefsky wrote:
> 
> Why do we require the !pte_dirty(pte) check? I don't get it. If a writeable
> clean pte is just fine then why do we check the dirty bit at all? Doesn't
> pte_dirty() imply pte_write()?

A _non_writable and clean pty is _also_ fine sometimes. But only if we 
have broken COW and marked it dirty.

> With the additional !pte_write(pte) check (and if I haven't overlooked
> something which is not unlikely) s390 should work fine even without the
> software-dirty bit hack.

No it won't. It will just loop forever in a tight loop if somebody tries 
to put a breakpoint on a read-only location.

On the other hand, this being s390, maybe nobody cares?

		Linus
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
