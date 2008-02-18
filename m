From: David Howells <dhowells@redhat.com>
In-Reply-To: <84144f020802180918h6fb4d52fw4c592407a16b19c0@mail.gmail.com>
References: <84144f020802180918h6fb4d52fw4c592407a16b19c0@mail.gmail.com> <16085.1203350863@redhat.com>
Subject: Re: Slab initialisation problems on MN10300
Date: Mon, 18 Feb 2008 23:02:28 +0000
Message-ID: <31300.1203375748@redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: dhowells@redhat.com, clameter@sgi.com, mpm@selenic.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Pekka Enberg <penberg@cs.helsinki.fi> wrote:

> If you didn't see PARTIAL_AC state at all, SLAB thinks INDEX_AC and
> INDEX_L3 are equal. However,

Ah...  The problem is that index_of() behaves differently under -O0 rather
than -O1, -O2 or -Os.

I was using -O0 so that I could debug another problem using GDB on the kernel.
However, this appears to mean that __builtin_constant_p() inside an inline
function is always false, even if the function is actually inlined because of
__always_inline.

I'd commented out the __bad_size() calls because they went to places that
don't exist, and so the -O0 kernel wouldn't link.

David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
