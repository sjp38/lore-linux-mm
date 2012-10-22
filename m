Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id 472AF6B0062
	for <linux-mm@kvack.org>; Mon, 22 Oct 2012 04:41:04 -0400 (EDT)
Message-ID: <5085068E.5080304@parallels.com>
Date: Mon, 22 Oct 2012 12:40:46 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v5 04/18] slab: don't preemptively remove element from
 list in cache destroy
References: <1350656442-1523-1-git-send-email-glommer@parallels.com> <1350656442-1523-5-git-send-email-glommer@parallels.com> <0000013a7a84cb28-334eab12-33c4-4a92-bd9c-e5ad938f83d0-000000@email.amazonses.com>
In-Reply-To: <0000013a7a84cb28-334eab12-33c4-4a92-bd9c-e5ad938f83d0-000000@email.amazonses.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, kamezawa.hiroyu@jp.fujitsu.com, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, devel@openvz.org, Pekka Enberg <penberg@cs.helsinki.fi>, Suleiman Souhlal <suleiman@google.com>

On 10/19/2012 11:34 PM, Christoph Lameter wrote:
> On Fri, 19 Oct 2012, Glauber Costa wrote:
> 
>> I, however, see no reason why we need to do so, since we are now locked
>> during the whole deletion (which wasn't necessarily true before).  I
>> propose a simplification in which we delete it only when there is no
>> more going back, so we don't need to add it again.
> 
> Ok lets hope that holding the lock does not cause issues.
> 
> Acked-by: Christoph Lameter <cl@linux.com>
> 
BTW: One of the good things about this set, is that we are naturally
exercising cache destruction a lot more than we did before. So if there
is any problem, either with this or anything related to cache
destruction, it should at least show up a lot more frequently. So far,
this does not seem to cause any problems.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
