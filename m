Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id 73D438D0020
	for <linux-mm@kvack.org>; Fri, 11 May 2012 14:22:13 -0400 (EDT)
Message-ID: <4FAD585A.4070007@parallels.com>
Date: Fri, 11 May 2012 15:20:10 -0300
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 04/29] slub: always get the cache from its page in
 kfree
References: <1336758272-24284-1-git-send-email-glommer@parallels.com> <1336758272-24284-5-git-send-email-glommer@parallels.com> <alpine.DEB.2.00.1205111251420.31049@router.home> <4FAD531D.6030007@parallels.com> <alpine.DEB.2.00.1205111305570.386@router.home> <4FAD566C.3000804@parallels.com> <alpine.DEB.2.00.1205111316540.386@router.home>
In-Reply-To: <alpine.DEB.2.00.1205111316540.386@router.home>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>, Greg Thelen <gthelen@google.com>, Suleiman Souhlal <suleiman@google.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, devel@openvz.org, Pekka Enberg <penberg@cs.helsinki.fi>

On 05/11/2012 03:17 PM, Christoph Lameter wrote:
> On Fri, 11 May 2012, Glauber Costa wrote:
>
>> On 05/11/2012 03:06 PM, Christoph Lameter wrote:
>>> On Fri, 11 May 2012, Glauber Costa wrote:
>>>
>>>>> Adding a VM_BUG_ON may be useful to make sure that kmem_cache_free is
>>>>> always passed the correct slab cache.
>>>>
>>>> Well, problem is , it isn't always passed the "correct" slab cache.
>>>> At least not after this series, since we'll have child caches associated
>>>> with
>>>> the main cache.
>>>>
>>>> So we'll pass, for instance, kmem_cache_free(dentry_cache...), but will in
>>>> fact free from the memcg copy of the dentry cache.
>>>
>>> Urg. But then please only do this for the MEMCG case and add a fat big
>>> warning in kmem_cache_free.
>>
>> I can do that, of course.
>> Another option if you don't oppose, is to add another field in the kmem_cache
>> structure (I tried to keep them at a minimum),
>> to record the parent cache we got created from.
>>
>> Then, it gets trivial to do the following:
>>
>> VM_BUG_ON(page->slab != s&&  page->slab != s->parent_cache);
>
> Sounds ok but I need to catch up on what this whole memcg thing in slab
> allocators should accomplish in order to say something definite.
>
Fair enough.

Thank you in advance for your time reviewing this!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
