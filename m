From: David Howells <dhowells@redhat.com>
In-Reply-To: <84144f020802180918h6fb4d52fw4c592407a16b19c0@mail.gmail.com>
References: <84144f020802180918h6fb4d52fw4c592407a16b19c0@mail.gmail.com> <16085.1203350863@redhat.com>
Subject: Re: Slab initialisation problems on MN10300
Date: Mon, 18 Feb 2008 20:38:31 +0000
Message-ID: <24841.1203367111@redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: dhowells@redhat.com, clameter@sgi.com, mpm@selenic.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Pekka Enberg <penberg@cs.helsinki.fi> wrote:

> would put struct arraycache_init to kmalloc-32 and struct kmem_list3
> to kmalloc-64. So are INDEX_AC and INDEX_L3 really equivalent? To
> which cache do they refer to?

(gdb) p sizeof(struct arraycache_init)
$1 = 20
(gdb) p sizeof(struct kmem_list3)
$2 = 52

However, the compiler has eliminated the test:

		if (INDEX_AC == INDEX_L3)

even though it's compiled with -O0.

This is odd.  I'll have to investigate the preprocessor output.

> And if this broke recently, you might want to try and see if commit
> 556a169dab38b5100df6f4a45b655dddd3db94c1 ("slab: fix bootstrap on
> memoryless node") is at fault here by reverting it.

Well, the MN10300 arch worked in -mm, but no longer works now that the patches
have been merged into Linus's tree.  Bisecting is probably not an option.

Thanks, anyway.  I've got something to investigate.

David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
