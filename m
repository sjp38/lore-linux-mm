Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 2B6CB6B0005
	for <linux-mm@kvack.org>; Thu, 17 Mar 2016 09:23:38 -0400 (EDT)
Received: by mail-wm0-f52.google.com with SMTP id l68so117039213wml.1
        for <linux-mm@kvack.org>; Thu, 17 Mar 2016 06:23:38 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id br5si10227072wjb.69.2016.03.17.06.23.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Mar 2016 06:23:37 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id x188so6740742wmg.0
        for <linux-mm@kvack.org>; Thu, 17 Mar 2016 06:23:37 -0700 (PDT)
Date: Thu, 17 Mar 2016 14:23:35 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 6/5] oom, oom_reaper: disable oom_reaper for
 oom_kill_allocating_task
Message-ID: <20160317132335.GF26017@dhcp22.suse.cz>
References: <20160315114300.GC6108@dhcp22.suse.cz>
 <20160315115001.GE6108@dhcp22.suse.cz>
 <201603162016.EBJ05275.VHMFSOLJOFQtOF@I-love.SAKURA.ne.jp>
 <201603171949.FHE57319.SMFFtJOHOVOFLQ@I-love.SAKURA.ne.jp>
 <20160317121751.GE26017@dhcp22.suse.cz>
 <201603172200.CIE52148.QOVSOHJFMLOFtF@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201603172200.CIE52148.QOVSOHJFMLOFtF@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org

On Thu 17-03-16 22:00:34, Tetsuo Handa wrote:
[...]
> If you worry about too much work for a single RCU, you can do like
> what kmallocwd does. kmallocwd adds a marker to task_struct so that
> kmallocwd can reliably resume reporting.

It is you who is trying to add a different debugging output so you
should better make sure you won't swamp the user by something that might
be not helpful after all by _default_. I would care much less if this
was hidden by the debugging option like the current
debug_show_all_locks.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
