Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id CAB626B0038
	for <linux-mm@kvack.org>; Fri, 17 Mar 2017 07:47:39 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id y90so13438290wrb.1
        for <linux-mm@kvack.org>; Fri, 17 Mar 2017 04:47:39 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c46si10830452wra.299.2017.03.17.04.47.38
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 17 Mar 2017 04:47:38 -0700 (PDT)
Date: Fri, 17 Mar 2017 12:47:33 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 4/5] mm, swap: Try kzalloc before vzalloc
Message-ID: <20170317114732.GF26298@dhcp22.suse.cz>
References: <20170317064635.12792-1-ying.huang@intel.com>
 <20170317064635.12792-4-ying.huang@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170317064635.12792-4-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Shaohua Li <shli@kernel.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Tim Chen <tim.c.chen@linux.intel.com>, Mel Gorman <mgorman@techsingularity.net>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, Aaron Lu <aaron.lu@intel.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Ingo Molnar <mingo@kernel.org>, Vegard Nossum <vegard.nossum@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri 17-03-17 14:46:22, Huang, Ying wrote:
> +void *swap_kvzalloc(size_t size)
> +{
> +	void *p;
> +
> +	p = kzalloc(size, GFP_KERNEL | __GFP_NOWARN);
> +	if (!p)
> +		p = vzalloc(size);
> +
> +	return p;
> +}

please do not invent your own kvmalloc implementation when we already
have on in mmotm tree.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
