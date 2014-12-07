Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f42.google.com (mail-qa0-f42.google.com [209.85.216.42])
	by kanga.kvack.org (Postfix) with ESMTP id ED2896B006E
	for <linux-mm@kvack.org>; Sun,  7 Dec 2014 08:59:44 -0500 (EST)
Received: by mail-qa0-f42.google.com with SMTP id j7so2399396qaq.1
        for <linux-mm@kvack.org>; Sun, 07 Dec 2014 05:59:44 -0800 (PST)
Received: from mail-qa0-x235.google.com (mail-qa0-x235.google.com. [2607:f8b0:400d:c00::235])
        by mx.google.com with ESMTPS id jv4si40594976qcb.13.2014.12.07.05.59.43
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 07 Dec 2014 05:59:43 -0800 (PST)
Received: by mail-qa0-f53.google.com with SMTP id bm13so2413235qab.12
        for <linux-mm@kvack.org>; Sun, 07 Dec 2014 05:59:43 -0800 (PST)
Date: Sun, 7 Dec 2014 08:59:40 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH -v2 2/5] OOM: thaw the OOM victim if it is frozen
Message-ID: <20141207135940.GB19034@htj.dyndns.org>
References: <20141110163055.GC18373@dhcp22.suse.cz>
 <1417797707-31699-1-git-send-email-mhocko@suse.cz>
 <1417797707-31699-3-git-send-email-mhocko@suse.cz>
 <20141206130657.GC18711@htj.dyndns.org>
 <20141207102430.GF15892@dhcp22.suse.cz>
 <20141207104539.GK15892@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141207104539.GK15892@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, "\\\"Rafael J. Wysocki\\\"" <rjw@rjwysocki.net>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Oleg Nesterov <oleg@redhat.com>, Cong Wang <xiyou.wangcong@gmail.com>, LKML <linux-kernel@vger.kernel.org>, linux-pm@vger.kernel.org

On Sun, Dec 07, 2014 at 11:45:39AM +0100, Michal Hocko wrote:
....
>  void mark_tsk_oom_victim(struct task_struct *tsk)
>  {
>  	set_tsk_thread_flag(tsk, TIF_MEMDIE);
> +	__thaw_task(tsk);

Yeah, this is a lot better.  Maybe we can add a comment at least
pointing readers to where to look at to understand what's going on?
This stems from the fact that OOM killer which essentially is a memory
reclaim operation overrides freezing.  It'd be nice if that is
documented somehow.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
