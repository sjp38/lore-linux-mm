Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id E260B6B0038
	for <linux-mm@kvack.org>; Tue, 28 Nov 2017 14:39:43 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id l4so573970wre.10
        for <linux-mm@kvack.org>; Tue, 28 Nov 2017 11:39:43 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b35si206237edb.0.2017.11.28.11.39.42
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 28 Nov 2017 11:39:42 -0800 (PST)
Date: Tue, 28 Nov 2017 20:39:40 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2] mm,oom: Set ->signal->oom_mm to all thread groups
 sharing the victim's mm.
Message-ID: <20171128193940.hcrsx3wimr5hwulh@dhcp22.suse.cz>
References: <201711282307.EBG97690.MQVOFLFFOJHtOS@I-love.SAKURA.ne.jp>
 <1511885835-4899-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1511885835-4899-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, Roman Gushchin <guro@fb.com>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>

On Wed 29-11-17 01:17:15, Tetsuo Handa wrote:
> Due to commit 696453e66630ad45 ("mm, oom: task_will_free_mem should skip
> oom_reaped tasks") and patch "mm,oom: Use ALLOC_OOM for OOM victim's last
> second allocation.", thread groups sharing the OOM victim's mm without
> setting ->signal->oom_mm before task_will_free_mem(current) is called
> might fail to try ALLOC_OOM allocation attempt.

I've already NACKed your previous attempt. Now you are interfering with
the patchset Roman plans to resubmit and cause further potential clashes
for him.

Stop this already!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
