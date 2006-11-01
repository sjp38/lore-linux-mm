Message-Id: <20061101114435.234474405@chello.nl>
Date: Wed, 01 Nov 2006 12:44:35 +0100
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 0/3] on do_page_fault() and *copy*_inatomic
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, Andrew Morton <akpm@osdl.org>
Cc: Nick Piggin <npiggin@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-arch@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

In light of the recent work on fault handlers and generic_file_buffered_write()
I've gone over some of the arch specific stuff that supports this work.

The following three patches are ready for inclusion IMHO, please apply.

The first patch fixes up some arch fault handlers to respect the
'take no locks in atomic context' rule; this also fixes CONFIG_PREEMPT bugs
on those platforms.

The second patch introduces pagefault_{disable,enable}() - an abtraction that
replaces the now open coded {inc,dec}_preempt_count() calls when we mean to
create atomic pagefault scope. The added barrier() calls in the new 
primitives might fix some CONFIG_PREEMPT bugs.

The third patch make k{,un}map_atomic denote an atomic pagefault scope. All
non-trivial implementation already do this, and this allows us to rely on that
in generic. This might also fix some bugs where people already assumed this.

Peter

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
