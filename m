Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id 45D276B0031
	for <linux-mm@kvack.org>; Mon,  9 Sep 2013 10:44:04 -0400 (EDT)
Date: Mon, 9 Sep 2013 14:44:03 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [REPOST PATCH 3/4] slab: introduce byte sized index for the
 freelist of a slab
In-Reply-To: <20130909043217.GB22390@lge.com>
Message-ID: <00000141032dea11-c5aa9c77-b2f2-4cab-b7a0-d37665a6cec8-000000@email.amazonses.com>
References: <1378447067-19832-1-git-send-email-iamjoonsoo.kim@lge.com> <1378447067-19832-4-git-send-email-iamjoonsoo.kim@lge.com> <00000140f3fed229-f49b95d4-7087-476f-b2c9-37846749aad6-000000@email.amazonses.com> <20130909043217.GB22390@lge.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Pekka Enberg <penberg@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 9 Sep 2013, Joonsoo Kim wrote:

> 32 byte is not minimum object size, minimum *kmalloc* object size
> in default configuration. There are some slabs that their object size is
> less than 32 byte. If we have a 8 byte sized kmem_cache, it has 512 objects
> in 4K page.

As far as I can recall only SLUB supports 8 byte objects. SLABs mininum
has always been 32 bytes.

> Moreover, we can configure slab_max_order in boot time so that we can't know
> how many object are in a certain slab in compile time. Therefore we can't
> decide the size of the index in compile time.

You can ignore the slab_max_order if necessary.

> I think that byte and short int sized index support would be enough, but
> it should be determined at runtime.

On x86 f.e. it would add useless branching. The branches are never taken.
You only need these if you do bad things to the system like requiring
large contiguous allocs.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
