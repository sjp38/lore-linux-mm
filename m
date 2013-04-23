Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id 0CAFD6B0032
	for <linux-mm@kvack.org>; Tue, 23 Apr 2013 14:17:33 -0400 (EDT)
Message-ID: <5176D024.5090007@parallels.com>
Date: Tue, 23 Apr 2013 11:17:08 -0700
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2] vmpressure: in-kernel notifications
References: <1366705329-9426-1-git-send-email-glommer@openvz.org> <1366705329-9426-2-git-send-email-glommer@openvz.org> <20130423171122.GA29983@teo>
In-Reply-To: <20130423171122.GA29983@teo>
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anton Vorontsov <anton@enomsg.org>
Cc: Glauber Costa <glommer@openvz.org>, linux-mm@kvack.org, cgroups@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, John Stultz <john.stultz@linaro.org>, Joonsoo Kim <js1304@gmail.com>, Michal Hocko <mhocko@suse.cz>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>

On 04/23/2013 10:11 AM, Anton Vorontsov wrote:
> On Tue, Apr 23, 2013 at 12:22:08PM +0400, Glauber Costa wrote:
>> From: Glauber Costa <glommer@parallels.com>
> [...]
>> This patch extends that to also support in-kernel users.
>
> Yup, that is the next logical step. ;-) The patches look good to me, just
> one question...
>
>> @@ -227,7 +233,7 @@ void vmpressure(gfp_t gfp, struct mem_cgroup *memcg,
>>   	 * we account it too.
>>   	 */
>>   	if (!(gfp & (__GFP_HIGHMEM | __GFP_MOVABLE | __GFP_IO | __GFP_FS)))
>
> I wonder if we want to let kernel users to specify the gfp mask here? The
> current mask is good for userspace notifications, but in-kernel users
> might be interested in including (or excluding) different types of
> allocations, e.g. watch only for DMA allocations pressure?
>

That is outside of the scope of this patch anyway. For this one, if you 
believe it is good, could I have your tag? =)

But answering your question regardless of the scope, I believe the 
context of the allocation is an implementation detail of the kernel - 
regardless of how widely understood it is. The thing I like the most 
about your work, is precisely the fact that is hides the implementation 
details so well.

So unless there is a strong use case that would benefit from it, I am 
inclined to say this is not wanted.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
