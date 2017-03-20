Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id BD0AA6B0038
	for <linux-mm@kvack.org>; Sun, 19 Mar 2017 21:02:04 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id c87so179436239pfl.6
        for <linux-mm@kvack.org>; Sun, 19 Mar 2017 18:02:04 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id d10si6945178pln.75.2017.03.19.18.02.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 19 Mar 2017 18:02:03 -0700 (PDT)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH 4/5] mm, swap: Try kzalloc before vzalloc
In-Reply-To: <20170317114732.GF26298@dhcp22.suse.cz> (Michal Hocko's message
	of "Fri, 17 Mar 2017 12:47:33 +0100")
References: <20170317064635.12792-1-ying.huang@intel.com>
	<20170317064635.12792-4-ying.huang@intel.com>
	<20170317114732.GF26298@dhcp22.suse.cz>
Date: Mon, 20 Mar 2017 09:01:54 +0800
Message-ID: <87wpbk222l.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: "Huang, Ying" <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Shaohua Li <shli@kernel.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Tim Chen <tim.c.chen@linux.intel.com>, Mel Gorman <mgorman@techsingularity.net>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Jerome Glisse <jglisse@redhat.com>, Aaron Lu <aaron.lu@intel.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Ingo Molnar <mingo@kernel.org>, Vegard Nossum <vegard.nossum@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Michal Hocko <mhocko@kernel.org> writes:

> On Fri 17-03-17 14:46:22, Huang, Ying wrote:
>> +void *swap_kvzalloc(size_t size)
>> +{
>> +	void *p;
>> +
>> +	p = kzalloc(size, GFP_KERNEL | __GFP_NOWARN);
>> +	if (!p)
>> +		p = vzalloc(size);
>> +
>> +	return p;
>> +}
>
> please do not invent your own kvmalloc implementation when we already
> have on in mmotm tree.

Thanks for pointing that out!  I will use it.

Best Regards,
Huang, Ying

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
