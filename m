Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id 8A2446B004D
	for <linux-mm@kvack.org>; Mon,  7 May 2012 18:04:40 -0400 (EDT)
Received: by qcsd16 with SMTP id d16so4591487qcs.14
        for <linux-mm@kvack.org>; Mon, 07 May 2012 15:04:39 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1336070841-1071-1-git-send-email-glommer@parallels.com>
References: <1336070841-1071-1-git-send-email-glommer@parallels.com>
Date: Mon, 7 May 2012 15:04:39 -0700
Message-ID: <CABCjUKDuiN6bq6rbPjE7futyUwTPKsSFWHXCJ-OFf30tgq5WZg@mail.gmail.com>
Subject: Re: [RFC] slub: show dead memcg caches in a separate file
From: Suleiman Souhlal <suleiman@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, devel@openvz.org, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Michal Hocko <mhocko@suse.cz>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Frederic Weisbecker <fweisbec@gmail.com>

On Thu, May 3, 2012 at 11:47 AM, Glauber Costa <glommer@parallels.com> wrote:
> One of the very few things that still unsettles me in the kmem
> controller for memcg, is how badly we mess up with the
> /proc/slabinfo file.
>
> It is alright to have the cgroup caches listed in slabinfo, but once
> they die, I think they should be removed right away. A box full
> of containers that come and go will rapidly turn that file into
> a supreme mess. However, we currently leave them there so we can
> determine where our used memory currently is.
>
> This patch attempts to clean this up by creating a separate proc file
> only to handle the dead slabs. Among other advantages, we need a lot
> less information in a dead cache: only its current size in memory
> matters to us.
>
> So besides avoiding polution of the slabinfo files, we can access
> dead cache information itself in a cleaner way.
>
> I implemented this as a proof of concept while finishing up
> my last round for submission. But I am sending this separately
> to collect opinions from all of you. I can either implement
> a version of this for the slab, or follow any other route.

I don't really understand why the "dead" slabs are considered as
polluting slabinfo.

They still have objects in them, and I think that hiding them would
not be the right thing to do (even if they are available in a separate
file): They will incorrectly not be seen by programs like slabtop.

-- Suleiman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
