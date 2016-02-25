Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id 677146B0254
	for <linux-mm@kvack.org>; Thu, 25 Feb 2016 09:16:51 -0500 (EST)
Received: by mail-wm0-f46.google.com with SMTP id c200so30619959wme.0
        for <linux-mm@kvack.org>; Thu, 25 Feb 2016 06:16:51 -0800 (PST)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id w7si4318978wmw.101.2016.02.25.06.16.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Feb 2016 06:16:50 -0800 (PST)
Received: by mail-wm0-f65.google.com with SMTP id g62so3723762wme.2
        for <linux-mm@kvack.org>; Thu, 25 Feb 2016 06:16:50 -0800 (PST)
Date: Thu, 25 Feb 2016 15:16:48 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 3/5] oom: clear TIF_MEMDIE after oom_reaper managed to
 unmap the address space
Message-ID: <20160225141647.GC4204@dhcp22.suse.cz>
References: <1454505240-23446-1-git-send-email-mhocko@kernel.org>
 <1454505240-23446-4-git-send-email-mhocko@kernel.org>
 <201602252028.BAE39532.MFOHFLOQSOVFJt@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201602252028.BAE39532.MFOHFLOQSOVFJt@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: rientjes@google.com, hannes@cmpxchg.org, linux-mm@kvack.org

On Thu 25-02-16 20:28:35, Tetsuo Handa wrote:
[...]
> Did you decide what to do if the OOM reaper is unable to take mmap_sem
> for the associated mm struct?

Not yet because I consider it outside of the context of this submission.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
