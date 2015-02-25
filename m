Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 7D3E16B0032
	for <linux-mm@kvack.org>; Wed, 25 Feb 2015 11:44:25 -0500 (EST)
Received: by pabkx10 with SMTP id kx10so6537249pab.0
        for <linux-mm@kvack.org>; Wed, 25 Feb 2015 08:44:25 -0800 (PST)
Received: from mail-pd0-x234.google.com (mail-pd0-x234.google.com. [2607:f8b0:400e:c02::234])
        by mx.google.com with ESMTPS id bn1si6627404pbb.257.2015.02.25.08.44.23
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Feb 2015 08:44:23 -0800 (PST)
Received: by pdev10 with SMTP id v10so5983203pde.10
        for <linux-mm@kvack.org>; Wed, 25 Feb 2015 08:44:23 -0800 (PST)
From: SeongJae Park <sj38.park@gmail.com>
Date: Thu, 26 Feb 2015 01:47:06 +0900 (KST)
Subject: Re: [RFC v2 0/5] introduce gcma
In-Reply-To: <20150225161158.GI26680@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.10.1502260119210.23105@hxeon>
References: <1424721263-25314-1-git-send-email-sj38.park@gmail.com> <20150224144804.GE15626@dhcp22.suse.cz> <alpine.DEB.2.10.1502251403390.23105@hxeon> <20150225161158.GI26680@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: SeongJae Park <sj38.park@gmail.com>, akpm@linux-foundation.org, lauraa@codeaurora.org, minchan@kernel.org, sergey.senozhatsky@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On Wed, 25 Feb 2015, Michal Hocko wrote:

> On Wed 25-02-15 14:31:08, SeongJae Park wrote:
>> Hello Michal,
>>
>> Thanks for your comment :)
>>
>> On Tue, 24 Feb 2015, Michal Hocko wrote:
>>
>>> On Tue 24-02-15 04:54:18, SeongJae Park wrote:
>>> [...]
>>>> include/linux/cma.h  |    4 +
>>>> include/linux/gcma.h |   64 +++
>>>> mm/Kconfig           |   24 +
>>>> mm/Makefile          |    1 +
>>>> mm/cma.c             |  113 ++++-
>>>> mm/gcma.c            | 1321 ++++++++++++++++++++++++++++++++++++++++++++++++++
>>>> 6 files changed, 1508 insertions(+), 19 deletions(-)
>>>> create mode 100644 include/linux/gcma.h
>>>> create mode 100644 mm/gcma.c
>>>
>>> Wow this is huge! And I do not see reason for it to be so big. Why
>>> cannot you simply define (per-cma area) 2-class users policy? Either via
>>> kernel command line or export areas to userspace and allow to set policy
>>> there.
>>
>> For implementation of the idea, we should develop not only policy selection,
>> but also backend for discardable memory. Most part of this patch were made
>> for the backend.
>
> What is the backend and why is it needed? I thought the discardable will
> go back to the CMA pool. I mean the cover email explained why the
> current CMA allocation policy might lead to lower success rate or
> stalls. So I would expect a new policy would be a relatively small
> change in the CMA allocation path to serve 2-class users as per policy.
> It is not clear to my why we need to pull a whole gcma layer in. I might
> be missing something obvious because I haven't looked at the patches yet
> but this should better be explained in the cover letter.

I meant backend for 2nd-class clients like cleancache and frontswap.
Because implementing backend for cleancache or frontswap is subsystem's
responsibility, gcma was needed to implement those backend. I believe
second ("gcma: utilize reserved memory as discardable memory") and
third ("gcma: adopt cleancache and frontswap as second-class
clients") could be helpful to understand about that.

And yes, I agree the explanation was not enough. My fault, sorry. My
explanation was too concentrated on policy itself. I should explained
about how the policy could be implemented and how gcma did. I will explain
about that in coverletter with next version.

Thanks for your helpful and nice comment.


Thanks,
SeongJae Park

>
> Thanks!
> -- 
> Michal Hocko
> SUSE Labs
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
