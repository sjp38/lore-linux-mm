Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id C62E66B0032
	for <linux-mm@kvack.org>; Wed,  7 Jan 2015 13:23:39 -0500 (EST)
Received: by mail-wi0-f173.google.com with SMTP id r20so8094312wiv.6
        for <linux-mm@kvack.org>; Wed, 07 Jan 2015 10:23:39 -0800 (PST)
Received: from mail-wg0-x234.google.com (mail-wg0-x234.google.com. [2a00:1450:400c:c00::234])
        by mx.google.com with ESMTPS id z5si33855960wiw.94.2015.01.07.10.23.38
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 07 Jan 2015 10:23:38 -0800 (PST)
Received: by mail-wg0-f52.google.com with SMTP id x12so1671207wgg.39
        for <linux-mm@kvack.org>; Wed, 07 Jan 2015 10:23:38 -0800 (PST)
Date: Wed, 7 Jan 2015 19:23:35 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH -v2 1/5] oom: add helpers for setting and clearing
 TIF_MEMDIE
Message-ID: <20150107182335.GG16553@dhcp22.suse.cz>
References: <20141110163055.GC18373@dhcp22.suse.cz>
 <1417797707-31699-1-git-send-email-mhocko@suse.cz>
 <1417797707-31699-2-git-send-email-mhocko@suse.cz>
 <20150107175731.GG4395@htj.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150107175731.GG4395@htj.dyndns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, "\\\"Rafael J. Wysocki\\\"" <rjw@rjwysocki.net>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Oleg Nesterov <oleg@redhat.com>, Cong Wang <xiyou.wangcong@gmail.com>, LKML <linux-kernel@vger.kernel.org>, linux-pm@vger.kernel.org

On Wed 07-01-15 12:57:31, Tejun Heo wrote:
> On Fri, Dec 05, 2014 at 05:41:43PM +0100, Michal Hocko wrote:
> > +/**
> > + * Unmarks the current task as OOM victim.
> > + */
> > +void unmark_tsk_oom_victim(void)
> > +{
> > +	clear_thread_flag(TIF_MEMDIE);
> > +}
> 
> This prolly should be unmark_current_oom_victim()?

OK.

> Also, can we
> please use full "task" at least in global symbols?  I don't think tsk
> abbreviation is that popular in function names.

It is mimicking *_tsk_thread_flag() API.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
