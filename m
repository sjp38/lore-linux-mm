Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 43BFB6B0069
	for <linux-mm@kvack.org>; Thu, 29 Dec 2016 02:50:08 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id u5so521888583pgi.7
        for <linux-mm@kvack.org>; Wed, 28 Dec 2016 23:50:08 -0800 (PST)
Received: from out4433.biz.mail.alibaba.com (out4433.biz.mail.alibaba.com. [47.88.44.33])
        by mx.google.com with ESMTP id m66si52616348pfc.209.2016.12.28.23.50.06
        for <linux-mm@kvack.org>;
        Wed, 28 Dec 2016 23:50:07 -0800 (PST)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <20161228153032.10821-1-mhocko@kernel.org> <20161228153032.10821-4-mhocko@kernel.org>
In-Reply-To: <20161228153032.10821-4-mhocko@kernel.org>
Subject: Re: [PATCH 3/7] mm, vmscan: show the number of skipped pages in mm_vmscan_lru_isolate
Date: Thu, 29 Dec 2016 15:49:45 +0800
Message-ID: <06d701d261a8$20082390$60186ab0$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Michal Hocko' <mhocko@kernel.org>, linux-mm@kvack.org
Cc: 'Andrew Morton' <akpm@linux-foundation.org>, 'Mel Gorman' <mgorman@suse.de>, 'Johannes Weiner' <hannes@cmpxchg.org>, 'Vlastimil Babka' <vbabka@suse.cz>, 'Rik van Riel' <riel@redhat.com>, 'LKML' <linux-kernel@vger.kernel.org>, 'Michal Hocko' <mhocko@suse.com>

On Wednesday, December 28, 2016 11:30 PM Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> mm_vmscan_lru_isolate shows the number of requested, scanned and taken
> pages. This is mostly OK but on 32b systems the number of scanned pages
> is quite misleading because it includes both the scanned and skipped
> pages.  Moreover the skipped part is scaled based on the number of taken
> pages. Let's report the exact numbers without any additional logic and
> add the number of skipped pages. This should make the reported data much
> more easier to interpret.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
