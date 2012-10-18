Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id 44E636B005A
	for <linux-mm@kvack.org>; Thu, 18 Oct 2012 05:34:08 -0400 (EDT)
Message-ID: <507FCD02.106@parallels.com>
Date: Thu, 18 Oct 2012 13:33:54 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v5 11/14] memcg: allow a memcg with kmem charges to be
 destructed.
References: <1350382611-20579-1-git-send-email-glommer@parallels.com> <1350382611-20579-12-git-send-email-glommer@parallels.com> <20121017151235.1e5d6f21.akpm@linux-foundation.org>
In-Reply-To: <20121017151235.1e5d6f21.akpm@linux-foundation.org>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, kamezawa.hiroyu@jp.fujitsu.com, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, devel@openvz.org, linux-kernel@vger.kernel.org, Pekka Enberg <penberg@cs.helsinki.fi>, Suleiman Souhlal <suleiman@google.com>

On 10/18/2012 02:12 AM, Andrew Morton wrote:
> On Tue, 16 Oct 2012 14:16:48 +0400
> Glauber Costa <glommer@parallels.com> wrote:
> 
>> Because the ultimate goal of the kmem tracking in memcg is to track slab
>> pages as well,
> 
> It is?  For a major patchset such as this, it's pretty important to
> discuss such long-term plans in the top-level discussion.  Covering
> things such as expected complexity, expected performance hit, how these
> plans affected the current implementation, etc.
> 
> The main reason for this is that if the future plans appear to be of
> doubtful feasibility and the current implementation isn't sufficiently
> useful without the future stuff, we shouldn't merge the current
> implementation.  It's a big issue!
> 

Not really. I am not talking about plans when it comes to slab. The code
is there, and usually always posted to linux-mm a few days after I post
this series. It also lives in the kmemcg-slab branch in my git tree.

I am trying to logically split it in two to aid reviewers work. I may
have made a mistake by splitting it this way, but so far I think it was
the right decision: it allowed people to focus on a part of the work
first, instead of going all the way in a 30-patch patch series that
would be merged atomically.

I believe they should be merged separately, to allow us to find any
issues easier. But I also believe that this "separate" should ultimately
live in the same merge window.

Pekka, from the slab side, already stated that 3.8 would not be
unreasonable.

As for the perfomance hit, my latest benchmark, quoted in the opening
mail of this series already include results for both patchsets.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
