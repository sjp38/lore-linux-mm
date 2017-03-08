Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6CF22831D3
	for <linux-mm@kvack.org>; Wed,  8 Mar 2017 06:38:34 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id q126so52394689pga.0
        for <linux-mm@kvack.org>; Wed, 08 Mar 2017 03:38:34 -0800 (PST)
Received: from mail-pf0-x244.google.com (mail-pf0-x244.google.com. [2607:f8b0:400e:c00::244])
        by mx.google.com with ESMTPS id v26si3024234pfa.151.2017.03.08.03.38.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Mar 2017 03:38:33 -0800 (PST)
Received: by mail-pf0-x244.google.com with SMTP id v190so3545092pfb.0
        for <linux-mm@kvack.org>; Wed, 08 Mar 2017 03:38:33 -0800 (PST)
Message-ID: <1488973076.13674.5.camel@gmail.com>
Subject: Re: [PATCH -mm -v6 2/9] mm, memcg: Support to charge/uncharge
 multiple swap entries
From: Balbir Singh <bsingharora@gmail.com>
Date: Wed, 08 Mar 2017 22:37:56 +1100
In-Reply-To: <20170308072613.17634-3-ying.huang@intel.com>
References: <20170308072613.17634-1-ying.huang@intel.com>
	 <20170308072613.17634-3-ying.huang@intel.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Vladimir Davydov <vdavydov@virtuozzo.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Tejun Heo <tj@kernel.org>, cgroups@vger.kernel.org

On Wed, 2017-03-08 at 15:26 +0800, Huang, Ying wrote:
> From: Huang Ying <ying.huang@intel.com>
>A 
> This patch make it possible to charge or uncharge a set of continuous
> swap entries in the swap cgroup.A A The number of swap entries is
> specified via an added parameter.
>A 
> This will be used for the THP (Transparent Huge Page) swap support.
> Where a swap cluster backing a THP may be allocated and freed as a
> whole.A A So a set of (HPAGE_PMD_NR) continuous swap entries backing one
> THP need to be charged or uncharged together.A A This will batch the
> cgroup operations for the THP swap too.

A quick look at the patches makes it look sane. I wonder if we would
make sense to track THP swapout separately as well
(from a memory.stat perspective)

Balbir Singh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
