Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f169.google.com (mail-yk0-f169.google.com [209.85.160.169])
	by kanga.kvack.org (Postfix) with ESMTP id 3CE2C6B025D
	for <linux-mm@kvack.org>; Tue,  8 Sep 2015 13:00:56 -0400 (EDT)
Received: by ykdg206 with SMTP id g206so127960436ykd.1
        for <linux-mm@kvack.org>; Tue, 08 Sep 2015 10:00:56 -0700 (PDT)
Received: from mail-yk0-x22d.google.com (mail-yk0-x22d.google.com. [2607:f8b0:4002:c07::22d])
        by mx.google.com with ESMTPS id u62si2504346ykc.142.2015.09.08.10.00.55
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Sep 2015 10:00:55 -0700 (PDT)
Received: by ykdg206 with SMTP id g206so127959720ykd.1
        for <linux-mm@kvack.org>; Tue, 08 Sep 2015 10:00:55 -0700 (PDT)
Date: Tue, 8 Sep 2015 13:00:51 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v2 3/2] memcg: punt high overage reclaim to
 return-to-userland path
Message-ID: <20150908170051.GH13749@mtj.duckdns.org>
References: <20150828220158.GD11089@htj.dyndns.org>
 <20150828220237.GE11089@htj.dyndns.org>
 <20150904210011.GH25329@mtj.duckdns.org>
 <20150907113822.GB31800@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150907113822.GB31800@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: hannes@cmpxchg.org, mhocko@kernel.org, akpm@linux-foundation.org, cgroups@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com

Hello, Vladimir.

On Mon, Sep 07, 2015 at 02:38:22PM +0300, Vladimir Davydov wrote:
> > As long as kernel doesn't have a run-away allocation spree, this
> > should provide enough protection while making kmemcg behave more
> > consistently.
> 
> Another good thing about such an approach is that it copes with prio
> inversion. Currently, a task with small memory.high might issue
> memory.high reclaim on kmem charge with a bunch of various locks held.
> If a task with a big value of memory.high needs any of these locks,
> it'll have to wait until the low prio task finishes reclaim and releases
> the locks. By handing over reclaim to task_work whenever possible we
> might avoid this issue and improve overall performance.

Indeed, will update the patch accordingly.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
