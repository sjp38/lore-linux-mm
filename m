Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 054C86B0260
	for <linux-mm@kvack.org>; Mon, 16 Jan 2017 22:40:36 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id 194so109829286pgd.7
        for <linux-mm@kvack.org>; Mon, 16 Jan 2017 19:40:35 -0800 (PST)
Received: from out0-132.mail.aliyun.com (out0-132.mail.aliyun.com. [140.205.0.132])
        by mx.google.com with ESMTP id c1si23523419pld.50.2017.01.16.19.40.34
        for <linux-mm@kvack.org>;
        Mon, 16 Jan 2017 19:40:35 -0800 (PST)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <20170116160123.GB30300@cmpxchg.org> <20170116193317.20390-1-mhocko@kernel.org>
In-Reply-To: <20170116193317.20390-1-mhocko@kernel.org>
Subject: Re: [PATCH 1/3] mm, vmscan: cleanup lru size claculations
Date: Tue, 17 Jan 2017 11:40:25 +0800
Message-ID: <033b01d27073$70e0db20$52a29160$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Michal Hocko' <mhocko@kernel.org>, 'Johannes Weiner' <hannes@cmpxchg.org>
Cc: 'Minchan Kim' <minchan@kernel.org>, 'Mel Gorman' <mgorman@suse.de>, linux-mm@kvack.org, 'LKML' <linux-kernel@vger.kernel.org>, 'Michal Hocko' <mhocko@suse.com>

On Tuesday, January 17, 2017 3:33 AM Michal Hocko wrote: 
> 
> From: Michal Hocko <mhocko@suse.com>
> 
> lruvec_lru_size returns the full size of the LRU list while we sometimes
> need a value reduced only to eligible zones (e.g. for lowmem requests).
> inactive_list_is_low is one such user. Later patches will add more of
> them. Add a new parameter to lruvec_lru_size and allow it filter out
> zones which are not eligible for the given context.
> 
> Acked-by: Johannes Weiner <hannes@cmpxchg.org>
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
