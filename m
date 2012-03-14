Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id 240706B0044
	for <linux-mm@kvack.org>; Wed, 14 Mar 2012 18:08:14 -0400 (EDT)
Received: by yhjj63 with SMTP id j63so2552957yhj.9
        for <linux-mm@kvack.org>; Wed, 14 Mar 2012 15:08:13 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4F608579.5090109@parallels.com>
References: <1331325556-16447-1-git-send-email-ssouhlal@FreeBSD.org>
	<1331325556-16447-7-git-send-email-ssouhlal@FreeBSD.org>
	<4F5C8414.5090800@parallels.com>
	<CABCjUKCioWO-F7k=hVs_18B3uyL4zG3-krPFDh++YAnmejKKdg@mail.gmail.com>
	<4F608579.5090109@parallels.com>
Date: Wed, 14 Mar 2012 15:08:13 -0700
Message-ID: <CABCjUKCktPzzZDXMRejDXGXtta=pH5LGHRGU-SjJPuYNkxjH0g@mail.gmail.com>
Subject: Re: [PATCH v2 06/13] slab: Add kmem_cache_gfp_flags() helper function.
From: Suleiman Souhlal <suleiman@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Suleiman Souhlal <ssouhlal@freebsd.org>, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, penberg@kernel.org, cl@linux.com, yinghan@google.com, hughd@google.com, gthelen@google.com, peterz@infradead.org, dan.magenheimer@oracle.com, hannes@cmpxchg.org, mgorman@suse.de, James.Bottomley@hansenpartnership.com, linux-mm@kvack.org, devel@openvz.org, linux-kernel@vger.kernel.org

On Wed, Mar 14, 2012 at 4:48 AM, Glauber Costa <glommer@parallels.com> wrote:
> So what?
> That function is only called from slab.c anyway. Let slab call it
> mem_cgroup_get_kmem_cache(cachep, flags | cachep->allocflags);
> and slub
> mem_cgroup_get_kmem_cache(cachep, flags | cachep->gfpflags);

Ok, I will do that.
I felt like it was better to do it in a single place, instead of doing
it at all the callers.

-- Suleiman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
