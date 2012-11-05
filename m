Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id EFA796B0062
	for <linux-mm@kvack.org>; Mon,  5 Nov 2012 03:18:41 -0500 (EST)
Message-ID: <50977651.6060502@parallels.com>
Date: Mon, 5 Nov 2012 09:18:25 +0100
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v6 00/29] kmem controller for memcg.
References: <1351771665-11076-1-git-send-email-glommer@parallels.com> <20121101170454.b7713bce.akpm@linux-foundation.org> <50937918.7080302@parallels.com> <CAAmzW4O74e3J9M3Q86Y0wXX6Pfp8GDpv6jAB5ebJPHfAxAeL0Q@mail.gmail.com>
In-Reply-To: <CAAmzW4O74e3J9M3Q86Y0wXX6Pfp8GDpv6jAB5ebJPHfAxAeL0Q@mail.gmail.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: JoonSoo Kim <js1304@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@suse.cz>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Greg Thelen <gthelen@google.com>

On 11/02/2012 08:25 PM, JoonSoo Kim wrote:
> Hello, Glauber.
> 
> 2012/11/2 Glauber Costa <glommer@parallels.com>:
>> On 11/02/2012 04:04 AM, Andrew Morton wrote:
>>> On Thu,  1 Nov 2012 16:07:16 +0400
>>> Glauber Costa <glommer@parallels.com> wrote:
>>>
>>>> Hi,
>>>>
>>>> This work introduces the kernel memory controller for memcg. Unlike previous
>>>> submissions, this includes the whole controller, comprised of slab and stack
>>>> memory.
>>>
>>> I'm in the middle of (re)reading all this.  Meanwhile I'll push it all
>>> out to http://ozlabs.org/~akpm/mmots/ for the crazier testers.
>>>
>>> One thing:
>>>
>>>> Numbers can be found at https://lkml.org/lkml/2012/9/13/239
>>>
>>> You claim in the above that the fork worload is 'slab intensive".  Or
>>> at least, you seem to - it's a bit fuzzy.
>>>
>>> But how slab intensive is it, really?
>>>
>>> What is extremely slab intensive is networking.  The networking guys
>>> are very sensitive to slab performance.  If this hasn't already been
>>> done, could you please determine what impact this has upon networking?
>>> I expect Eric Dumazet, Dave Miller and Tom Herbert could suggest
>>> testing approaches.
>>>
>>
>> I can test it, but unfortunately I am unlikely to get to prepare a good
>> environment before Barcelona.
>>
>> I know, however, that Greg Thelen was testing netperf in his setup.
>> Greg, do you have any publishable numbers you could share?
> 
> Below is my humble opinion.
> I am worrying about data cache footprint which is possibly caused by
> this patchset, especially slab implementation.
> If there are several memcg cgroups, each cgroup has it's own kmem_caches.

I answered the performance part in response to Tejun's response.

Let me just add something here: Just keep in mind this is not "per
memcg", this is "per memcg that are kernel-memory limited". So in a
sense, you are only paying this, and allocate from different caches, if
you runtime enable this.

This should all be documented in the Documentation/ patch. But let me
know if there is anything that needs further clarification

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
