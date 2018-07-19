Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8EAB16B0005
	for <linux-mm@kvack.org>; Thu, 19 Jul 2018 00:42:28 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id m25-v6so3000159pgv.22
        for <linux-mm@kvack.org>; Wed, 18 Jul 2018 21:42:28 -0700 (PDT)
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id r191-v6si5421983pfr.152.2018.07.18.21.42.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Jul 2018 21:42:25 -0700 (PDT)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH v2 2/7] mm/swapfile.c: Replace some #ifdef with IS_ENABLED()
References: <20180717005556.29758-1-ying.huang@intel.com>
	<20180717005556.29758-3-ying.huang@intel.com>
	<10878744-8db0-1d2c-e899-7c132d78e153@linux.intel.com>
	<877eltgr7f.fsf@yhuang-dev.intel.com>
	<ec1c459d-4366-8134-59d3-bc48d9fc5acd@linux.intel.com>
Date: Thu, 19 Jul 2018 12:42:14 +0800
In-Reply-To: <ec1c459d-4366-8134-59d3-bc48d9fc5acd@linux.intel.com> (Dave
	Hansen's message of "Wed, 18 Jul 2018 08:15:58 -0700")
Message-ID: <87wotr6dll.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, Dan Williams <dan.j.williams@intel.com>

Dave Hansen <dave.hansen@linux.intel.com> writes:

> On 07/17/2018 08:25 PM, Huang, Ying wrote:
>>> Seriously, though, does it hurt us to add a comment or two to say
>>> something like:
>>>
>>> 	/*
>>> 	 * Should not even be attempting cluster allocations when
>>> 	 * huge page swap is disabled.  Warn and fail the allocation.
>>> 	 */
>>> 	if (!IS_ENABLED(CONFIG_THP_SWAP)) {
>>> 		VM_WARN_ON_ONCE(1);
>>> 		return 0;
>>> 	}
>> I totally agree with you that we should add more comments for THP swap
>> to improve the code readability.  As for this specific case,
>> VM_WARN_ON_ONCE() here is just to capture some programming error during
>> development.  Do we really need comments here?
>
> If it's code in mainline, we need to know what it is doing.
>
> If it's not useful to have in mainline, then let's remove it.

OK.  Will add the comments.

Best Regards,
Huang, Ying
