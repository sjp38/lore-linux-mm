Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3F6AC6B0275
	for <linux-mm@kvack.org>; Tue, 19 Dec 2017 08:42:38 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id t15so1177168wmh.3
        for <linux-mm@kvack.org>; Tue, 19 Dec 2017 05:42:38 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i88si11373948wri.407.2017.12.19.05.42.36
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 19 Dec 2017 05:42:37 -0800 (PST)
Date: Tue, 19 Dec 2017 14:42:35 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: BUG: unable to handle kernel NULL pointer dereference in
 __list_del_entry_valid
Message-ID: <20171219134235.GW2787@dhcp22.suse.cz>
References: <001a11452568f5857c0560b0dc0e@google.com>
 <20171219130337.GU2787@dhcp22.suse.cz>
 <CACT4Y+Ye=gdP4tv1T4mGuTsDB0uDGkYncg5LC0X10ab6=xXm9A@mail.gmail.com>
 <20171219132209.GV2787@dhcp22.suse.cz>
 <CACT4Y+aqFuVToOQH8RnfahhonaQ=qvq5JTvL-9aAKBQAa7UOug@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CACT4Y+aqFuVToOQH8RnfahhonaQ=qvq5JTvL-9aAKBQAa7UOug@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: syzbot <bot+83f46cd25e266359cd056c91f6ecd20b04eddf42@syzkaller.appspotmail.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Hillf Danton <hillf.zj@alibaba-inc.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Mel Gorman <mgorman@techsingularity.net>, Minchan Kim <minchan@kernel.org>, shakeelb@google.com, syzkaller-bugs@googlegroups.com, ying.huang@intel.com, syzkaller <syzkaller@googlegroups.com>

On Tue 19-12-17 14:38:35, Dmitry Vyukov wrote:
> On Tue, Dec 19, 2017 at 2:22 PM, Michal Hocko <mhocko@kernel.org> wrote:
> > On Tue 19-12-17 14:12:38, Dmitry Vyukov wrote:
> >> On Tue, Dec 19, 2017 at 2:03 PM, Michal Hocko <mhocko@kernel.org> wrote:
> >> > Can we silence this duplicates [1] please?
> >> >
> >> > [1] http://lkml.kernel.org/r/001a1140f57806ebef05608b25a5@google.com
> >>
> >> Hi Michal,
> >>
> >> What exactly do you mean?
> >>
> >> These 2 are the same email with the same Message-ID just on different
> >> mailing lists. I don't see anything wrong here.
> >
> > Hmm the other one has Message-id: 001a1140f57806ebef05608b25a5@google.com
> > while this one has 001a11452568f5857c0560b0dc0e@google.com
> 
> Ah, I see.
> These are reported separately because the crashes are titled
> differently. Kernel titled one as "general protection fault" and
> another as "BUG: unable to handle kernel NULL pointer dereference".

Ahh, OK, so I've missed that part ;) I just thought it was duplicate
because the report seemed very familiar.

> What algorithm do you propose to use to merge them?

Maybe based on the stack trace?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
