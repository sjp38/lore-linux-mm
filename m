Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 479586B002D
	for <linux-mm@kvack.org>; Mon, 24 Oct 2011 02:23:47 -0400 (EDT)
Received: by wyg34 with SMTP id 34so7618121wyg.14
        for <linux-mm@kvack.org>; Sun, 23 Oct 2011 23:16:19 -0700 (PDT)
Subject: Re: [PATCH v2 6/6] slub: only preallocate cpus_with_slabs if
 offstack
From: Sasha Levin <levinsasha928@gmail.com>
In-Reply-To: <m2obx755md.fsf@firstfloor.org>
References: <1319384922-29632-1-git-send-email-gilad@benyossef.com>
	 <1319384922-29632-7-git-send-email-gilad@benyossef.com>
	 <m2obx755md.fsf@firstfloor.org>
Content-Type: text/plain; charset="us-ascii"
Date: Mon, 24 Oct 2011 08:16:14 +0200
Message-ID: <1319436974.12841.1.camel@lappy>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Gilad Ben-Yossef <gilad@benyossef.com>, lkml@vger.kernel.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Frederic Weisbecker <fweisbec@gmail.com>, Russell King <linux@arm.linux.org.uk>, linux-mm@kvack.org, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>

On Sun, 2011-10-23 at 22:19 -0700, Andi Kleen wrote:
> Gilad Ben-Yossef <gilad@benyossef.com> writes:
> 
> > We need a cpumask to track cpus with per cpu cache pages
> > to know which cpu to whack during flush_all. For
> > CONFIG_CPUMASK_OFFSTACK=n we allocate the mask on stack.
> > For CONFIG_CPUMASK_OFFSTACK=y we don't want to call kmalloc
> > on the flush_all path, so we preallocate per kmem_cache
> > on cache creation and use it in flush_all.
> 
> What's the problem with calling kmalloc in flush_all? 
> That's a slow path anyways, isn't it?
> 
> I believe the IPI functions usually allocate anyways.
> 
> So maybe you can do that much simpler.

You'd be trying to allocate memory in a memory shrinking path.

-- 

Sasha.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
