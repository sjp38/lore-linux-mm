Date: Tue, 11 Nov 2003 08:12:32 -0800 (PST)
From: Linus Torvalds <torvalds@osdl.org>
Subject: Re: [PATCH?] 2.6.0-test9: mm/memory.c:1075: spin_unlock(kernel/fork.c:c0efed90)
 not locked
In-Reply-To: <20031111150915.GA14601@vana.vc.cvut.cz>
Message-ID: <Pine.LNX.4.44.0311110812060.30657-100000@home.osdl.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Petr Vandrovec <vandrove@vc.cvut.cz>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 11 Nov 2003, Petr Vandrovec wrote:
> 
>   As far as I can tell, problem is that no_mem case should NOT release page_table_lock
> as it was already released before call to pte_chain_alloc(), and was not reacquired
> yet.

Your patch looks correct to me..

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
