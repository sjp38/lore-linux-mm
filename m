Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 3F6D56B0038
	for <linux-mm@kvack.org>; Tue,  4 Aug 2015 21:35:37 -0400 (EDT)
Received: by padck2 with SMTP id ck2so22066809pad.0
        for <linux-mm@kvack.org>; Tue, 04 Aug 2015 18:35:37 -0700 (PDT)
Received: from mgwym02.jp.fujitsu.com (mgwym02.jp.fujitsu.com. [211.128.242.41])
        by mx.google.com with ESMTPS id t6si2396533pdm.24.2015.08.04.18.35.35
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Aug 2015 18:35:36 -0700 (PDT)
Received: from m3051.s.css.fujitsu.com (m3051.s.css.fujitsu.com [10.134.21.209])
	by yt-mxoi1.gw.nic.fujitsu.com (Postfix) with ESMTP id 0ACF5AC02B7
	for <linux-mm@kvack.org>; Wed,  5 Aug 2015 10:35:32 +0900 (JST)
Subject: Re: [PATCH 0/3] Make workingset detection logic memcg aware
References: <cover.1438599199.git.vdavydov@parallels.com>
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <55C16842.9040505@jp.fujitsu.com>
Date: Wed, 5 Aug 2015 10:34:58 +0900
MIME-Version: 1.0
In-Reply-To: <cover.1438599199.git.vdavydov@parallels.com>
Content-Type: text/plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 2015/08/03 21:04, Vladimir Davydov wrote:
> Hi,
> 
> Currently, workingset detection logic is not memcg aware - inactive_age
> is maintained per zone. As a result, if memory cgroups are used,
> refaulted file pages are activated randomly. This patch set makes
> inactive_age per lruvec so that workingset detection will work correctly
> for memory cgroup reclaim.
> 
> Thanks,
> 

Reading discussion, I feel storing more data is difficult, too.

I wonder, rather than collecting more data, rough calculation can help the situation.
for example,

   (refault_disatance calculated in zone) * memcg_reclaim_ratio < memcg's active list

If one of per-zone calc or per-memcg calc returns true, refault should be true.

memcg_reclaim_ratio is the percentage of scan in a memcg against in a zone.


Thanks,
-Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
