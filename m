Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id AC9416B0068
	for <linux-mm@kvack.org>; Wed, 17 Oct 2012 18:12:36 -0400 (EDT)
Date: Wed, 17 Oct 2012 15:12:35 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v5 11/14] memcg: allow a memcg with kmem charges to be
 destructed.
Message-Id: <20121017151235.1e5d6f21.akpm@linux-foundation.org>
In-Reply-To: <1350382611-20579-12-git-send-email-glommer@parallels.com>
References: <1350382611-20579-1-git-send-email-glommer@parallels.com>
	<1350382611-20579-12-git-send-email-glommer@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, kamezawa.hiroyu@jp.fujitsu.com, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, devel@openvz.org, linux-kernel@vger.kernel.org, Pekka Enberg <penberg@cs.helsinki.fi>, Suleiman Souhlal <suleiman@google.com>

On Tue, 16 Oct 2012 14:16:48 +0400
Glauber Costa <glommer@parallels.com> wrote:

> Because the ultimate goal of the kmem tracking in memcg is to track slab
> pages as well,

It is?  For a major patchset such as this, it's pretty important to
discuss such long-term plans in the top-level discussion.  Covering
things such as expected complexity, expected performance hit, how these
plans affected the current implementation, etc.

The main reason for this is that if the future plans appear to be of
doubtful feasibility and the current implementation isn't sufficiently
useful without the future stuff, we shouldn't merge the current
implementation.  It's a big issue!

> we can't guarantee that we'll always be able to point a
> page to a particular process, and migrate the charges along with it -
> since in the common case, a page will contain data belonging to multiple
> processes.
> 
> Because of that, when we destroy a memcg, we only make sure the
> destruction will succeed by discounting the kmem charges from the user
> charges when we try to empty the cgroup.
> 
> ...
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
