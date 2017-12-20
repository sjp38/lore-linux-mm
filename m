Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 83ED66B0038
	for <linux-mm@kvack.org>; Wed, 20 Dec 2017 05:00:32 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id l3so1913982wrf.4
        for <linux-mm@kvack.org>; Wed, 20 Dec 2017 02:00:32 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j32si5761949wra.191.2017.12.20.02.00.31
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 20 Dec 2017 02:00:31 -0800 (PST)
Date: Wed, 20 Dec 2017 11:00:29 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: BUG: unable to handle kernel NULL pointer dereference in
 __list_del_entry_valid
Message-ID: <20171220100029.GH4831@dhcp22.suse.cz>
References: <001a11452568f5857c0560b0dc0e@google.com>
 <20171219130337.GU2787@dhcp22.suse.cz>
 <CACT4Y+Ye=gdP4tv1T4mGuTsDB0uDGkYncg5LC0X10ab6=xXm9A@mail.gmail.com>
 <20171219132209.GV2787@dhcp22.suse.cz>
 <CACT4Y+aqFuVToOQH8RnfahhonaQ=qvq5JTvL-9aAKBQAa7UOug@mail.gmail.com>
 <20171219134235.GW2787@dhcp22.suse.cz>
 <CACT4Y+YqwhSyxRAGVQNQBqKPVe4WKa=5ZyKfW78qY9CDOs1r3w@mail.gmail.com>
 <20171220092046.GE4831@dhcp22.suse.cz>
 <CACT4Y+achWa2fCT9LWeHas6gOLtMwk28XZLkkfFF++D1X=9mVw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CACT4Y+achWa2fCT9LWeHas6gOLtMwk28XZLkkfFF++D1X=9mVw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: syzbot <bot+83f46cd25e266359cd056c91f6ecd20b04eddf42@syzkaller.appspotmail.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Mel Gorman <mgorman@techsingularity.net>, Minchan Kim <minchan@kernel.org>, Shakeel Butt <shakeelb@google.com>, syzkaller-bugs@googlegroups.com, ying.huang@intel.com, syzkaller <syzkaller@googlegroups.com>

On Wed 20-12-17 10:24:51, Dmitry Vyukov wrote:
> On Wed, Dec 20, 2017 at 10:20 AM, Michal Hocko <mhocko@kernel.org> wrote:
> > On Tue 19-12-17 17:40:19, Dmitry Vyukov wrote:
> >> On Tue, Dec 19, 2017 at 2:42 PM, Michal Hocko <mhocko@kernel.org> wrote:
> >> >> >> > Can we silence this duplicates [1] please?
> >> >> >> >
> >> >> >> > [1] http://lkml.kernel.org/r/001a1140f57806ebef05608b25a5@google.com
> >> >> >>
> >> >> >> Hi Michal,
> >> >> >>
> >> >> >> What exactly do you mean?
> >> >> >>
> >> >> >> These 2 are the same email with the same Message-ID just on different
> >> >> >> mailing lists. I don't see anything wrong here.
> >> >> >
> >> >> > Hmm the other one has Message-id: 001a1140f57806ebef05608b25a5@google.com
> >> >> > while this one has 001a11452568f5857c0560b0dc0e@google.com
> >> >>
> >> >> Ah, I see.
> >> >> These are reported separately because the crashes are titled
> >> >> differently. Kernel titled one as "general protection fault" and
> >> >> another as "BUG: unable to handle kernel NULL pointer dereference".
> >> >
> >> > Ahh, OK, so I've missed that part ;) I just thought it was duplicate
> >> > because the report seemed very familiar.
> >>
> >>
> >> So are these duplicates? If yes, we need to tell this syzbot:
> >
> > It seems so.
> 
> Please tell this directly to syzbot next time.
> 
> #syz dup: general protection fault in __list_del_entry_valid (2)

OK.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
