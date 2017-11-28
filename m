Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1FA2B6B0069
	for <linux-mm@kvack.org>; Tue, 28 Nov 2017 06:54:35 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id t76so44701pfk.7
        for <linux-mm@kvack.org>; Tue, 28 Nov 2017 03:54:35 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d126si2486634pgc.821.2017.11.28.03.54.33
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 28 Nov 2017 03:54:33 -0800 (PST)
Date: Tue, 28 Nov 2017 12:54:29 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] Revert "mm/page-writeback.c: print a warning if the vm
 dirtiness settings are illogical" (was: Re: [PATCH] mm: print a warning once
 the vm dirtiness settings is illogical)
Message-ID: <20171128115429.qcotdcnhdbjd72tz@dhcp22.suse.cz>
References: <1506592464-30962-1-git-send-email-laoar.shao@gmail.com>
 <cdfce9d0-9542-3fd1-098c-492d8d9efc11@I-love.SAKURA.ne.jp>
 <20171127091939.tahb77nznytcxw55@dhcp22.suse.cz>
 <20171128103723.GK5977@quack2.suse.cz>
 <20171128104810.5f3lvby64i6x54id@dhcp22.suse.cz>
 <CALOAHbC8DXrk0g-PTizp1rmcXOGATHLWmhBTF20AJHjrXsU0mg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALOAHbC8DXrk0g-PTizp1rmcXOGATHLWmhBTF20AJHjrXsU0mg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yafang Shao <laoar.shao@gmail.com>
Cc: Jan Kara <jack@suse.cz>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>

On Tue 28-11-17 19:05:54, Yafang Shao wrote:
> 2017-11-28 18:48 GMT+08:00 Michal Hocko <mhocko@suse.com>:
> > On Tue 28-11-17 11:37:23, Jan Kara wrote:
> >> On Mon 27-11-17 10:19:39, Michal Hocko wrote:
> >> > Andrew,
> >> > could you simply send this to Linus. If we _really_ need something to
> >> > prevent misconfiguration, which I doubt to be honest, then it should be
> >> > thought through much better.
> >>
> >> What's so bad about the warning? I think warning about such
> >> misconfiguration is not a bad thing per se. Maybe it should be ratelimited
> >> and certainly the condition is too loose as your example shows but in
> >> principle I'm not against it and e.g. making the inequality in the condition
> >> strict like:
> >>
> >>       if (unlikely(bg_thresh > thresh))
> >>
> >> or at least
> >>
> >>       if (unlikely(bg_thresh >= thresh && thresh > 0))
> >>
> >> would warn about cases where domain_dirty_limits() had to fixup bg_thresh
> >> manually to make writeback throttling work and avoid reclaim stalls which
> >> is IMHO a sane thing...
> >
> > If it generates false positives then it is more harmful than useful. And
> > even if it doesn't, what is the point? Do we check that other related
> > knobs are configured properly? I do not think so, we simply rely on
> > admins doing sane things.
> 
> Not all admins are good at tuning this.
> I don't think every SE knows how to tune vm.dirty_background_bytes and
> vm.dirty_background_bytes. Only kernel experts could do that.

So are you saying that people tend to configure system randomly without
reading documentation? Seriously, this whole thing has generated much
more discussion than it deserves. I really fail to see why you are
insisting without admiting that the thing is just broken and you do not
have a great idea to fix it without adding even more hacks on top of
what we have currently.

> At least this warning could help them to learn what happend instead of
> knowing nothing.

That is what we have a documentation for. If it needs improvements then
I am all for it.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
