Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5454D6B0033
	for <linux-mm@kvack.org>; Mon,  6 Feb 2017 19:36:06 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id 194so126242580pgd.7
        for <linux-mm@kvack.org>; Mon, 06 Feb 2017 16:36:06 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id 9si2231800pfp.297.2017.02.06.16.36.04
        for <linux-mm@kvack.org>;
        Mon, 06 Feb 2017 16:36:05 -0800 (PST)
Date: Tue, 7 Feb 2017 09:33:36 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v6 1/4] mm/migration: make isolate_movable_page() return
 int type
Message-ID: <20170207003336.GB12188@bbox>
References: <1486108770-630-1-git-send-email-xieyisheng1@huawei.com>
 <1486108770-630-2-git-send-email-xieyisheng1@huawei.com>
MIME-Version: 1.0
In-Reply-To: <1486108770-630-2-git-send-email-xieyisheng1@huawei.com>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yisheng Xie <xieyisheng1@huawei.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, mhocko@kernel.org, ak@linux.intel.com, guohanjun@huawei.com, hannes@cmpxchg.org, iamjoonsoo.kim@lge.com, mgorman@techsingularity.net, n-horiguchi@ah.jp.nec.com, arbab@linux.vnet.ibm.com, izumi.taku@jp.fujitsu.com, vkuznets@redhat.com, vbabka@suse.cz, qiuxishi@huawei.com

On Fri, Feb 03, 2017 at 03:59:27PM +0800, Yisheng Xie wrote:
> Change the return type of isolate_movable_page() from bool to int.  It
> will return 0 when isolate movable page successfully, and return -EBUSY
> when it isolates failed.
> 
> There is no functional change within this patch but prepare for later
> patch.
> 
> Signed-off-by: Yisheng Xie <xieyisheng1@huawei.com>
> Suggested-by: Michal Hocko <mhocko@kernel.org>
> Suggested-by: Minchan Kim <minchan@kernel.org>
Acked-by: Minchan Kim <minchan@kernel.org>

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
