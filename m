Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6B8426B02F2
	for <linux-mm@kvack.org>; Tue, 28 Nov 2017 05:48:16 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id 199so25546745pgg.20
        for <linux-mm@kvack.org>; Tue, 28 Nov 2017 02:48:16 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d65si27220450pfm.149.2017.11.28.02.48.15
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 28 Nov 2017 02:48:15 -0800 (PST)
Date: Tue, 28 Nov 2017 11:48:10 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] Revert "mm/page-writeback.c: print a warning if the vm
 dirtiness settings are illogical" (was: Re: [PATCH] mm: print a warning once
 the vm dirtiness settings is illogical)
Message-ID: <20171128104810.5f3lvby64i6x54id@dhcp22.suse.cz>
References: <1506592464-30962-1-git-send-email-laoar.shao@gmail.com>
 <cdfce9d0-9542-3fd1-098c-492d8d9efc11@I-love.SAKURA.ne.jp>
 <20171127091939.tahb77nznytcxw55@dhcp22.suse.cz>
 <20171128103723.GK5977@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171128103723.GK5977@quack2.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Yafang Shao <laoar.shao@gmail.com>, akpm@linux-foundation.org, linux-mm@kvack.org

On Tue 28-11-17 11:37:23, Jan Kara wrote:
> On Mon 27-11-17 10:19:39, Michal Hocko wrote:
> > Andrew,
> > could you simply send this to Linus. If we _really_ need something to
> > prevent misconfiguration, which I doubt to be honest, then it should be
> > thought through much better.
> 
> What's so bad about the warning? I think warning about such
> misconfiguration is not a bad thing per se. Maybe it should be ratelimited
> and certainly the condition is too loose as your example shows but in
> principle I'm not against it and e.g. making the inequality in the condition
> strict like:
> 
> 	if (unlikely(bg_thresh > thresh))
> 
> or at least
> 
> 	if (unlikely(bg_thresh >= thresh && thresh > 0))
> 
> would warn about cases where domain_dirty_limits() had to fixup bg_thresh
> manually to make writeback throttling work and avoid reclaim stalls which
> is IMHO a sane thing...

If it generates false positives then it is more harmful than useful. And
even if it doesn't, what is the point? Do we check that other related
knobs are configured properly? I do not think so, we simply rely on
admins doing sane things. Otherwise we would have a lot of warnings like
that. They would be pain to maintain and I believe the additional value
is quite dubious.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
