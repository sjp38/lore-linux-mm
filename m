Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f53.google.com (mail-qa0-f53.google.com [209.85.216.53])
	by kanga.kvack.org (Postfix) with ESMTP id 89B3E6B0032
	for <linux-mm@kvack.org>; Wed,  7 Jan 2015 12:57:36 -0500 (EST)
Received: by mail-qa0-f53.google.com with SMTP id j7so3693091qaq.12
        for <linux-mm@kvack.org>; Wed, 07 Jan 2015 09:57:36 -0800 (PST)
Received: from mail-qa0-x22b.google.com (mail-qa0-x22b.google.com. [2607:f8b0:400d:c00::22b])
        by mx.google.com with ESMTPS id a8si2829154qga.3.2015.01.07.09.57.34
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 07 Jan 2015 09:57:35 -0800 (PST)
Received: by mail-qa0-f43.google.com with SMTP id n4so3724316qaq.2
        for <linux-mm@kvack.org>; Wed, 07 Jan 2015 09:57:34 -0800 (PST)
Date: Wed, 7 Jan 2015 12:57:31 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH -v2 1/5] oom: add helpers for setting and clearing
 TIF_MEMDIE
Message-ID: <20150107175731.GG4395@htj.dyndns.org>
References: <20141110163055.GC18373@dhcp22.suse.cz>
 <1417797707-31699-1-git-send-email-mhocko@suse.cz>
 <1417797707-31699-2-git-send-email-mhocko@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1417797707-31699-2-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, "\\\"Rafael J. Wysocki\\\"" <rjw@rjwysocki.net>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Oleg Nesterov <oleg@redhat.com>, Cong Wang <xiyou.wangcong@gmail.com>, LKML <linux-kernel@vger.kernel.org>, linux-pm@vger.kernel.org

On Fri, Dec 05, 2014 at 05:41:43PM +0100, Michal Hocko wrote:
> +/**
> + * Unmarks the current task as OOM victim.
> + */
> +void unmark_tsk_oom_victim(void)
> +{
> +	clear_thread_flag(TIF_MEMDIE);
> +}

This prolly should be unmark_current_oom_victim()?  Also, can we
please use full "task" at least in global symbols?  I don't think tsk
abbreviation is that popular in function names.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
