Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id 1B3F56B006C
	for <linux-mm@kvack.org>; Wed, 19 Sep 2012 03:49:25 -0400 (EDT)
Message-ID: <505977D8.7050005@parallels.com>
Date: Wed, 19 Sep 2012 11:44:24 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3 08/16] slab: allow enable_cpu_cache to use preset values
 for its tunables
References: <1347977530-29755-1-git-send-email-glommer@parallels.com> <1347977530-29755-9-git-send-email-glommer@parallels.com> <00000139d9fc4ccc-d0904b9b-5bbf-4cf6-9325-013f16f11745-000000@email.amazonses.com>
In-Reply-To: <00000139d9fc4ccc-d0904b9b-5bbf-4cf6-9325-013f16f11745-000000@email.amazonses.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, devel@openvz.org, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, Suleiman Souhlal <suleiman@google.com>, Frederic Weisbecker <fweisbec@gmail.com>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>

On 09/18/2012 07:25 PM, Christoph Lameter wrote:
> On Tue, 18 Sep 2012, Glauber Costa wrote:
> 
>> SLAB allows us to tune a particular cache behavior with tunables.
>> When creating a new memcg cache copy, we'd like to preserve any tunables
>> the parent cache already had.
> 
> Again the same is true for SLUB. Some generic way of preserving tuning
> parameters would be appreciated.

So you would like me to extend "slub: slub-specific propagation changes"
to also allow for pre-set values, right?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
