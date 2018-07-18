Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4830E6B0006
	for <linux-mm@kvack.org>; Tue, 17 Jul 2018 23:26:11 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id c13-v6so1576785pfo.14
        for <linux-mm@kvack.org>; Tue, 17 Jul 2018 20:26:11 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id z28-v6si2596180pfa.161.2018.07.17.20.26.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Jul 2018 20:26:10 -0700 (PDT)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH v2 2/7] mm/swapfile.c: Replace some #ifdef with IS_ENABLED()
References: <20180717005556.29758-1-ying.huang@intel.com>
	<20180717005556.29758-3-ying.huang@intel.com>
	<10878744-8db0-1d2c-e899-7c132d78e153@linux.intel.com>
Date: Wed, 18 Jul 2018 11:25:56 +0800
In-Reply-To: <10878744-8db0-1d2c-e899-7c132d78e153@linux.intel.com> (Dave
	Hansen's message of "Tue, 17 Jul 2018 11:32:48 -0700")
Message-ID: <877eltgr7f.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, Dan Williams <dan.j.williams@intel.com>

Dave Hansen <dave.hansen@linux.intel.com> writes:

>> @@ -878,6 +877,11 @@ static int swap_alloc_cluster(struct swap_info_struct *si, swp_entry_t *slot)
>>  	unsigned long offset, i;
>>  	unsigned char *map;
>>  
>> +	if (!IS_ENABLED(CONFIG_THP_SWAP)) {
>> +		VM_WARN_ON_ONCE(1);
>> +		return 0;
>> +	}
>
> I see you seized the opportunity to keep this code gloriously
> unencumbered by pesky comments.  This seems like a time when you might
> have slipped up and been temped to add a comment or two.  Guess not. :)
>
> Seriously, though, does it hurt us to add a comment or two to say
> something like:
>
> 	/*
> 	 * Should not even be attempting cluster allocations when
> 	 * huge page swap is disabled.  Warn and fail the allocation.
> 	 */
> 	if (!IS_ENABLED(CONFIG_THP_SWAP)) {
> 		VM_WARN_ON_ONCE(1);
> 		return 0;
> 	}

I totally agree with you that we should add more comments for THP swap
to improve the code readability.  As for this specific case,
VM_WARN_ON_ONCE() here is just to capture some programming error during
development.  Do we really need comments here?

I will try to add more comments for other places in code regardless this
one.

Best Regards,
Huang, Ying
