Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id E6E706B027A
	for <linux-mm@kvack.org>; Tue, 29 Dec 2015 11:32:52 -0500 (EST)
Received: by mail-wm0-f50.google.com with SMTP id f206so42767495wmf.0
        for <linux-mm@kvack.org>; Tue, 29 Dec 2015 08:32:52 -0800 (PST)
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com. [74.125.82.41])
        by mx.google.com with ESMTPS id l191si17172013wmg.78.2015.12.29.08.32.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Dec 2015 08:32:52 -0800 (PST)
Received: by mail-wm0-f41.google.com with SMTP id b14so19450539wmb.1
        for <linux-mm@kvack.org>; Tue, 29 Dec 2015 08:32:51 -0800 (PST)
Date: Tue, 29 Dec 2015 17:32:50 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 0/3] OOM detection rework v4
Message-ID: <20151229163249.GD10321@dhcp22.suse.cz>
References: <1450203586-10959-1-git-send-email-mhocko@kernel.org>
 <201512242141.EAH69761.MOVFQtHSFOJFLO@I-love.SAKURA.ne.jp>
 <201512282108.EDI82328.OHFLtVJOSQFMFO@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201512282108.EDI82328.OHFLtVJOSQFMFO@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, torvalds@linux-foundation.org, hannes@cmpxchg.org, mgorman@suse.de, rientjes@google.com, hillf.zj@alibaba-inc.com, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon 28-12-15 21:08:56, Tetsuo Handa wrote:
> Tetsuo Handa wrote:
> > I got OOM killers while running heavy disk I/O (extracting kernel source,
> > running lxr's genxref command). (Environ: 4 CPUs / 2048MB RAM / no swap / XFS)
> > Do you think these OOM killers reasonable? Too weak against fragmentation?
> 
> Well, current patch invokes OOM killers when more than 75% of memory is used
> for file cache (active_file: + inactive_file:). I think this is a surprising
> thing for administrators and we want to retry more harder (but not forever,
> please).

Here again, it would be good to see what is the comparision between
the original and the new behavior. 75% of a page cache is certainly
unexpected but those pages might be pinned for other reasons and so
unreclaimable and basically IO bound. This is hard to optimize for
without causing any undesirable side effects for other loads. I will
have a look at the oom reports later but having a comparision would be
a great start.

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
