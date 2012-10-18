Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id 762276B0044
	for <linux-mm@kvack.org>; Thu, 18 Oct 2012 16:44:59 -0400 (EDT)
Date: Thu, 18 Oct 2012 13:44:57 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v5 07/14] mm: Allocate kernel pages to the right memcg
Message-Id: <20121018134457.5e7edd19.akpm@linux-foundation.org>
In-Reply-To: <507FCADF.20109@parallels.com>
References: <1350382611-20579-1-git-send-email-glommer@parallels.com>
	<1350382611-20579-8-git-send-email-glommer@parallels.com>
	<20121017151221.4c420e5a.akpm@linux-foundation.org>
	<507FCADF.20109@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, kamezawa.hiroyu@jp.fujitsu.com, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, devel@openvz.org, linux-kernel@vger.kernel.org, Pekka Enberg <penberg@cs.helsinki.fi>, Suleiman Souhlal <suleiman@google.com>

On Thu, 18 Oct 2012 13:24:47 +0400
Glauber Costa <glommer@parallels.com> wrote:

> On 10/18/2012 02:12 AM, Andrew Morton wrote:
> > On Tue, 16 Oct 2012 14:16:44 +0400
> > Glauber Costa <glommer@parallels.com> wrote:
> > 
> >> When a process tries to allocate a page with the __GFP_KMEMCG flag, the
> >> page allocator will call the corresponding memcg functions to validate
> >> the allocation. Tasks in the root memcg can always proceed.
> >>
> >> To avoid adding markers to the page - and a kmem flag that would
> >> necessarily follow, as much as doing page_cgroup lookups for no reason,
> >> whoever is marking its allocations with __GFP_KMEMCG flag is responsible
> >> for telling the page allocator that this is such an allocation at
> >> free_pages() time.
> > 
> > Well, why?  Was that the correct decision?
> > 
> 
> I don't fully understand your question. Is this the same question you
> posed in patch 0, about marking some versus marking all? If so, I
> believe I should have answered it there.

Yes, it's the same question.  The one which has not yet been fully answered ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
