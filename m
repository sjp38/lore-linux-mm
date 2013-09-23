Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 6FA5A6B0070
	for <linux-mm@kvack.org>; Mon, 23 Sep 2013 09:12:21 -0400 (EDT)
Received: by mail-pa0-f48.google.com with SMTP id bj1so2273439pad.21
        for <linux-mm@kvack.org>; Mon, 23 Sep 2013 06:12:21 -0700 (PDT)
Received: by mail-qc0-f175.google.com with SMTP id v2so1991679qcr.6
        for <linux-mm@kvack.org>; Mon, 23 Sep 2013 06:12:18 -0700 (PDT)
Date: Mon, 23 Sep 2013 09:12:15 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v6 0/5] memcg, cgroup: kill css id
Message-ID: <20130923131215.GI30946@htj.dyndns.org>
References: <524001F8.6070205@huawei.com>
 <20130923130816.GH30946@htj.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130923130816.GH30946@htj.dyndns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Zefan <lizefan@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, cgroups <cgroups@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Mon, Sep 23, 2013 at 09:08:16AM -0400, Tejun Heo wrote:
> Hello,
> 
> On Mon, Sep 23, 2013 at 04:55:20PM +0800, Li Zefan wrote:
> > The whole patchset has been acked and reviewed by Michal and Tejun.
> > Could you merge it into mm tree?
> 
> Ah... I really hoped that this had been merged during -rc1 window.
> Andrew, would it be okay to carry this series through cgroup tree?  It
> doesn't really have much to do with mm proper and it's a PITA to have
> to keep updating css_id code from cgroup side when it's scheduled to
> go away.  If carried in -mm, it's likely to cause conflicts with
> ongoing cgroup changes too.

Also, wasn't this already in -mm during the last devel cycle?  ISTR
conflicts with it in -mm with other cgroup core changes.  Is there any
specific reason why this wasn't merged during the merge windw?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
