Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 512E46B01E3
	for <linux-mm@kvack.org>; Tue, 13 Apr 2010 05:32:46 -0400 (EDT)
Message-ID: <4BC43A3C.7010603@cs.helsinki.fi>
Date: Tue, 13 Apr 2010 12:32:44 +0300
From: Pekka Enberg <penberg@cs.helsinki.fi>
MIME-Version: 1.0
Subject: Re: [PATCH - V2] Fix missing of last user while dumping slab 	corruption
 log
References: <w2z4810ea571004112250x855fadd5uecbc813726ae3412@mail.gmail.com> <h2v5f4a33681004130005xc06eadf7jc94e9257c6af4350@mail.gmail.com>
In-Reply-To: <h2v5f4a33681004130005xc06eadf7jc94e9257c6af4350@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: TAO HU <tghk48@motorola.com>, Nick Piggin <npiggin@suse.de>
Cc: linux-kernel@vger.kernel.org, cl@linux-foundation.org, mpm@selenic.com, linux-mm@kvack.org, dwmw2@infradead.org, TAO HU <taohu@motorola.com>, ShiYong LI <shi-yong.li@motorola.com>, david.rientjes@google.com
List-ID: <linux-mm.kvack.org>

TAO HU kirjoitti:
> Actually we greped "kmem_cache_create" in whole kernel souce tree
> (2.6.29 and 2.6.32).
> 
> Either "align" equal to "0" or flag SLAB_HWCACHE_ALIGN is used when
> calling kmem_cache_create().

I don't think that's correct. The "task_xstate" has alignof(struct 
task_xstate) and there seems to be so GCC attributes that force 
non-default alignment on the struct.

> Seems all of arch's cache-line-size is multiple of 64-bit/8-byte
> (sizeof(long long)) except  arch-microblaze (4-byte).
> The smallest (except arch-microblaze) cache-line-size is 2^4= 16-byte
> as I can see.
> So even considering possible sizeof(long long) == 128-bit/16-byte, it
> is still safe to apply Shiyong's original version.
> 
> Anyway, Shiyong's new patch check the weired situation that "align >
> sizeof(long long) && align is NOT multiple of sizeof (long long)"
> Let us know whether the new version address your concerns.

Yeah, sorry for dragging this issue on. I've been looking at the patch 
but haven't been able to convince myself that it's correct. Nick, David, 
Christoph, Matt, could you also please take a look at this?

			Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
