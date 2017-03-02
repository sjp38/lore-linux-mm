Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id E8F2C6B0387
	for <linux-mm@kvack.org>; Wed,  1 Mar 2017 22:36:36 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id u62so69700583pfk.1
        for <linux-mm@kvack.org>; Wed, 01 Mar 2017 19:36:36 -0800 (PST)
Received: from out0-137.mail.aliyun.com (out0-137.mail.aliyun.com. [140.205.0.137])
        by mx.google.com with ESMTP id b1si6295098pld.307.2017.03.01.19.36.35
        for <linux-mm@kvack.org>;
        Wed, 01 Mar 2017 19:36:36 -0800 (PST)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <20170228214007.5621-1-hannes@cmpxchg.org> <20170228214007.5621-9-hannes@cmpxchg.org>
In-Reply-To: <20170228214007.5621-9-hannes@cmpxchg.org>
Subject: Re: [PATCH 8/9] Revert "mm, vmscan: account for skipped pages as a partial scan"
Date: Thu, 02 Mar 2017 11:36:31 +0800
Message-ID: <078301d29306$2f3f9a70$8dbecf50$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Johannes Weiner' <hannes@cmpxchg.org>, 'Andrew Morton' <akpm@linux-foundation.org>
Cc: 'Jia He' <hejianet@gmail.com>, 'Michal Hocko' <mhocko@suse.cz>, 'Mel Gorman' <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On March 01, 2017 5:40 AM Johannes Weiner wrote: 
>  
> This reverts commit d7f05528eedb047efe2288cff777676b028747b6.
> 
> Now that reclaimability of a node is no longer based on the ratio
> between pages scanned and theoretically reclaimable pages, we can
> remove accounting tricks for pages skipped due to zone constraints.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> ---
Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
