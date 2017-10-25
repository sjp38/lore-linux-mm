Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id CFB466B0033
	for <linux-mm@kvack.org>; Tue, 24 Oct 2017 22:32:57 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id 15so8410694pgc.16
        for <linux-mm@kvack.org>; Tue, 24 Oct 2017 19:32:57 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id s1si1074488pge.122.2017.10.24.19.32.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Oct 2017 19:32:55 -0700 (PDT)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH -mm] mm, swap: Fix false error message in __swp_swapcount()
References: <20171024024700.23679-1-ying.huang@intel.com>
	<20171024201708.GA25022@bgram>
Date: Wed, 25 Oct 2017 10:32:52 +0800
In-Reply-To: <20171024201708.GA25022@bgram> (Minchan Kim's message of "Wed, 25
	Oct 2017 05:17:08 +0900")
Message-ID: <8737686jor.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: "Huang, Ying" <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Tim Chen <tim.c.chen@linux.intel.com>, Michal Hocko <mhocko@suse.com>, stable@vger.kernel.org, Christian Kujau <lists@nerdbynature.de>

Minchan Kim <minchan@kernel.org> writes:

> On Tue, Oct 24, 2017 at 10:47:00AM +0800, Huang, Ying wrote:
>> From: Ying Huang <ying.huang@intel.com>
>> 
>> __swp_swapcount() is used in __read_swap_cache_async().  Where the
>> invalid swap entry (offset > max) may be supplied during swap
>> readahead.  But __swp_swapcount() will print error message for these
>> expected invalid swap entry as below, which will make the users
>> confusing.
>> 
>>   swap_info_get: Bad swap offset entry 0200f8a7
>> 
>> So the swap entry checking code in __swp_swapcount() is changed to
>> avoid printing error message for it.  To avoid to duplicate code with
>> __swap_duplicate(), a new helper function named
>> __swap_info_get_silence() is added and invoked in both places.
>
> It's the problem caused by readahead, not __swap_info_get which is low-end
> primitive function. Instead, please fix high-end swapin_readahead to limit
> to last valid block as handling to avoid swap header which is special case,
> too.

Yes.  You are right, will send the new version.

Best Regards,
Huang, Ying

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
