Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id DB74F8E0038
	for <linux-mm@kvack.org>; Wed,  9 Jan 2019 05:15:54 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id c18so2691207edt.23
        for <linux-mm@kvack.org>; Wed, 09 Jan 2019 02:15:54 -0800 (PST)
Received: from outbound-smtp16.blacknight.com (outbound-smtp16.blacknight.com. [46.22.139.233])
        by mx.google.com with ESMTPS id o1-v6si1114941eji.22.2019.01.09.02.15.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Jan 2019 02:15:53 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail06.blacknight.ie [81.17.255.152])
	by outbound-smtp16.blacknight.com (Postfix) with ESMTPS id 189161C28C6
	for <linux-mm@kvack.org>; Wed,  9 Jan 2019 10:15:53 +0000 (GMT)
Date: Wed, 9 Jan 2019 10:15:51 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH -next] mm, compaction: remove set but not used variables
 'a, b, c'
Message-ID: <20190109101551.GR31517@techsingularity.net>
References: <1547002967-6127-1-git-send-email-yuehaibing@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1547002967-6127-1-git-send-email-yuehaibing@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: YueHaibing <yuehaibing@huawei.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Stephen Rothwell <sfr@canb.auug.org.au>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org

On Wed, Jan 09, 2019 at 03:02:47AM +0000, YueHaibing wrote:
> Fixes gcc '-Wunused-but-set-variable' warning:
> 
> mm/compaction.c: In function 'compact_zone':
> mm/compaction.c:2063:22: warning:
>  variable 'c' set but not used [-Wunused-but-set-variable]
> mm/compaction.c:2063:19: warning:
>  variable 'b' set but not used [-Wunused-but-set-variable]
> mm/compaction.c:2063:16: warning:
>  variable 'a' set but not used [-Wunused-but-set-variable]
> 
> This never used since 94d5992baaa5 ("mm, compaction: finish pageblock
> scanning on contention")
> 

Dang. This is left-over debugging code that got accidentally merged
during a rebase.  Andrew, can you pick this up as a fix to the mmotm
patch mm-compaction-finish-pageblock-scanning-on-contention.patch please?

Thanks YueHaibing.

-- 
Mel Gorman
SUSE Labs
