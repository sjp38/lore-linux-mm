Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id DFE996B0044
	for <linux-mm@kvack.org>; Tue, 25 Sep 2012 12:28:12 -0400 (EDT)
Date: Tue, 25 Sep 2012 16:28:11 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v3 06/16] memcg: infrastructure to match an allocation
 to the right cache
In-Reply-To: <5061B852.7070902@parallels.com>
Message-ID: <00000139fe41d6c9-f647ef17-8c06-4332-91b8-13c18a0b19ea-000000@email.amazonses.com>
References: <1347977530-29755-1-git-send-email-glommer@parallels.com> <1347977530-29755-7-git-send-email-glommer@parallels.com> <20120921183217.GH7264@google.com> <50601DEB.10705@parallels.com> <20120924175619.GD7694@google.com>
 <5061B852.7070902@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Tejun Heo <tj@kernel.org>, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, devel@openvz.org, linux-mm@kvack.org, Suleiman Souhlal <suleiman@google.com>, Frederic Weisbecker <fweisbec@gmail.com>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>

On Tue, 25 Sep 2012, Glauber Costa wrote:

> >> 1) Do like the events mechanism and allocate this in a separate
> >> structure. Add a pointer chase in the access, and I don't think it helps
> >> much because it gets allocated anyway. But we could at least
> >> defer it to the time when we limit the cache.
> >
> > Start at some reasonable size and then double it as usage grows?  How
> > many kmem_caches do we typically end up using?
> >
>
> So my Fedora box here, recently booted on a Fedora kernel, will have 111
> caches. How would 150 sound to you?

Some drivers/subsystems can dynamically create slabs as needed for new
devices or instances of metadata. You cannot use a fixed size
array and cannot establish an upper boundary for the number of slabs on
the system.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
