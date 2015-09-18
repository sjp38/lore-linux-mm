Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f170.google.com (mail-yk0-f170.google.com [209.85.160.170])
	by kanga.kvack.org (Postfix) with ESMTP id ED2766B0038
	for <linux-mm@kvack.org>; Fri, 18 Sep 2015 12:04:22 -0400 (EDT)
Received: by ykft14 with SMTP id t14so50814918ykf.0
        for <linux-mm@kvack.org>; Fri, 18 Sep 2015 09:04:22 -0700 (PDT)
Received: from mail-yk0-x233.google.com (mail-yk0-x233.google.com. [2607:f8b0:4002:c07::233])
        by mx.google.com with ESMTPS id 206si4375980ykl.62.2015.09.18.09.04.22
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Sep 2015 09:04:22 -0700 (PDT)
Received: by ykdt18 with SMTP id t18so50671756ykd.3
        for <linux-mm@kvack.org>; Fri, 18 Sep 2015 09:04:22 -0700 (PDT)
Date: Fri, 18 Sep 2015 12:04:17 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 2/5] cgroup, memcg, cpuset: implement
 cgroup_taskset_for_each_leader()
Message-ID: <20150918160417.GD4065@mtj.duckdns.org>
References: <1441998022-12953-1-git-send-email-tj@kernel.org>
 <1441998022-12953-3-git-send-email-tj@kernel.org>
 <20150914204907.GI25369@htj.duckdns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150914204907.GI25369@htj.duckdns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lizefan@huawei.com
Cc: cgroups@vger.kernel.org, hannes@cmpxchg.org, mhocko@suse.cz, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Sep 14, 2015 at 04:49:07PM -0400, Tejun Heo wrote:
> Michal, if you're okay with this patch, I'll apply the patchset in
> cgroup/for-4.4.

Michal?

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
