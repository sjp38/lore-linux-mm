Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id 709386B005A
	for <linux-mm@kvack.org>; Wed, 19 Sep 2012 10:14:24 -0400 (EDT)
Date: Wed, 19 Sep 2012 14:14:23 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v3 09/16] sl[au]b: always get the cache from its page in
 kfree
In-Reply-To: <5059777E.8060906@parallels.com>
Message-ID: <00000139dee12735-6220e641-d91c-446e-a329-ed9389eafa22-000000@email.amazonses.com>
References: <1347977530-29755-1-git-send-email-glommer@parallels.com> <1347977530-29755-10-git-send-email-glommer@parallels.com> <00000139d9fe8595-8905906d-18ed-4d41-afdb-f4c632c2d50a-000000@email.amazonses.com> <5059777E.8060906@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, devel@openvz.org, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, Suleiman Souhlal <suleiman@google.com>, Frederic Weisbecker <fweisbec@gmail.com>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>

On Wed, 19 Sep 2012, Glauber Costa wrote:

> > This is an extremely hot path of the kernel and you are adding significant
> > processing. Check how the benchmarks are influenced by this change.
> > virt_to_cache can be a bit expensive.
> Would it be enough for you to have a separate code path for
> !CONFIG_MEMCG_KMEM?

Yes, at least add an #ifdef around this.

> I don't really see another way to do it, aside from deriving the cache
> from the object in our case. I am open to suggestions if you do.

Rethink the whole memcg approach and find some other way to do it? This
whole scheme is very intrusive and is likely to increase instability in
the VM given the explosion of lru lists, duplication of slab caches and
significantly more complex processing throughout the VM.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
