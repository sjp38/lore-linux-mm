Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 9CEE36B0009
	for <linux-mm@kvack.org>; Thu, 28 Jan 2016 17:36:18 -0500 (EST)
Received: by mail-wm0-f47.google.com with SMTP id r129so45278561wmr.0
        for <linux-mm@kvack.org>; Thu, 28 Jan 2016 14:36:18 -0800 (PST)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id ll4si18049715wjb.130.2016.01.28.14.36.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Jan 2016 14:36:17 -0800 (PST)
Received: by mail-wm0-f67.google.com with SMTP id r129so6514743wmr.0
        for <linux-mm@kvack.org>; Thu, 28 Jan 2016 14:36:17 -0800 (PST)
Date: Thu, 28 Jan 2016 23:36:16 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 3/2] oom: clear TIF_MEMDIE after oom_reaper managed to
 unmap the address space
Message-ID: <20160128223615.GB14803@dhcp22.suse.cz>
References: <1452516120-5535-1-git-send-email-mhocko@kernel.org>
 <201601181335.JJD69226.JHVQSMFOFOFtOL@I-love.SAKURA.ne.jp>
 <20160126163823.GG27563@dhcp22.suse.cz>
 <201601282024.JBG90615.JLFQOSFFVOMHtO@I-love.SAKURA.ne.jp>
 <20160128215121.GE621@dhcp22.suse.cz>
 <201601290726.GGC12497.OSQJVtMFFOHOLF@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201601290726.GGC12497.OSQJVtMFFOHOLF@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, hannes@cmpxchg.org, mgorman@suse.de, rientjes@google.com, torvalds@linux-foundation.org, oleg@redhat.com, hughd@google.com, andrea@kernel.org, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri 29-01-16 07:26:39, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Thu 28-01-16 20:24:36, Tetsuo Handa wrote:
> > [...]
> > > I like the OOM reaper approach but I can't agree on merging the OOM reaper
> > > without providing a guaranteed last resort at the same time. If you do want
> > > to start the OOM reaper as simple as possible (without being bothered by
> > > a lot of possible corner cases), please pursue a guaranteed last resort
> > > at the same time.
> > 
> > I am getting tired of this level of argumentation. oom_reaper in its
> > current form is a step forward. I have acknowledged there are possible
> > improvements doable on top but I do not see them necessary for the core
> > part being merged. I am not trying to rush this in because I am very
> > well aware of how subtle and complex all the interactions might be.
> > So please stop your "we must have it all at once" attitude. This is
> > nothing we have to rush in. We are not talking about a regression which
> > has to be absolutely fixed in few days.
> 
> I'm not asking you to merge a perfect version of oom_reaper from the
> beginning. I know it is too difficult. Instead, I'm asking you to allow
> using timeout based approaches (shown below) as temporarily workaround
> because there are environments which cannot wait for oom_reaper to become
> enough reliable. Would you please reply to the thread which proposed a
> guaranteed last resort (shown below)?

I really fail to see why you have to bring that part in this particular
thread or in any other oom related discussion. I didn't get to read
through that discussion and make my opinion yet.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
