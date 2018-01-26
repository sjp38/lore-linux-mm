Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2211C6B0011
	for <linux-mm@kvack.org>; Fri, 26 Jan 2018 05:08:35 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id x24so6611796pge.13
        for <linux-mm@kvack.org>; Fri, 26 Jan 2018 02:08:35 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 70-v6si3507291pla.635.2018.01.26.02.08.33
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 26 Jan 2018 02:08:34 -0800 (PST)
Date: Fri, 26 Jan 2018 11:08:30 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/2] mm,vmscan: Kill global shrinker lock.
Message-ID: <20180126100830.GB5027@dhcp22.suse.cz>
References: <201801251956.FAH73425.VFJLFFtSHOOMQO@I-love.SAKURA.ne.jp>
 <alpine.LRH.2.11.1801252209010.6864@mail.ewheeler.net>
 <201801260312.w0Q3C0tr067684@www262.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201801260312.w0Q3C0tr067684@www262.sakura.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Eric Wheeler <linux-mm@lists.ewheeler.net>, hannes@cmpxchg.org, minchan@kernel.org, ying.huang@intel.com, mgorman@techsingularity.net, vdavydov.dev@gmail.com, akpm@linux-foundation.org, shakeelb@google.com, gthelen@google.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri 26-01-18 12:12:00, Tetsuo Handa wrote:
> Would you answer to Michal's questions
> 
>   Is this a permanent state or does the holder eventually releases the lock?
> 
>   Do you remember the last good kernel?
> 
> and my guess
> 
>   Since commit 0bcac06f27d75285 was not backported to 4.14-stable kernel,
>   this is unlikely the bug introduced by 0bcac06f27d75285 unless Eric
>   explicitly backported 0bcac06f27d75285.

Can we do that in the original email thread please. Conflating these two
things while we have no idea about the culprit is just mess.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
