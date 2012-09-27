Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id C21DA6B005A
	for <linux-mm@kvack.org>; Thu, 27 Sep 2012 09:44:49 -0400 (EDT)
Message-ID: <50645771.3030204@parallels.com>
Date: Thu, 27 Sep 2012 17:41:05 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3 05/13] Add a __GFP_KMEMCG flag
References: <1347977050-29476-1-git-send-email-glommer@parallels.com> <1347977050-29476-6-git-send-email-glommer@parallels.com> <20120927133435.GE3429@suse.de>
In-Reply-To: <20120927133435.GE3429@suse.de>
Content-Type: text/plain; charset="ISO-8859-15"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, devel@openvz.org, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, Suleiman Souhlal <suleiman@google.com>, Frederic Weisbecker <fweisbec@gmail.com>, David Rientjes <rientjes@google.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>

On 09/27/2012 05:34 PM, Mel Gorman wrote:
> On Tue, Sep 18, 2012 at 06:04:02PM +0400, Glauber Costa wrote:
>> This flag is used to indicate to the callees that this allocation is a
>> kernel allocation in process context, and should be accounted to
>> current's memcg. It takes numerical place of the of the recently removed
>> __GFP_NO_KSWAPD.
>>
>> Signed-off-by: Glauber Costa <glommer@parallels.com>
>> CC: Christoph Lameter <cl@linux.com>
>> CC: Pekka Enberg <penberg@cs.helsinki.fi>
>> CC: Michal Hocko <mhocko@suse.cz>
>> CC: Johannes Weiner <hannes@cmpxchg.org>
>> CC: Suleiman Souhlal <suleiman@google.com>
>> CC: Rik van Riel <riel@redhat.com>
>> CC: Mel Gorman <mel@csn.ul.ie>
>> Acked-by: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> I agree with Christophs recommendation that this flag always exist instead
> of being 0 in the !MEMCG_KMEM case. If __GFP_KMEMCG ever is used in another
> part of the VM (which would be unexpected but still) then the behaviour
> might differ too much between MEMCG_KMEM and !MEMCG_KMEM cases. As unlikely
> as the case is, it's not impossible.
> 
> For tracing __GFP_KMEMCG should have an entry in
> include/trace/events/gfpflags.h
> 
> Get rid of the CONFIG_MEMCG_KMEM check and update
> include/trace/events/gfpflags.h and then feel free to stick my Acked-by
> on it.
> 

Thanks, that is certainly doable.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
