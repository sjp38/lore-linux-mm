Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id 1C7AF8D0020
	for <linux-mm@kvack.org>; Fri, 11 May 2012 15:00:52 -0400 (EDT)
Message-ID: <4FAD6169.8090409@parallels.com>
Date: Fri, 11 May 2012 15:58:49 -0300
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 04/29] slub: always get the cache from its page in
 kfree
References: <1336758272-24284-1-git-send-email-glommer@parallels.com> <1336758272-24284-5-git-send-email-glommer@parallels.com> <alpine.DEB.2.00.1205111251420.31049@router.home> <4FAD531D.6030007@parallels.com> <alpine.DEB.2.00.1205111305570.386@router.home> <4FAD566C.3000804@parallels.com> <alpine.DEB.2.00.1205111316540.386@router.home> <4FAD585A.4070007@parallels.com> <alpine.DEB.2.00.1205111331010.386@router.home> <4FAD5DA2.70803@parallels.com> <alpine.DEB.2.00.1205111354540.386@router.home>
In-Reply-To: <alpine.DEB.2.00.1205111354540.386@router.home>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>, Greg Thelen <gthelen@google.com>, Suleiman Souhlal <suleiman@google.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, devel@openvz.org, Pekka Enberg <penberg@cs.helsinki.fi>

On 05/11/2012 03:56 PM, Christoph Lameter wrote:
> On Fri, 11 May 2012, Glauber Costa wrote:
>
>> So we don't mix pages from multiple memcgs in the same cache - we believe that
>> would be too confusing.
>
> Well subsystem create caches and other things that are shared between
> multiple processes. How can you track that?

Each process that belongs to a memcg triggers the creation of a new 
child kmem cache.

>> /proc/slabinfo reflects this information, by listing the memcg-specific slabs.
>
> What about /sys/kernel/slab/*?

 From the PoV of the global system, what you'll see is something like:
dentry , dentry(2:memcg1), dentry(2:memcg2), etc.

No attempt is made to provide any view of those caches in a logically 
grouped way - the global system can view them independently.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
