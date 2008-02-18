Message-ID: <47B9F128.50500@cs.helsinki.fi>
Date: Mon, 18 Feb 2008 22:57:12 +0200
From: Pekka Enberg <penberg@cs.helsinki.fi>
MIME-Version: 1.0
Subject: Re: Slab initialisation problems on MN10300
References: <84144f020802180918h6fb4d52fw4c592407a16b19c0@mail.gmail.com> <16085.1203350863@redhat.com> <24841.1203367111@redhat.com>
In-Reply-To: <24841.1203367111@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Howells <dhowells@redhat.com>
Cc: clameter@sgi.com, mpm@selenic.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

David Howells wrote:
> (gdb) p sizeof(struct arraycache_init)
> $1 = 20
> (gdb) p sizeof(struct kmem_list3)
> $2 = 52
> 
> However, the compiler has eliminated the test:
> 
> 		if (INDEX_AC == INDEX_L3)
> 
> even though it's compiled with -O0.
> 
> This is odd.  I'll have to investigate the preprocessor output.

What's PAGE_SIZE for the architecture? If it's something other than 4KB, 
the size 32 cache is not there which makes both use the 64 one. However, 
that should work too, so maybe there's some GCC bug here for your 
architecture?

			Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
