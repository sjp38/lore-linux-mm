Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id 24D6F6B006E
	for <linux-mm@kvack.org>; Sun,  7 Dec 2014 05:13:26 -0500 (EST)
Received: by mail-wi0-f180.google.com with SMTP id n3so2317082wiv.7
        for <linux-mm@kvack.org>; Sun, 07 Dec 2014 02:13:25 -0800 (PST)
Received: from mail-wi0-x22b.google.com (mail-wi0-x22b.google.com. [2a00:1450:400c:c05::22b])
        by mx.google.com with ESMTPS id db3si5329071wib.3.2014.12.07.02.13.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 07 Dec 2014 02:13:25 -0800 (PST)
Received: by mail-wi0-f171.google.com with SMTP id bs8so2298454wib.10
        for <linux-mm@kvack.org>; Sun, 07 Dec 2014 02:13:25 -0800 (PST)
Date: Sun, 7 Dec 2014 11:13:23 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH -v2 1/5] oom: add helpers for setting and clearing
 TIF_MEMDIE
Message-ID: <20141207101323.GE15892@dhcp22.suse.cz>
References: <20141110163055.GC18373@dhcp22.suse.cz>
 <1417797707-31699-1-git-send-email-mhocko@suse.cz>
 <1417797707-31699-2-git-send-email-mhocko@suse.cz>
 <20141206125617.GB18711@htj.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141206125617.GB18711@htj.dyndns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, "\\\"Rafael J. Wysocki\\\"" <rjw@rjwysocki.net>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Oleg Nesterov <oleg@redhat.com>, Cong Wang <xiyou.wangcong@gmail.com>, LKML <linux-kernel@vger.kernel.org>, linux-pm@vger.kernel.org

On Sat 06-12-14 07:56:17, Tejun Heo wrote:
> On Fri, Dec 05, 2014 at 05:41:43PM +0100, Michal Hocko wrote:
> > +/**
> > + * Marks the given taks as OOM victim.
> 
> /**
>  * $FUNCTION_NAME - $DESCRIPTION
> 
> > + * @tsk: task to mark
> > + */
> > +void mark_tsk_oom_victim(struct task_struct *tsk)
> > +{
> > +	set_tsk_thread_flag(tsk, TIF_MEMDIE);
> > +}
> > +
> > +/**
> > + * Unmarks the current task as OOM victim.
> 
> Ditto.

Fixed
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
