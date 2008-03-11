Message-Id: <20080311104653.995564000@nick.local0.net>
Date: Tue, 11 Mar 2008 21:46:53 +1100
From: npiggin@nick.local0.net
Subject: [patch 0/7] [rfc] VM_MIXEDMAP, pte_special, xip work
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: akpm@linux-foundation.org, Jared Hulbert <jaredeh@gmail.com>, Carsten Otte <cotte@de.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

-- 

(doh, please ignore the previous "x/6" patches, they're old. The
new ones are these x/7 set)

Hi,

I'm sorry for neglecting these patches for a few weeks :(

I'd like to still get them into -mm and aim for the next merge window --
they've been gradually getting a pretty reasonable amount of review and
testing. I think the implementation of the pte_special path in vm_normal_page
and vm_insert_mixed was the only point left unresolved since last time.

I've included the dual kaddr/pfn API that we worked out with Jared, but
he hasn't yet tested my patch rollup... so this is an RFC only. If we all
agree on it, then I'll rebase to -mm and submit.

Thanks,
Nick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
