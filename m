Date: Fri, 15 Sep 2006 14:30:24 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [RFC] page fault retry with NOPAGE_RETRY
In-Reply-To: <20060915003529.8a59c542.akpm@osdl.org>
Message-ID: <Pine.LNX.4.64.0609151425050.22674@blonde.wat.veritas.com>
References: <1158274508.14473.88.camel@localhost.localdomain>
 <20060915001151.75f9a71b.akpm@osdl.org> <20060915003529.8a59c542.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, linux-mm@kvack.org, Linux Kernel list <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@osdl.org>, Mike Waychison <mikew@google.com>
List-ID: <linux-mm.kvack.org>

On Fri, 15 Sep 2006, Andrew Morton wrote:
> 
> This assumes that no other heavyweight process will try to modify this
> single-threaded process's mm.  I don't _think_ that happens anywhere, does
> it?  access_process_vm() is the only case I can think of,

"Modify" in the sense of fault into.
Yes, access_process_vm() is all I can think of too.

> and it does down_read(other process's mmap_sem).

If there were anything else, it'd have to do so too (if not down_write).

I too like NOPAGE_RETRY: as you've both observed, it can help to solve
several different problems.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
