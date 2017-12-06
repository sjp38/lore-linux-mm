Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9CE166B037F
	for <linux-mm@kvack.org>; Wed,  6 Dec 2017 04:00:23 -0500 (EST)
Received: by mail-pl0-f70.google.com with SMTP id i7so655262plt.3
        for <linux-mm@kvack.org>; Wed, 06 Dec 2017 01:00:23 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k7si1542661pgq.431.2017.12.06.01.00.22
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 06 Dec 2017 01:00:22 -0800 (PST)
Date: Wed, 6 Dec 2017 10:00:19 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Multiple oom_reaper BUGs: unmap_page_range racing with exit_mmap
Message-ID: <20171206090019.GE16386@dhcp22.suse.cz>
References: <alpine.DEB.2.10.1712051824050.91099@chino.kir.corp.google.com>
 <alpine.DEB.2.10.1712051857450.98120@chino.kir.corp.google.com>
 <201712060328.vB63SrDK069830@www262.sakura.ne.jp>
 <alpine.DEB.2.10.1712052323170.119719@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1712052323170.119719@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue 05-12-17 23:48:21, David Rientjes wrote:
[...]
> I think this argues to do MMF_REAPING-style behavior at the beginning of 
> exit_mmap() and avoid reaping all together once we have reached that 
> point.  There are no more users of the mm and we are in the process of 
> tearing it down, I'm not sure that the oom reaper should be in the 
> business with trying to interfere with that.  Or are there actual bug 
> reports where an oom victim gets wedged while in exit_mmap() prior to 
> releasing its memory?

Something like that seem to work indeed. But we should better understand
what is going on here before adding new oom reaper specific kludges. So
let's focus on getting more information from your crashes first.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
