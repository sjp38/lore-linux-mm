Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id 2E4146B0278
	for <linux-mm@kvack.org>; Tue, 29 Dec 2015 11:27:58 -0500 (EST)
Received: by mail-wm0-f45.google.com with SMTP id l65so37167193wmf.1
        for <linux-mm@kvack.org>; Tue, 29 Dec 2015 08:27:58 -0800 (PST)
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com. [74.125.82.42])
        by mx.google.com with ESMTPS id a17si53101624wjx.30.2015.12.29.08.27.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Dec 2015 08:27:56 -0800 (PST)
Received: by mail-wm0-f42.google.com with SMTP id f206so47964395wmf.0
        for <linux-mm@kvack.org>; Tue, 29 Dec 2015 08:27:56 -0800 (PST)
Date: Tue, 29 Dec 2015 17:27:54 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 0/3] OOM detection rework v4
Message-ID: <20151229162753.GC10321@dhcp22.suse.cz>
References: <1450203586-10959-1-git-send-email-mhocko@kernel.org>
 <201512242141.EAH69761.MOVFQtHSFOJFLO@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201512242141.EAH69761.MOVFQtHSFOJFLO@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, torvalds@linux-foundation.org, hannes@cmpxchg.org, mgorman@suse.de, rientjes@google.com, hillf.zj@alibaba-inc.com, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu 24-12-15 21:41:19, Tetsuo Handa wrote:
> I got OOM killers while running heavy disk I/O (extracting kernel source,
> running lxr's genxref command). (Environ: 4 CPUs / 2048MB RAM / no swap / XFS)
> Do you think these OOM killers reasonable? Too weak against fragmentation?

I will have a look at the oom report more closely early next week (I am
still in holiday mode) but it would be good to compare how the same load
behaves with the original implementation. It would be also interesting
to see how stable are the results (is there any variability in multiple
runs?).

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
