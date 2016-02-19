Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id A82FD6B0005
	for <linux-mm@kvack.org>; Fri, 19 Feb 2016 10:13:57 -0500 (EST)
Received: by mail-wm0-f47.google.com with SMTP id g62so72949942wme.0
        for <linux-mm@kvack.org>; Fri, 19 Feb 2016 07:13:57 -0800 (PST)
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com. [74.125.82.45])
        by mx.google.com with ESMTPS id 12si18495283wjy.50.2016.02.19.07.13.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Feb 2016 07:13:56 -0800 (PST)
Received: by mail-wm0-f45.google.com with SMTP id g62so72949444wme.0
        for <linux-mm@kvack.org>; Fri, 19 Feb 2016 07:13:56 -0800 (PST)
Date: Fri, 19 Feb 2016 16:13:55 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2] mm,oom: exclude oom_task_origin processes if they are
 OOM-unkillable.
Message-ID: <20160219151355.GJ12690@dhcp22.suse.cz>
References: <alpine.DEB.2.10.1602171430500.15429@chino.kir.corp.google.com>
 <20160218080909.GA18149@dhcp22.suse.cz>
 <201602181930.HIH09321.SFVFOQLHOFMJOt@I-love.SAKURA.ne.jp>
 <20160218120849.GC18149@dhcp22.suse.cz>
 <20160218121333.GD18149@dhcp22.suse.cz>
 <201602200007.EAF90182.OQFSOMOFtFJLHV@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201602200007.EAF90182.OQFSOMOFtFJLHV@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: rientjes@google.com, akpm@linux-foundation.org, mgorman@suse.de, oleg@redhat.com, torvalds@linux-foundation.org, hughd@google.com, andrea@kernel.org, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sat 20-02-16 00:07:05, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Thu 18-02-16 13:08:49, Michal Hocko wrote:
> > > I guess we can safely remove the memcg
> > > argument from oom_badness and oom_unkillable_task. At least from a quick
> > > glance...
> > 
> > No we cannot actually. oom_kill_process could select a child which is in
> > a different memcg in that case...
> 
> Then, don't we need to check whether processes sharing victim->mm in other
> thread groups are in the same memcg when we walk the process list?

memcg is bound to the mm not to the task. So all processes sharing the
mm after in the same memcg (from the memcg POV). See tast_struct::owner.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
