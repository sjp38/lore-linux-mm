Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id A77B96B000E
	for <linux-mm@kvack.org>; Wed, 18 Jul 2018 11:16:15 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id x2-v6so2161568pgv.7
        for <linux-mm@kvack.org>; Wed, 18 Jul 2018 08:16:15 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id n1-v6si3522060pge.57.2018.07.18.08.16.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Jul 2018 08:16:14 -0700 (PDT)
Subject: Re: [PATCH v2 2/7] mm/swapfile.c: Replace some #ifdef with
 IS_ENABLED()
References: <20180717005556.29758-1-ying.huang@intel.com>
 <20180717005556.29758-3-ying.huang@intel.com>
 <10878744-8db0-1d2c-e899-7c132d78e153@linux.intel.com>
 <877eltgr7f.fsf@yhuang-dev.intel.com>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <ec1c459d-4366-8134-59d3-bc48d9fc5acd@linux.intel.com>
Date: Wed, 18 Jul 2018 08:15:58 -0700
MIME-Version: 1.0
In-Reply-To: <877eltgr7f.fsf@yhuang-dev.intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, Dan Williams <dan.j.williams@intel.com>

On 07/17/2018 08:25 PM, Huang, Ying wrote:
>> Seriously, though, does it hurt us to add a comment or two to say
>> something like:
>>
>> 	/*
>> 	 * Should not even be attempting cluster allocations when
>> 	 * huge page swap is disabled.  Warn and fail the allocation.
>> 	 */
>> 	if (!IS_ENABLED(CONFIG_THP_SWAP)) {
>> 		VM_WARN_ON_ONCE(1);
>> 		return 0;
>> 	}
> I totally agree with you that we should add more comments for THP swap
> to improve the code readability.  As for this specific case,
> VM_WARN_ON_ONCE() here is just to capture some programming error during
> development.  Do we really need comments here?

If it's code in mainline, we need to know what it is doing.

If it's not useful to have in mainline, then let's remove it.
