Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f180.google.com (mail-lb0-f180.google.com [209.85.217.180])
	by kanga.kvack.org (Postfix) with ESMTP id 9608D6B0071
	for <linux-mm@kvack.org>; Tue, 26 Nov 2013 07:55:53 -0500 (EST)
Received: by mail-lb0-f180.google.com with SMTP id w6so4304424lbh.39
        for <linux-mm@kvack.org>; Tue, 26 Nov 2013 04:55:52 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id k8si4496407lag.19.2013.11.26.04.55.51
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 26 Nov 2013 04:55:51 -0800 (PST)
Message-ID: <52949A4F.7030004@parallels.com>
Date: Tue, 26 Nov 2013 16:55:43 +0400
From: Vladimir Davydov <vdavydov@parallels.com>
MIME-Version: 1.0
Subject: Re: [Devel] [PATCH v11 00/15] kmemcg shrinkers
References: <cover.1385377616.git.vdavydov@parallels.com> <20131125174135.GE22729@cmpxchg.org> <529443E4.7080602@parallels.com>
In-Reply-To: <529443E4.7080602@parallels.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-kernel@vger.kernel.org, glommer@openvz.org, mhocko@suse.cz, linux-mm@kvack.org, cgroups@vger.kernel.org, akpm@linux-foundation.org, devel@openvz.org

On 11/26/2013 10:47 AM, Vladimir Davydov wrote:
> Hi,
>
> Thank you for the review. I agree with all your comments and I'll 
> resend the fixed version soon.
>
> If anyone still has something to say about the patchset, I'd be glad 
> to hear from them.
>
> On 11/25/2013 09:41 PM, Johannes Weiner wrote:
>> I ran out of steam reviewing these because there were too many things
>> that should be changed in the first couple patches.
>>
>> I realize this is frustrating to see these type of complaints in v11
>> of a patch series, but the review bandwidth was simply exceeded back
>> when Glauber submitted this along with the kmem accounting patches.  A
>> lot of the kmemcg commits themselves don't even have review tags or
>> acks, but it all got merged anyway, and the author has moved on to
>> different projects...
>>
>> Too much stuff slips past the only two people that have more than one
>> usecase on their agenda and are willing to maintain this code base -
>> which is in desparate need of rework and pushback against even more
>> drive-by feature dumps.  I have repeatedly asked to split the memcg
>> tree out of the memory tree to better deal with the vastly different
>> developmental stages of memcg and the rest of the mm code, to no
>> avail.  So I don't know what to do anymore, but this is not working.
>>
>> Thoughts?
>
> That's a pity, because w/o this patchset kmemcg is in fact useless. 
> Perhaps, it's worth trying to split it? (not sure if it'll help much 
> though since first 11 patches are rather essential :-( )

What do you think about splitting this set into two main series as follows:

1) Prepare vmscan to kmemcg-aware shrinkers; would include patches 1-7 
of this set.
2) Make fs shrinkers memcg-aware; would include patches 9-11 of this set

and leave other patches, which are rather for optimization/extending 
functionality, for future?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
