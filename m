Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f54.google.com (mail-qa0-f54.google.com [209.85.216.54])
	by kanga.kvack.org (Postfix) with ESMTP id 6E70E6B0032
	for <linux-mm@kvack.org>; Wed,  7 Jan 2015 13:41:29 -0500 (EST)
Received: by mail-qa0-f54.google.com with SMTP id i13so3862898qae.13
        for <linux-mm@kvack.org>; Wed, 07 Jan 2015 10:41:29 -0800 (PST)
Received: from mail-qa0-x22a.google.com (mail-qa0-x22a.google.com. [2607:f8b0:400d:c00::22a])
        by mx.google.com with ESMTPS id 48si2912335qgb.58.2015.01.07.10.41.27
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 07 Jan 2015 10:41:28 -0800 (PST)
Received: by mail-qa0-f42.google.com with SMTP id n8so3904446qaq.1
        for <linux-mm@kvack.org>; Wed, 07 Jan 2015 10:41:27 -0800 (PST)
Date: Wed, 7 Jan 2015 13:41:24 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH -v2 5/5] OOM, PM: make OOM detection in the freezer path
 raceless
Message-ID: <20150107184124.GI4395@htj.dyndns.org>
References: <20141110163055.GC18373@dhcp22.suse.cz>
 <1417797707-31699-1-git-send-email-mhocko@suse.cz>
 <1417797707-31699-6-git-send-email-mhocko@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1417797707-31699-6-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, "\\\"Rafael J. Wysocki\\\"" <rjw@rjwysocki.net>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Oleg Nesterov <oleg@redhat.com>, Cong Wang <xiyou.wangcong@gmail.com>, LKML <linux-kernel@vger.kernel.org>, linux-pm@vger.kernel.org

Hello, Michal.  Sorry about the long delay.

On Fri, Dec 05, 2014 at 05:41:47PM +0100, Michal Hocko wrote:
...
> @@ -252,6 +220,8 @@ void thaw_kernel_threads(void)
>  {
>  	struct task_struct *g, *p;
>  
> +	oom_killer_enable();
> +

Wouldn't it be more symmetrical and make more sense to enable oom
killer after kernel threads are thawed?  Until kernel threads are
thawed, it isn't guaranteed that oom killer would be able to make
forward progress, right?

Other than that, looks good to me.

Thanks!

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
