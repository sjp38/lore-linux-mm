Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id A54306B005A
	for <linux-mm@kvack.org>; Thu, 18 Oct 2012 07:39:08 -0400 (EDT)
Message-ID: <507FEA44.9040004@parallels.com>
Date: Thu, 18 Oct 2012 15:38:44 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v4 00/19] slab accounting for memcg
References: <1350049273-17213-1-git-send-email-glommer@parallels.com>
In-Reply-To: <1350049273-17213-1-git-send-email-glommer@parallels.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: cgroups@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, kamezawa.hiroyu@jp.fujitsu.com, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, devel@openvz.org

On 10/12/2012 05:40 PM, Glauber Costa wrote:
> This is a followup to the previous kmem series. I divided them logically
> so it gets easier for reviewers. But I believe they are ready to be merged
> together (although we can do a two-pass merge if people would prefer)
> 
> Throwaway git tree found at:
> 
> 	git://git.kernel.org/pub/scm/linux/kernel/git/glommer/memcg.git kmemcg-slab
> 

To all reviewers of my previous series (and others as well), I'd like to
draw attention to this one.

This is the follow up to the kmemcg-stack series, to be applied right
ontop. I believe the first series (kmemcg-stack) got more attention
(which is good), but this one got a bunch of fixes and reviews in the
process as well.

Thanks

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
