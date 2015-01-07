Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id A6D066B0032
	for <linux-mm@kvack.org>; Wed,  7 Jan 2015 13:48:50 -0500 (EST)
Received: by mail-wi0-f182.google.com with SMTP id h11so2276086wiw.9
        for <linux-mm@kvack.org>; Wed, 07 Jan 2015 10:48:50 -0800 (PST)
Received: from mail-wi0-x22e.google.com (mail-wi0-x22e.google.com. [2a00:1450:400c:c05::22e])
        by mx.google.com with ESMTPS id y9si6180248wje.44.2015.01.07.10.48.49
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 07 Jan 2015 10:48:49 -0800 (PST)
Received: by mail-wi0-f174.google.com with SMTP id h11so8152093wiw.7
        for <linux-mm@kvack.org>; Wed, 07 Jan 2015 10:48:49 -0800 (PST)
Date: Wed, 7 Jan 2015 19:48:47 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH -v2 5/5] OOM, PM: make OOM detection in the freezer path
 raceless
Message-ID: <20150107184847.GH16553@dhcp22.suse.cz>
References: <20141110163055.GC18373@dhcp22.suse.cz>
 <1417797707-31699-1-git-send-email-mhocko@suse.cz>
 <1417797707-31699-6-git-send-email-mhocko@suse.cz>
 <20150107184124.GI4395@htj.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150107184124.GI4395@htj.dyndns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, "\\\"Rafael J. Wysocki\\\"" <rjw@rjwysocki.net>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Oleg Nesterov <oleg@redhat.com>, Cong Wang <xiyou.wangcong@gmail.com>, LKML <linux-kernel@vger.kernel.org>, linux-pm@vger.kernel.org

On Wed 07-01-15 13:41:24, Tejun Heo wrote:
> Hello, Michal.  Sorry about the long delay.
> 
> On Fri, Dec 05, 2014 at 05:41:47PM +0100, Michal Hocko wrote:
> ...
> > @@ -252,6 +220,8 @@ void thaw_kernel_threads(void)
> >  {
> >  	struct task_struct *g, *p;
> >  
> > +	oom_killer_enable();
> > +
> 
> Wouldn't it be more symmetrical and make more sense to enable oom
> killer after kernel threads are thawed?  Until kernel threads are
> thawed, it isn't guaranteed that oom killer would be able to make
> forward progress, right?

Makes sense, fixed.

> Other than that, looks good to me.

Thanks! Btw. I plan to repost after Andrew releases new mmotm as there
are some dependencies in oom area.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
