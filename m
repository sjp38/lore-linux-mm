Return-Path: <linux-kernel-owner@vger.kernel.org>
Message-ID: <5A4603AB.8060809@huawei.com>
Date: Fri, 29 Dec 2017 16:58:19 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: [RFC] mm: why vfree() do not free page table memory?
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: linux-kernel-owner@vger.kernel.org
To: Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>
Cc: LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Xishi Qiu <qiuxishi@huawei.com>, "Wujiangtao (A)" <wu.wujiangtao@huawei.com>
List-ID: <linux-mm.kvack.org>

When calling vfree(), it calls unmap_vmap_area() to clear page table,
but do not free the memory of page table, why? just for performance?

If a driver use vmalloc() and vfree() frequently, we will lost much
page table memory, maybe oom later.

Thanks,
Xishi Qiu
