Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id DA2946B0070
	for <linux-mm@kvack.org>; Thu, 18 Oct 2012 18:42:04 -0400 (EDT)
Date: Thu, 18 Oct 2012 15:42:03 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v5] slab: Ignore internal flags in cache creation
Message-Id: <20121018154203.4b3a1179.akpm@linux-foundation.org>
In-Reply-To: <1350473811-16264-1-git-send-email-glommer@parallels.com>
References: <1350473811-16264-1-git-send-email-glommer@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, devel@openvz.org, Pekka Enberg <penberg@cs.helsinki.fi>

On Wed, 17 Oct 2012 15:36:51 +0400
Glauber Costa <glommer@parallels.com> wrote:

> Some flags are used internally by the allocators for management
> purposes. One example of that is the CFLGS_OFF_SLAB flag that slab uses
> to mark that the metadata for that cache is stored outside of the slab.
> 
> No cache should ever pass those as a creation flags. We can just ignore
> this bit if it happens to be passed (such as when duplicating a cache in
> the kmem memcg patches).

I may be minunderstanding this, but...

If some caller to kmem_cache_create() is passing in bogus flags then
that's a bug, and it is undesirable to hide such a bug in this fashion?

> Because such flags can vary from allocator to allocator, we allow them
> to make their own decisions on that, defining SLAB_AVAILABLE_FLAGS with
> all flags that are valid at creation time.  Allocators that doesn't have
> any specific flag requirement should define that to mean all flags.
> 
> Common code will mask out all flags not belonging to that set.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
