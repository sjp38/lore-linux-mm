Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 30CD76B0003
	for <linux-mm@kvack.org>; Tue,  7 Aug 2018 14:24:04 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id v24-v6so23760wmh.5
        for <linux-mm@kvack.org>; Tue, 07 Aug 2018 11:24:04 -0700 (PDT)
Received: from Chamillionaire.breakpoint.cc (Chamillionaire.breakpoint.cc. [2a01:7a0:2:106d:670::1])
        by mx.google.com with ESMTPS id v15-v6si1439027wrm.86.2018.08.07.11.24.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 07 Aug 2018 11:24:02 -0700 (PDT)
Date: Tue, 7 Aug 2018 20:23:55 +0200
From: Florian Westphal <fw@strlen.de>
Subject: Re: [Bug 200651] New: cgroups iptables-restor: vmalloc: allocation
 failure
Message-ID: <20180807182355.yjbq3vixnvmajavr@breakpoint.cc>
References: <89ea4f56-6253-4f51-0fb7-33d7d4b60cfa@icdsoft.com>
 <20180730183820.GA24267@dhcp22.suse.cz>
 <56597af4-73c6-b549-c5d5-b3a2e6441b8e@icdsoft.com>
 <6838c342-2d07-3047-e723-2b641bc6bf79@suse.cz>
 <8105b7b3-20d3-5931-9f3c-2858021a4e12@icdsoft.com>
 <20180731140520.kpotpihqsmiwhh7l@breakpoint.cc>
 <e5b24629-0296-5a4d-577a-c25d1c52b03b@suse.cz>
 <20180801083349.GF16767@dhcp22.suse.cz>
 <e5c5e965-a6bc-d61f-97fc-78da287b5d94@icdsoft.com>
 <20180802085043.GC10808@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180802085043.GC10808@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Georgi Nikolov <gnikolov@icdsoft.com>, Vlastimil Babka <vbabka@suse.cz>, Florian Westphal <fw@strlen.de>, Andrew Morton <akpm@linux-foundation.org>, bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org, netfilter-devel@vger.kernel.org

Michal Hocko <mhocko@kernel.org> wrote:
> Subject: [PATCH] netfilter/x_tables: do not fail xt_alloc_table_info too
>  easilly

[..]

> -	/* __GFP_NORETRY is not fully supported by kvmalloc but it should
> -	 * work reasonably well if sz is too large and bail out rather
> -	 * than shoot all processes down before realizing there is nothing
> -	 * more to reclaim.
> -	 */
> -	info = kvmalloc(sz, GFP_KERNEL | __GFP_NORETRY);
> +	info = kvmalloc(sz, GFP_KERNEL | __GFP_ACCOUNT);
>  	if (!info)
>  		return NULL;

Acked-by: Florian Westphal <fw@strlen.de>

You can keep this acked-by in case you mangle this patch in a minor
way such as using GFP_KERNEL_ACCOUNT.

Thanks,
Florian
