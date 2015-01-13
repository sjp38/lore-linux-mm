Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f45.google.com (mail-wg0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id 9D1FA6B0032
	for <linux-mm@kvack.org>; Tue, 13 Jan 2015 09:15:26 -0500 (EST)
Received: by mail-wg0-f45.google.com with SMTP id y19so3196405wgg.4
        for <linux-mm@kvack.org>; Tue, 13 Jan 2015 06:15:26 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id cr3si18881365wib.59.2015.01.13.06.15.24
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Jan 2015 06:15:24 -0800 (PST)
Date: Tue, 13 Jan 2015 09:15:15 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] memcg: remove extra newlines from memcg oom kill log
Message-ID: <20150113141515.GA8180@phnom.home.cmpxchg.org>
References: <1421131539-3211-1-git-send-email-gthelen@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1421131539-3211-1-git-send-email-gthelen@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Tejun Heo <tj@kernel.org>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Jan 12, 2015 at 10:45:39PM -0800, Greg Thelen wrote:
> Commit e61734c55c24 ("cgroup: remove cgroup->name") added two extra
> newlines to memcg oom kill log messages.  This makes dmesg hard to read
> and parse.  The issue affects 3.15+.
> Example:
>   Task in /t                          <<< extra #1
>    killed as a result of limit of /t
>                                       <<< extra #2
>   memory: usage 102400kB, limit 102400kB, failcnt 274712
> 
> Remove the extra newlines from memcg oom kill messages, so the messages
> look like:
>   Task in /t killed as a result of limit of /t
>   memory: usage 102400kB, limit 102400kB, failcnt 240649
> 
> Fixes: e61734c55c24 ("cgroup: remove cgroup->name")
> Signed-off-by: Greg Thelen <gthelen@google.com>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
