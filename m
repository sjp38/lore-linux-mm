Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 0966F6B002D
	for <linux-mm@kvack.org>; Mon, 24 Oct 2011 01:19:08 -0400 (EDT)
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH v2 6/6] slub: only preallocate cpus_with_slabs if offstack
References: <1319384922-29632-1-git-send-email-gilad@benyossef.com>
	<1319384922-29632-7-git-send-email-gilad@benyossef.com>
Date: Sun, 23 Oct 2011 22:19:06 -0700
In-Reply-To: <1319384922-29632-7-git-send-email-gilad@benyossef.com> (Gilad
	Ben-Yossef's message of "Sun, 23 Oct 2011 17:48:42 +0200")
Message-ID: <m2obx755md.fsf@firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gilad Ben-Yossef <gilad@benyossef.com>
Cc: lkml@vger.kernel.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Frederic Weisbecker <fweisbec@gmail.com>, Russell King <linux@arm.linux.org.uk>, linux-mm@kvack.org, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Sasha Levin <levinsasha928@gmail.com>

Gilad Ben-Yossef <gilad@benyossef.com> writes:

> We need a cpumask to track cpus with per cpu cache pages
> to know which cpu to whack during flush_all. For
> CONFIG_CPUMASK_OFFSTACK=n we allocate the mask on stack.
> For CONFIG_CPUMASK_OFFSTACK=y we don't want to call kmalloc
> on the flush_all path, so we preallocate per kmem_cache
> on cache creation and use it in flush_all.

What's the problem with calling kmalloc in flush_all? 
That's a slow path anyways, isn't it?

I believe the IPI functions usually allocate anyways.

So maybe you can do that much simpler.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
