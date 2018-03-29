Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2477C6B0005
	for <linux-mm@kvack.org>; Thu, 29 Mar 2018 10:50:58 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id q10so2902136wre.6
        for <linux-mm@kvack.org>; Thu, 29 Mar 2018 07:50:58 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u44si5018666wrf.112.2018.03.29.07.50.56
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 29 Mar 2018 07:50:56 -0700 (PDT)
Date: Thu, 29 Mar 2018 16:50:55 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm,oom: Do not unfreeze OOM victim thread.
Message-ID: <20180329145055.GH31039@dhcp22.suse.cz>
References: <1522334218-4268-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1522334218-4268-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-pm@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Pavel Machek <pavel@ucw.cz>, "Rafael J. Wysocki" <rjw@rjwysocki.net>

On Thu 29-03-18 23:36:58, Tetsuo Handa wrote:
> Currently, mark_oom_victim() calls __thaw_task() on the OOM victim
> threads and freezing_slow_path() unfreezes the OOM victim thread.
> But I think this exceptional behavior makes little sense nowadays.

Well, I would like to see this happen because it would allow more
changes on top. E.g. get rid of TIF_MEMDIE finally. But I am not really
sure we are there yet. OOM reaper is useful tool but it still cannot
help in some cases (shared memory, a lot of metadata allocated on behalf
of the process etc...). Considering that the freezing can be an
unprivileged operation (think cgroup freezer) then I am worried that
one container can cause the global oom killer and hide oom victims to
the fridge and spill over to other containers. Maybe I am overly
paranoid and this scenario is not even all that interesting but I would
like to hear a better justification which explains all these cases
rather than "we have oom reaper so we are good to go" rationale.
-- 
Michal Hocko
SUSE Labs
