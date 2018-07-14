Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 40B6A6B0007
	for <linux-mm@kvack.org>; Sat, 14 Jul 2018 08:57:13 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id t10-v6so22407826pfh.0
        for <linux-mm@kvack.org>; Sat, 14 Jul 2018 05:57:13 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id q136-v6si24411050pgq.483.2018.07.14.05.57.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 14 Jul 2018 05:57:12 -0700 (PDT)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH 6/6] swap, put_swap_page: Share more between huge/normal code path
References: <20180712233636.20629-1-ying.huang@intel.com>
	<20180712233636.20629-7-ying.huang@intel.com>
	<20180713201858.zj43xzsnxqk3ozks@ca-dmjordan1.us.oracle.com>
Date: Sat, 14 Jul 2018 20:57:07 +0800
In-Reply-To: <20180713201858.zj43xzsnxqk3ozks@ca-dmjordan1.us.oracle.com>
	(Daniel Jordan's message of "Fri, 13 Jul 2018 13:18:58 -0700")
Message-ID: <87a7qudlgc.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Jordan <daniel.m.jordan@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dave Hansen <dave.hansen@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Dan Williams <dan.j.williams@intel.com>

Daniel Jordan <daniel.m.jordan@oracle.com> writes:

> On Fri, Jul 13, 2018 at 07:36:36AM +0800, Huang, Ying wrote:
>> From: Huang Ying <ying.huang@intel.com>
>> 
>> In this patch, locking related code is shared between huge/normal code
>> path in put_swap_page() to reduce code duplication.  And `free_entries
>> == 0` case is merged into more general `free_entries !=
>> SWAPFILE_CLUSTER` case, because the new locking method makes it easy.
>
> Might be a bit easier to think about the two changes if they were split up.

I just think the second change appears too trivial to be a separate patch.

> Agree with Dave's comment from patch 1, but otherwise the series looks ok to
> me.  I like the nr_swap_entries macro, that's clever.

Thanks!

Best Regards,
Huang, Ying
