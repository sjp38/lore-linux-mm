Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id 19B1E6B004D
	for <linux-mm@kvack.org>; Tue, 15 May 2012 17:55:08 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so298635pbb.14
        for <linux-mm@kvack.org>; Tue, 15 May 2012 14:55:07 -0700 (PDT)
Date: Tue, 15 May 2012 14:55:04 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v2 02/29] slub: fix slab_state for slub
In-Reply-To: <1336758272-24284-3-git-send-email-glommer@parallels.com>
Message-ID: <alpine.DEB.2.00.1205151453460.18595@chino.kir.corp.google.com>
References: <1336758272-24284-1-git-send-email-glommer@parallels.com> <1336758272-24284-3-git-send-email-glommer@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>, Pekka Enberg <penberg@cs.helsinki.fi>
Cc: linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>, Greg Thelen <gthelen@google.com>, Suleiman Souhlal <suleiman@google.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, devel@openvz.org, Christoph Lameter <cl@linux.com>

On Fri, 11 May 2012, Glauber Costa wrote:

> When the slub code wants to know if the sysfs state has already been
> initialized, it tests for slab_state == SYSFS. This is quite fragile,
> since new state can be added in the future (it is, in fact, for
> memcg caches). This patch fixes this behavior so the test matches
> >= SYSFS, as all other state does.
> 
> Signed-off-by: Glauber Costa <glommer@parallels.com>

Acked-by: David Rientjes <rientjes@google.com>

Can be merged now, there's no dependency on the rest of this patchset.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
