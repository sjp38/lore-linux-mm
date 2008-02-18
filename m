From: David Howells <dhowells@redhat.com>
In-Reply-To: <84144f020802180937p6bea0a25t93b8f9c7202b06e2@mail.gmail.com>
References: <84144f020802180937p6bea0a25t93b8f9c7202b06e2@mail.gmail.com> <16085.1203350863@redhat.com> <84144f020802180918h6fb4d52fw4c592407a16b19c0@mail.gmail.com>
Subject: Re: Slab initialisation problems on MN10300
Date: Mon, 18 Feb 2008 20:39:08 +0000
Message-ID: <24867.1203367148@redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: dhowells@redhat.com, clameter@sgi.com, mpm@selenic.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Pekka Enberg <penberg@cs.helsinki.fi> wrote:

> One thing that I thought of was ARCH_KMALLOC_MINALIGN
> which is set to some fairly big values on some MIPS architectures
> (MN10300 is one, right?)

No.  MN10300 is not MIPS.

David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
