Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f199.google.com (mail-yb0-f199.google.com [209.85.213.199])
	by kanga.kvack.org (Postfix) with ESMTP id 06C846B02F3
	for <linux-mm@kvack.org>; Wed, 17 May 2017 17:43:42 -0400 (EDT)
Received: by mail-yb0-f199.google.com with SMTP id e136so14216359ybb.6
        for <linux-mm@kvack.org>; Wed, 17 May 2017 14:43:42 -0700 (PDT)
Received: from mail-yw0-x244.google.com (mail-yw0-x244.google.com. [2607:f8b0:4002:c05::244])
        by mx.google.com with ESMTPS id u128si21452ybf.319.2017.05.17.14.43.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 May 2017 14:43:41 -0700 (PDT)
Received: by mail-yw0-x244.google.com with SMTP id h82so1745849ywb.3
        for <linux-mm@kvack.org>; Wed, 17 May 2017 14:43:40 -0700 (PDT)
Date: Wed, 17 May 2017 17:43:38 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC PATCH v2 10/17] cgroup: Make debug cgroup support v2 and
 thread mode
Message-ID: <20170517214338.GG942@htj.duckdns.org>
References: <1494855256-12558-1-git-send-email-longman@redhat.com>
 <1494855256-12558-11-git-send-email-longman@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1494855256-12558-11-git-send-email-longman@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Waiman Long <longman@redhat.com>
Cc: Li Zefan <lizefan@huawei.com>, Johannes Weiner <hannes@cmpxchg.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com, pjt@google.com, luto@amacapital.net, efault@gmx.de

Hello,

On Mon, May 15, 2017 at 09:34:09AM -0400, Waiman Long wrote:
> Besides supporting cgroup v2 and thread mode, the following changes
> are also made:
>  1) current_* cgroup files now resides only at the root as we don't
>     need duplicated files of the same function all over the cgroup
>     hierarchy.
>  2) The cgroup_css_links_read() function is modified to report
>     the number of tasks that are skipped because of overflow.
>  3) The relationship between proc_cset and threaded_csets are displayed.
>  4) The number of extra unaccounted references are displayed.
>  5) The status of being a thread root or threaded cgroup is displayed.
>  6) The current_css_set_read() function now prints out the addresses of
>     the css'es associated with the current css_set.
>  7) A new cgroup_subsys_states file is added to display the css objects
>     associated with a cgroup.
>  8) A new cgroup_masks file is added to display the various controller
>     bit masks in the cgroup.
> 
> Signed-off-by: Waiman Long <longman@redhat.com>

As noted before, please make it clear that this is a debug feature and
not expected to be stable.  Also, I don't see why this and the
previous two patches are in this series.  Can you please split these
out to a separate patchset?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
