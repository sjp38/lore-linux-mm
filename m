Subject: Re: [PATCH] get_user_pages shortcut for anonymous pages.
Message-ID: <OF6EF57E85.22D55C5C-ONC1256E6E.0027D264-C1256E6E.0028A85B@de.ibm.com>
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Date: Tue, 6 Apr 2004 09:24:05 +0200
MIME-Version: 1.0
Content-type: text/plain; charset=ISO-8859-1
Content-transfer-encoding: 8BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>




> OK..  I'm not sure that this patch makes sense though.  I mean, if your
> test had gone and dirtied all these pages rather than forcing the
coredump
> code to do it, we'd still exhaust all physical memory with pagetables,
> assuming you have enough swapspace.  So I don't see we're gaining much?

Well, it the test would have tried to dirty all these pages it would have
run out of memory long before the available real memory is filled up with
page tables. After bigcore has finished I had a core file of 2 terabyte.
What we are gaining with the patch is that a system can't be "crashed"
any more by a wild store of a process to a memory location below the
stack. Consider a store to current stack - 1TB. The stack vma is extended
to include this address because of VM_GROWSDOWN. If such a process dies
(which is likely for a defunc process) then the elf core dumper will
cause the system to hang because of too many page tables. I known that
this can easily be circumvented with ulimit. This is why I asked the
question if I am wasting my time with this.

blue skies,
   Martin

Linux/390 Design & Development, IBM Deutschland Entwicklung GmbH
Schonaicherstr. 220, D-71032 Boblingen, Telefon: 49 - (0)7031 - 16-2247
E-Mail: schwidefsky@de.ibm.com


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
