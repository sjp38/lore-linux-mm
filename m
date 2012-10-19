Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id 55CB46B0062
	for <linux-mm@kvack.org>; Fri, 19 Oct 2012 05:10:46 -0400 (EDT)
Message-ID: <50811903.9000105@parallels.com>
Date: Fri, 19 Oct 2012 13:10:27 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v5 06/14] memcg: kmem controller infrastructure
References: <1350382611-20579-1-git-send-email-glommer@parallels.com> <1350382611-20579-7-git-send-email-glommer@parallels.com> <20121017151214.e3d2aa3b.akpm@linux-foundation.org> <507FC8E3.8020006@parallels.com> <alpine.DEB.2.00.1210181502270.30894@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1210181502270.30894@chino.kir.corp.google.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, cgroups@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, kamezawa.hiroyu@jp.fujitsu.com, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, devel@openvz.org, linux-kernel@vger.kernel.org, Pekka Enberg <penberg@cs.helsinki.fi>

On 10/19/2012 02:06 AM, David Rientjes wrote:
> On Thu, 18 Oct 2012, Glauber Costa wrote:
> 
>>> Do we actually need to test PF_KTHREAD when current->mm == NULL? 
>>> Perhaps because of aio threads whcih temporarily adopt a userspace mm?
>>
>> I believe so. I remember I discussed this in the past with David
>> Rientjes and he advised me to test for both.
>>
> 
> PF_KTHREAD can do use_mm() to assume an ->mm but hopefully they aren't 
> allocating slab while doing so.  Have you considered actually charging 
> current->mm->owner for that memory, though, since the kthread will have 
> freed the memory before unuse_mm() or otherwise have charged it on behalf 
> of a user process, i.e. only exempting PF_KTHREAD?
> 
I always charge current->mm->owner.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
