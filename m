Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id EBABF6B010B
	for <linux-mm@kvack.org>; Thu, 23 Feb 2012 09:02:03 -0500 (EST)
Received: by bkty12 with SMTP id y12so1381206bkt.14
        for <linux-mm@kvack.org>; Thu, 23 Feb 2012 06:02:02 -0800 (PST)
Message-ID: <4F4646D6.6070900@openvz.org>
Date: Thu, 23 Feb 2012 18:01:58 +0400
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
MIME-Version: 1.0
Subject: Re: [PATCH v2 00/22] mm: lru_lock splitting
References: <20120220171138.22196.65847.stgit@zurg> <m2boor33g8.fsf@firstfloor.org> <4F447904.90500@openvz.org> <20120222061618.GT7703@one.firstfloor.org>
In-Reply-To: <20120222061618.GT7703@one.firstfloor.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Hugh Dickins <hughd@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "tim.c.chen@linux.intel.com" <tim.c.chen@linux.intel.com>

Andi Kleen wrote:
> On Wed, Feb 22, 2012 at 09:11:32AM +0400, Konstantin Khlebnikov wrote:
>> Andi Kleen wrote:
>>> Konstantin Khlebnikov<khlebnikov@openvz.org>   writes:
>>>
>>> Konstantin,
>>>
>>>> There complete patch-set with my lru_lock splitting
>>>> plus all related preparations and cleanups rebased to next-20120210
>>>
>>> On large systems we're also seeing lock contention on the lru_lock
>>> without using memcgs. Any thoughts how this could be extended for this
>>> situation too?
>>
>> We can split lru_lock by pfn-based interleaving.
>> After all these cleanups it is very easy. I already have patch for this.
>
> Cool. If you send it can try it out on a large system.

See last patch in v3 patchset in lkml or in
git: https://github.com/koct9i/linux/commits/lruvec-v3

>
> This would split the LRU by pfn too, correct?

Of course, I don't see any problems with splitting large zone into some
independent pages subsets. But all sub-pages in huge-page should be in one lru,
that's why I use pfn-based interleaving.

>
> -Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
