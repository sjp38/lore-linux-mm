Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 44B2F6B0038
	for <linux-mm@kvack.org>; Wed, 25 Jan 2017 09:21:48 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id v77so38730037wmv.5
        for <linux-mm@kvack.org>; Wed, 25 Jan 2017 06:21:48 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s62si9825896wms.146.2017.01.25.06.21.46
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 25 Jan 2017 06:21:47 -0800 (PST)
Date: Wed, 25 Jan 2017 15:21:42 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v6] mm: Add memory allocation watchdog kernel thread.
Message-ID: <20170125142141.GT32377@dhcp22.suse.cz>
References: <1478416501-10104-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <201612151924.HJJ69799.VSFLHOQFFMOtOJ@I-love.SAKURA.ne.jp>
 <201612282042.GDB17129.tOHFOFSQOFLVJM@I-love.SAKURA.ne.jp>
 <201701252303.FCI17866.FOJFHMtSQOFVLO@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201701252303.FCI17866.FOJFHMtSQOFVLO@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, mgorman@suse.de, hannes@cmpxchg.org, vdavydov.dev@gmail.com, pmladek@suse.com, sergey.senozhatsky.work@gmail.com, vegard.nossum@oracle.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed 25-01-17 23:03:43, Tetsuo Handa wrote:
> Andrew, what do you think about this version? There seems to be no objections.

Well, this is not true. My main objection still holds. I simply do not
think all the additional code is really worth it. Not enough to nack the
patch, though, of course. I am not questioning that the watchdog might
be useful for debugging. I just think that what we have currently tells
us enough to debug issues. Sure, you will tell that this is not
reliable, but I will argue that this should be fixed because that makes
sense regardless of the stall warning.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
