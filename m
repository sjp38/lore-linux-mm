Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id C76776B0069
	for <linux-mm@kvack.org>; Wed, 25 Jan 2017 04:53:44 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id r126so35590556wmr.2
        for <linux-mm@kvack.org>; Wed, 25 Jan 2017 01:53:44 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n189si20835611wmn.97.2017.01.25.01.53.42
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 25 Jan 2017 01:53:43 -0800 (PST)
Date: Wed, 25 Jan 2017 10:53:38 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 1/2] mm, vmscan: account the number of isolated pages
 per zone
Message-ID: <20170125095337.GF32377@dhcp22.suse.cz>
References: <20170118170010.agpd4njpv5log3xe@suse.de>
 <20170118172944.GA17135@dhcp22.suse.cz>
 <20170119100755.rs6erdiz5u5by2pu@suse.de>
 <20170119112336.GN30786@dhcp22.suse.cz>
 <20170119131143.2ze5l5fwheoqdpne@suse.de>
 <201701202227.GCC13598.OHJMSQFVOtFOLF@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201701202227.GCC13598.OHJMSQFVOtFOLF@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: mgorman@suse.de, linux-mm@kvack.org, hannes@cmpxchg.org, linux-kernel@vger.kernel.org

On Fri 20-01-17 22:27:27, Tetsuo Handa wrote:
> Mel Gorman wrote:
> > On Thu, Jan 19, 2017 at 12:23:36PM +0100, Michal Hocko wrote:
> > > So what do you think about the following? Tetsuo, would you be willing
> > > to run this patch through your torture testing please?
> > 
> > I'm fine with treating this as a starting point.
> 
> OK. So I tried to test this patch but I failed at preparation step.
> There are too many pending mm patches and I'm not sure which patch on
> which linux-next snapshot I should try.

The current linux-next should be good to test. It contains all patches
sitting in the mmotm tree. If you want a more stable base then you can
use mmotm git tree
(git://git.kernel.org/pub/scm/linux/kernel/git/mhocko/mm.git #since-4.9
or its #auto-latest alias)

> Also as another question,
> too_many_isolated() loop exists in both mm/vmscan.c and mm/compaction.c
> but why this patch does not touch the loop in mm/compaction.c part?

I am not yet convinced the compaction suffers from the same problem.
Compaction backs off much sooner so that path shouldn't get into
pathological situation AFAICS. I might be wrong here but I think we
should start with the reclaim path first.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
