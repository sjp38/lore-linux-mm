Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 02B8A6B0036
	for <linux-mm@kvack.org>; Tue, 29 Jul 2014 17:04:54 -0400 (EDT)
Received: by mail-pd0-f181.google.com with SMTP id g10so241956pdj.26
        for <linux-mm@kvack.org>; Tue, 29 Jul 2014 14:04:54 -0700 (PDT)
Received: from na01-by2-obe.outbound.protection.outlook.com (mail-by2lp0244.outbound.protection.outlook.com. [207.46.163.244])
        by mx.google.com with ESMTPS id c4si47874pdk.312.2014.07.29.14.04.53
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 29 Jul 2014 14:04:53 -0700 (PDT)
Message-ID: <53D80C5A.4010605@amd.com>
Date: Wed, 30 Jul 2014 00:04:26 +0300
From: Oded Gabbay <oded.gabbay@amd.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/7] mmu_notifier: add call_srcu and sync function for
 listener to delay call and sync.
References: <1405622809-3797-1-git-send-email-j.glisse@gmail.com>
	<1405622809-3797-2-git-send-email-j.glisse@gmail.com>
	<53CD2B43.3090405@amd.com>	<53D7B800.6050700@amd.com>
 <20140729134803.8db34d88eda9209bda6069c7@linux-foundation.org>
In-Reply-To: <20140729134803.8db34d88eda9209bda6069c7@linux-foundation.org>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, j.glisse@gmail.com, Linus Torvalds <torvalds@linux-foundation.org>, joro@8bytes.org, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind
 Gopalakrishnan <arvindg@nvidia.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, Ben Sander <ben.sander@amd.com>, Greg Stoner <Greg.Stoner@amd.com>, John
 Bridgman <John.Bridgman@amd.com>, Michael Mantor <Michael.Mantor@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Laurent Morichetti <Laurent.Morichetti@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, =?UTF-8?B?SsOpcsO0bWUgR2xp?= =?UTF-8?B?c3Nl?= <jglisse@redhat.com>

On 29/07/14 23:48, Andrew Morton wrote:
> On Tue, 29 Jul 2014 18:04:32 +0300 Oded Gabbay <oded.gabbay@amd.com> wrote:
> 
>> On 21/07/14 18:01, Oded Gabbay wrote:
>>> On 17/07/14 21:46, j.glisse@gmail.com wrote:
>>>> From: Peter Zijlstra <peterz@infradead.org>
>>>>
>>>> New mmu_notifier listener are eager to cleanup there structure after the
>>>> mmu_notifier::release callback. In order to allow this the patch provide
>>>> a function that allows to add a delayed call to the mmu_notifier srcu. It
>>>> also add a function that will call barrier_srcu so those listener can sync
>>>> with mmu_notifier.
>>>
>>> Tested with amdkfd and iommuv2 driver
>>> So,
>>> Tested-by: Oded Gabbay <oded.gabbay@amd.com>
>>
>> akpm, any chance that only this specific patch from Peter.Z will get in 3.17 ?
>> I must have it for amdkfd (HSA driver). Without it, I can't be in 3.17 either.
> 
> I can send it in for 3.17-rc1.
> 
> Can we get a better changelog please?  "eager to cleanup there
> structure after the mmu_notifier::release callback" is terribly vague
> and brief.  Fully describe the problem then describe the proposed
> solution.  Because others may be able to suggest alternative ways of
> solving that problem, but this text simply doesn't provide enough details for
> them to do so.
> 

Thank you :)

I will fix the commit msg and I will submit this patch as part of my v3
patch set of amdkfd (this will be the first patch of the set). I'm going
to publish it in a few days (I guess on Friday). You are also on the
amdkfd patch set list, so you will get the v3 as well.

	Oded

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
