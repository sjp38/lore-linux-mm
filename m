Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 212546B0389
	for <linux-mm@kvack.org>; Thu, 23 Feb 2017 08:31:47 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id r18so7185952wmd.1
        for <linux-mm@kvack.org>; Thu, 23 Feb 2017 05:31:47 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d12si6106850wrb.170.2017.02.23.05.31.45
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 23 Feb 2017 05:31:46 -0800 (PST)
Date: Thu, 23 Feb 2017 14:31:44 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: + mm-vmscan-do-not-pass-reclaimed-slab-to-vmpressure.patch added
 to -mm tree
Message-ID: <20170223133144.GA29056@dhcp22.suse.cz>
References: <58a38a94.nb3wSoo24sv+3Kju%akpm@linux-foundation.org>
 <20170222104303.GH5753@dhcp22.suse.cz>
 <4378f15c-91fa-2ad1-4c32-2fce11262ef3@codeaurora.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4378f15c-91fa-2ad1-4c32-2fce11262ef3@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vinayak Menon <vinmenon@codeaurora.org>
Cc: akpm@linux-foundation.org, anton.vorontsov@linaro.org, hannes@cmpxchg.org, mgorman@techsingularity.net, minchan@kernel.org, riel@redhat.com, shashim@codeaurora.org, vbabka@suse.cz, vdavydov.dev@gmail.com, mm-commits@vger.kernel.org, linux-mm@kvack.org

On Thu 23-02-17 14:31:51, Vinayak Menon wrote:
> 
> On 2/22/2017 4:13 PM, Michal Hocko wrote:
[...]
> > - the changelog doesn't mention that the test case basically benefits
> >   from as many lmk interventions as possible. Does this represent a real
> >   life workload? If not is there any real life workload which would
> >   benefit from the new behavior.
>
> The use case does not actually benefit from as many lmk interventions
> as possible. Because it has to also take care of maximizing the number
> of applications sustained. 

exactly and that is why I am questioning a more pessimistic events. LMK
is a disruptive action so reporting critical actions too early can have
negative impact.

> IMHO Android using a vmpressure based user
> space lowmemorykiller is a real life workload. But the lowmemorykiller
> killer example was just to show the difference in vmpressure events
> between 2 kernel versions. Any workload which uses vmpressure would
> be something similar ? It would take an action by killing tasks, or
> releasing some buffers etc as I understand. The patch was actually
> meant to fix the addition of noise to vmpressure by adding reclaimed
> without accounting the cost and the lmk example was just to indicate
> the difference in vmpressure events.

OK, it seems I have to repeat myself again. So what is the advantage of
getting more pessimistic events and potentially fire disruptive actions
sooner while we could still reclaim slab? Who is going to benefit from
this except from the initial test case which, we agreed, is artificial?
Why does the "noise" even matter?

I am sorry but this whole change smells like "let's fix the test case"
rather than "let's think what the real life use cases will benefit from"
to me. As I've said I will not block this change because the cost model
is so fuzzy that one way or another there will always be somebody
complaining about it... So please, at least, make sure that somebody
hunting a vmpressure misbehavior know why this has been changed! If this
really is a test case motivated change then I would encourage you to
withdraw this patch and instead try to think how to make the vmpressure
more robust.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
