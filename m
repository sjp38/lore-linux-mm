Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f53.google.com (mail-wg0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id 7A3A86B0032
	for <linux-mm@kvack.org>; Sun,  7 Dec 2014 05:11:21 -0500 (EST)
Received: by mail-wg0-f53.google.com with SMTP id l18so4079963wgh.40
        for <linux-mm@kvack.org>; Sun, 07 Dec 2014 02:11:21 -0800 (PST)
Received: from mail-wi0-x235.google.com (mail-wi0-x235.google.com. [2a00:1450:400c:c05::235])
        by mx.google.com with ESMTPS id cz10si5271341wib.49.2014.12.07.02.11.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 07 Dec 2014 02:11:20 -0800 (PST)
Received: by mail-wi0-f181.google.com with SMTP id r20so2323067wiv.8
        for <linux-mm@kvack.org>; Sun, 07 Dec 2014 02:11:20 -0800 (PST)
Date: Sun, 7 Dec 2014 11:11:18 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH -v2 5/5] OOM, PM: make OOM detection in the freezer path
 raceless
Message-ID: <20141207101118.GD15892@dhcp22.suse.cz>
References: <20141110163055.GC18373@dhcp22.suse.cz>
 <1417797707-31699-1-git-send-email-mhocko@suse.cz>
 <1417797707-31699-6-git-send-email-mhocko@suse.cz>
 <20141206131115.GF18711@htj.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141206131115.GF18711@htj.dyndns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, "\\\"Rafael J. Wysocki\\\"" <rjw@rjwysocki.net>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Oleg Nesterov <oleg@redhat.com>, Cong Wang <xiyou.wangcong@gmail.com>, LKML <linux-kernel@vger.kernel.org>, linux-pm@vger.kernel.org

On Sat 06-12-14 08:11:15, Tejun Heo wrote:
> On Fri, Dec 05, 2014 at 05:41:47PM +0100, Michal Hocko wrote:
> > 5695be142e20 (OOM, PM: OOM killed task shouldn't escape PM suspend)
> > has left a race window when OOM killer manages to note_oom_kill after
> > freeze_processes checks the counter. The race window is quite small and
> > really unlikely and partial solution deemed sufficient at the time of
> > submission.
> 
> This patch doesn't apply on top of v3.18-rc3, latest mainline, -mm or
> -next.  Did I miss something?  Can you please check the patch?

The original cover letter which didn't make it to the mailing list has
mentioned that. I have reposted it now. Anyway this is on top of
http://marc.info/?l=linux-kernel&m=141779091114777 which hasn't landed
into -mm tree at the time I was posting this. Sorry about the confusion.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
