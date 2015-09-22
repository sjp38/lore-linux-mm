Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id E5F3C6B0255
	for <linux-mm@kvack.org>; Tue, 22 Sep 2015 11:49:36 -0400 (EDT)
Received: by wicgb1 with SMTP id gb1so166325574wic.1
        for <linux-mm@kvack.org>; Tue, 22 Sep 2015 08:49:36 -0700 (PDT)
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com. [209.85.212.181])
        by mx.google.com with ESMTPS id ck14si3116494wjb.90.2015.09.22.08.49.35
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Sep 2015 08:49:35 -0700 (PDT)
Received: by wicfx3 with SMTP id fx3so30661510wic.0
        for <linux-mm@kvack.org>; Tue, 22 Sep 2015 08:49:35 -0700 (PDT)
Date: Tue, 22 Sep 2015 17:49:34 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/5] cgroup, memcg, cpuset: implement
 cgroup_taskset_for_each_leader()
Message-ID: <20150922154933.GB4027@dhcp22.suse.cz>
References: <1441998022-12953-1-git-send-email-tj@kernel.org>
 <1441998022-12953-3-git-send-email-tj@kernel.org>
 <20150914204907.GI25369@htj.duckdns.org>
 <20150918160417.GD4065@mtj.duckdns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150918160417.GD4065@mtj.duckdns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: lizefan@huawei.com, cgroups@vger.kernel.org, hannes@cmpxchg.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri 18-09-15 12:04:17, Tejun Heo wrote:
> On Mon, Sep 14, 2015 at 04:49:07PM -0400, Tejun Heo wrote:
> > Michal, if you're okay with this patch, I'll apply the patchset in
> > cgroup/for-4.4.
> 
> Michal?

I am sorry but I wasn't online very much last week. The old and new code
are similarly hackish so I am OK with it. Ideally we should be able to
migrate all the tasks for both the legacy and the default hierarchies
this would require more changes in this area though.

Acked-by: Michal Hocko <mhocko@suse.com>

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
