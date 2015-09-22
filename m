Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f182.google.com (mail-yk0-f182.google.com [209.85.160.182])
	by kanga.kvack.org (Postfix) with ESMTP id AF9B66B0253
	for <linux-mm@kvack.org>; Tue, 22 Sep 2015 12:48:24 -0400 (EDT)
Received: by ykft14 with SMTP id t14so15401368ykf.0
        for <linux-mm@kvack.org>; Tue, 22 Sep 2015 09:48:24 -0700 (PDT)
Received: from mail-yk0-x22c.google.com (mail-yk0-x22c.google.com. [2607:f8b0:4002:c07::22c])
        by mx.google.com with ESMTPS id g198si1580600ywe.83.2015.09.22.09.48.23
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Sep 2015 09:48:24 -0700 (PDT)
Received: by ykdt18 with SMTP id t18so15324054ykd.3
        for <linux-mm@kvack.org>; Tue, 22 Sep 2015 09:48:23 -0700 (PDT)
Date: Tue, 22 Sep 2015 12:48:20 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCHSET v2 cgroup/for-4.4] cgroup: make multi-process
 migration atomic
Message-ID: <20150922164820.GC9761@mtj.duckdns.org>
References: <1441998022-12953-1-git-send-email-tj@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1441998022-12953-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lizefan@huawei.com
Cc: cgroups@vger.kernel.org, hannes@cmpxchg.org, mhocko@suse.cz, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Sep 11, 2015 at 03:00:17PM -0400, Tejun Heo wrote:
> This is v2 of atomic multi-process migration patchset.  This one
> slipped through crack somehow.  Changes from the last take[L] are.

Applied to cgroup/for-4.4.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
