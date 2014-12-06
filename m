Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f178.google.com (mail-qc0-f178.google.com [209.85.216.178])
	by kanga.kvack.org (Postfix) with ESMTP id 136FA6B006E
	for <linux-mm@kvack.org>; Sat,  6 Dec 2014 08:11:20 -0500 (EST)
Received: by mail-qc0-f178.google.com with SMTP id b13so1900205qcw.37
        for <linux-mm@kvack.org>; Sat, 06 Dec 2014 05:11:19 -0800 (PST)
Received: from mail-qg0-x22c.google.com (mail-qg0-x22c.google.com. [2607:f8b0:400d:c04::22c])
        by mx.google.com with ESMTPS id w8si37979764qar.67.2014.12.06.05.11.18
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 06 Dec 2014 05:11:19 -0800 (PST)
Received: by mail-qg0-f44.google.com with SMTP id z60so1718837qgd.31
        for <linux-mm@kvack.org>; Sat, 06 Dec 2014 05:11:18 -0800 (PST)
Date: Sat, 6 Dec 2014 08:11:15 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH -v2 5/5] OOM, PM: make OOM detection in the freezer path
 raceless
Message-ID: <20141206131115.GF18711@htj.dyndns.org>
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

On Fri, Dec 05, 2014 at 05:41:47PM +0100, Michal Hocko wrote:
> 5695be142e20 (OOM, PM: OOM killed task shouldn't escape PM suspend)
> has left a race window when OOM killer manages to note_oom_kill after
> freeze_processes checks the counter. The race window is quite small and
> really unlikely and partial solution deemed sufficient at the time of
> submission.

This patch doesn't apply on top of v3.18-rc3, latest mainline, -mm or
-next.  Did I miss something?  Can you please check the patch?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
