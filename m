From: David Howells <dhowells@redhat.com>
In-Reply-To: <47B9F128.50500@cs.helsinki.fi>
References: <47B9F128.50500@cs.helsinki.fi> <84144f020802180918h6fb4d52fw4c592407a16b19c0@mail.gmail.com> <16085.1203350863@redhat.com> <24841.1203367111@redhat.com>
Subject: Re: Slab initialisation problems on MN10300
Date: Mon, 18 Feb 2008 22:41:21 +0000
Message-ID: <25150.1203374481@redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: dhowells@redhat.com, clameter@sgi.com, mpm@selenic.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Pekka Enberg <penberg@cs.helsinki.fi> wrote:

> What's PAGE_SIZE for the architecture? If it's something other than 4KB, the
> size 32 cache is not there which makes both use the 64 one. However, that
> should work too, so maybe there's some GCC bug here for your architecture?

It's 4K.

David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
