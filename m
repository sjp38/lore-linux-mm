Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2B9CC8E0001
	for <linux-mm@kvack.org>; Fri, 11 Jan 2019 06:33:57 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id o21so5802190edq.4
        for <linux-mm@kvack.org>; Fri, 11 Jan 2019 03:33:57 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z5-v6si2447041ejp.317.2019.01.11.03.33.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Jan 2019 03:33:55 -0800 (PST)
Date: Fri, 11 Jan 2019 12:33:54 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 0/2] oom, memcg: do not report racy no-eligible OOM
Message-ID: <20190111113354.GD14956@dhcp22.suse.cz>
References: <e55fb27c-f23b-0ac5-acfd-7265c0a3b8dc@i-love.sakura.ne.jp>
 <20190109120212.GT31793@dhcp22.suse.cz>
 <201901102359.x0ANxIbn020225@www262.sakura.ne.jp>
 <fbdfdfeb-5664-ddf3-4d65-c64f9851ac26@i-love.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <fbdfdfeb-5664-ddf3-4d65-c64f9851ac26@i-love.sakura.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>

On Fri 11-01-19 19:25:22, Tetsuo Handa wrote:
> On 2019/01/11 8:59, Tetsuo Handa wrote:
> > Michal Hocko wrote:
> >> On Wed 09-01-19 20:34:46, Tetsuo Handa wrote:
> >>> On 2019/01/09 20:03, Michal Hocko wrote:
> >>>> Tetsuo,
> >>>> can you confirm that these two patches are fixing the issue you have
> >>>> reported please?
> >>>>
> >>>
> >>> My patch fixes the issue better than your "[PATCH 2/2] memcg: do not
> >>> report racy no-eligible OOM tasks" does.
> >>
> >> OK, so we are stuck again. Hooray!
> > 
> > Andrew, will you pick up "[PATCH 3/2] memcg: Facilitate termination of memcg OOM victims." ?
> > Since mm-oom-marks-all-killed-tasks-as-oom-victims.patch does not call mark_oom_victim()
> > when task_will_free_mem() == true, memcg-do-not-report-racy-no-eligible-oom-tasks.patch
> > does not close the race whereas my patch closes the race better.
> > 
> 
> I confirmed that mm-oom-marks-all-killed-tasks-as-oom-victims.patch and
> memcg-do-not-report-racy-no-eligible-oom-tasks.patch are completely failing
> to fix the issue I am reporting. :-(

OK, this is really interesting. This means that we are racing
when marking all the tasks sharing the mm with the clone syscall.
Does fatal_signal_pending handle this better?
-- 
Michal Hocko
SUSE Labs
