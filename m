Date: Tue, 5 Jun 2001 13:54:15 -0400
From: cohutta <cohutta@MailAndNews.com>
Subject: temp. mem mappings
Message-ID: <3B568C0B@MailAndNews.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

hi-

i'm trying to map some memory during kernel init.
(this is x86-specific.)
this should be temporary, unmapped after use.
this memory is not in the low identity-mapped 8 MB.

currently i have this sorta working by using a new fixed
mapping (linux/include/asm-i386/fixmap.h) and calling
set_fixmap() which calls set_pte_phys().
after i use (access, read-only) this memory, i try to
unmap it so that i can use the same virtual address
again by calling set_fixmap() again.
i use pte_clear() to unmap it.
however the next time that i call set_fixmap(),
set_pte_phys() gives me a pte_ERROR()...because the
pte hasn't been cleared (?).
but the new mapping seems to work.

i tried to make this similar to linux/include/asm-i386/highmem.h.

what is the a preferred/correct method to map and unmap memory
temporarily?

thanks.
/cohutta/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
