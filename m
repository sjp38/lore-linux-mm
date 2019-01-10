Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id BD6858E0001
	for <linux-mm@kvack.org>; Thu, 10 Jan 2019 18:59:38 -0500 (EST)
Received: by mail-io1-f71.google.com with SMTP id t133so11418524iof.20
        for <linux-mm@kvack.org>; Thu, 10 Jan 2019 15:59:38 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id e12si10773786ioc.3.2019.01.10.15.59.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Jan 2019 15:59:37 -0800 (PST)
Message-Id: <201901102359.x0ANxIbn020225@www262.sakura.ne.jp>
Subject: Re: [PATCH 0/2] oom, memcg: do not report racy no-eligible OOM
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
MIME-Version: 1.0
Date: Fri, 11 Jan 2019 08:59:18 +0900
References: <e55fb27c-f23b-0ac5-acfd-7265c0a3b8dc@i-love.sakura.ne.jp> <20190109120212.GT31793@dhcp22.suse.cz>
In-Reply-To: <20190109120212.GT31793@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>

Michal Hocko wrote:
> On Wed 09-01-19 20:34:46, Tetsuo Handa wrote:
> > On 2019/01/09 20:03, Michal Hocko wrote:
> > > Tetsuo,
> > > can you confirm that these two patches are fixing the issue you have
> > > reported please?
> > > 
> > 
> > My patch fixes the issue better than your "[PATCH 2/2] memcg: do not
> > report racy no-eligible OOM tasks" does.
> 
> OK, so we are stuck again. Hooray!

Andrew, will you pick up "[PATCH 3/2] memcg: Facilitate termination of memcg OOM victims." ?
Since mm-oom-marks-all-killed-tasks-as-oom-victims.patch does not call mark_oom_victim()
when task_will_free_mem() == true, memcg-do-not-report-racy-no-eligible-oom-tasks.patch
does not close the race whereas my patch closes the race better.
