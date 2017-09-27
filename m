Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 55B526B0069
	for <linux-mm@kvack.org>; Tue, 26 Sep 2017 21:36:43 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id i130so24259019pgc.5
        for <linux-mm@kvack.org>; Tue, 26 Sep 2017 18:36:43 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id p84si6444503pfi.246.2017.09.26.18.36.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Sep 2017 18:36:42 -0700 (PDT)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH] mm, swap: Make VMA based swap readahead configurable
References: <20170921013310.31348-1-ying.huang@intel.com>
	<20170926132129.dbtr2mof35x4j4og@dhcp22.suse.cz>
Date: Wed, 27 Sep 2017 09:36:39 +0800
In-Reply-To: <20170926132129.dbtr2mof35x4j4og@dhcp22.suse.cz> (Michal Hocko's
	message of "Tue, 26 Sep 2017 15:21:29 +0200")
Message-ID: <87shf8c47s.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Minchan Kim <minchan@kernel.org>
Cc: "Huang, Ying" <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Fengguang Wu <fengguang.wu@intel.com>, Tim Chen <tim.c.chen@intel.com>, Dave Hansen <dave.hansen@intel.com>

Michal Hocko <mhocko@kernel.org> writes:

> On Thu 21-09-17 09:33:10, Huang, Ying wrote:
>> From: Huang Ying <ying.huang@intel.com>
>> 
>> This patch adds a new Kconfig option VMA_SWAP_READAHEAD and wraps VMA
>> based swap readahead code inside #ifdef CONFIG_VMA_SWAP_READAHEAD/#endif.
>> This is more friendly for tiny kernels.
>
> How (much)?

OK.  I will measure it.

>> And as pointed to by Minchan
>> Kim, give people who want to disable the swap readahead an opportunity
>> to notice the changes to the swap readahead algorithm and the
>> corresponding knobs.
>
> Why would anyone want that?
>
> Please note that adding new config options make the already complicated
> config space even more problematic so there should be a good reason to
> add one. Please make sure your justification is clear on why this is
> worth the future maintenance and configurability burden.

Hi, Minchan,

Could you give more information on this?

Best Regards,
Huang, Ying

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
