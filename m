Message-ID: <20030520202728.42626.qmail@web12308.mail.yahoo.com>
Date: Tue, 20 May 2003 13:27:28 -0700 (PDT)
From: Ravi <kravi26@yahoo.com>
Subject: BUG_ON in remap_pte_range: Why?
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, kernelnewbies@nl.linux.org
List-ID: <linux-mm.kvack.org>

Hi,

I am looking at the latest mm/memory.c on Bitkeeper.
The comment for remap_pte_range() says "maps a range of 
physical memory into the requested pages. the old mappings
are removed". But the code has this check:

BUG_ON(!pte_none(*pte));

Why is it a bug to have a valid PTE when remap_pte_range()
is called? The 2.4 version of this fucntion cleared the
old PTE using ptep_get_and_clear() and then installed
a new one. Why was this changed?

Thanks,
Ravi.

__________________________________
Do you Yahoo!?
The New Yahoo! Search - Faster. Easier. Bingo.
http://search.yahoo.com
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
