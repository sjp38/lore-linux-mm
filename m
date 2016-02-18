Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id 0628B828E2
	for <linux-mm@kvack.org>; Thu, 18 Feb 2016 07:13:36 -0500 (EST)
Received: by mail-wm0-f46.google.com with SMTP id b205so22039231wmb.1
        for <linux-mm@kvack.org>; Thu, 18 Feb 2016 04:13:35 -0800 (PST)
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com. [74.125.82.52])
        by mx.google.com with ESMTPS id ev16si9886646wjd.112.2016.02.18.04.13.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Feb 2016 04:13:35 -0800 (PST)
Received: by mail-wm0-f52.google.com with SMTP id c200so23909760wme.0
        for <linux-mm@kvack.org>; Thu, 18 Feb 2016 04:13:34 -0800 (PST)
Date: Thu, 18 Feb 2016 13:13:33 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2] mm,oom: exclude oom_task_origin processes if they are
 OOM-unkillable.
Message-ID: <20160218121333.GD18149@dhcp22.suse.cz>
References: <1455719460-7690-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <alpine.DEB.2.10.1602171430500.15429@chino.kir.corp.google.com>
 <20160218080909.GA18149@dhcp22.suse.cz>
 <201602181930.HIH09321.SFVFOQLHOFMJOt@I-love.SAKURA.ne.jp>
 <20160218120849.GC18149@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160218120849.GC18149@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: rientjes@google.com, akpm@linux-foundation.org, mgorman@suse.de, oleg@redhat.com, torvalds@linux-foundation.org, hughd@google.com, andrea@kernel.org, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu 18-02-16 13:08:49, Michal Hocko wrote:
> I guess we can safely remove the memcg
> argument from oom_badness and oom_unkillable_task. At least from a quick
> glance...

No we cannot actually. oom_kill_process could select a child which is in
a different memcg in that case...
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
