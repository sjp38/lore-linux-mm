Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id 9DAE76B002B
	for <linux-mm@kvack.org>; Fri, 21 Sep 2012 05:47:11 -0400 (EDT)
Message-ID: <505C36D4.60303@parallels.com>
Date: Fri, 21 Sep 2012 13:43:48 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3 00/16] slab accounting for memcg
References: <1347977530-29755-1-git-send-email-glommer@parallels.com> <CAOJsxLFVMYUxoVOcaCAtvwZmyMHS9mB3msP8gHn0a6NqzneLqQ@mail.gmail.com>
In-Reply-To: <CAOJsxLFVMYUxoVOcaCAtvwZmyMHS9mB3msP8gHn0a6NqzneLqQ@mail.gmail.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, devel@openvz.org, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, Suleiman Souhlal <suleiman@google.com>, Frederic Weisbecker <fweisbec@gmail.com>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>

On 09/21/2012 01:40 PM, Pekka Enberg wrote:
> Hi Glauber,
> 
> On Tue, Sep 18, 2012 at 5:11 PM, Glauber Costa <glommer@parallels.com> wrote:
>> This is a followup to the previous kmem series. I divided them logically
>> so it gets easier for reviewers. But I believe they are ready to be merged
>> together (although we can do a two-pass merge if people would prefer)
>>
>> Throwaway git tree found at:
>>
>>         git://git.kernel.org/pub/scm/linux/kernel/git/glommer/memcg.git kmemcg-slab
>>
>> There are mostly bugfixes since last submission.
> 
> Overall, I like this series a lot. However, I don't really see this as a
> v3.7 material because we already have largeish pending updates to the
> slab allocators. I also haven't seen any performance numbers for this
> which is a problem.
> 
> So what I'd really like to see is this series being merged early in the
> v3.8 development cycle to maximize the number of people eyeballing the
> code and looking at performance impact.
> 
> Does this sound reasonable to you Glauber?

Absolutely.

As I've stated before, I actually believe the kmemcg-stack and
kmemcg-slab (this one) portions should be merged separately. (So we can
sort out issues more easily, and point to the right place)

The first one is a lot more stable and got a lot more love. The goal of
this one is to get it reviewed so we can merge as soon as we can - but
not sooner.

early v3.8 sounds perfect to me.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
