Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id D5AD96B029D
	for <linux-mm@kvack.org>; Tue, 19 Dec 2017 08:22:12 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id i83so1153056wma.4
        for <linux-mm@kvack.org>; Tue, 19 Dec 2017 05:22:12 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 94si4390845wre.31.2017.12.19.05.22.11
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 19 Dec 2017 05:22:11 -0800 (PST)
Date: Tue, 19 Dec 2017 14:22:09 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: BUG: unable to handle kernel NULL pointer dereference in
 __list_del_entry_valid
Message-ID: <20171219132209.GV2787@dhcp22.suse.cz>
References: <001a11452568f5857c0560b0dc0e@google.com>
 <20171219130337.GU2787@dhcp22.suse.cz>
 <CACT4Y+Ye=gdP4tv1T4mGuTsDB0uDGkYncg5LC0X10ab6=xXm9A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CACT4Y+Ye=gdP4tv1T4mGuTsDB0uDGkYncg5LC0X10ab6=xXm9A@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: syzbot <bot+83f46cd25e266359cd056c91f6ecd20b04eddf42@syzkaller.appspotmail.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Hillf Danton <hillf.zj@alibaba-inc.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Mel Gorman <mgorman@techsingularity.net>, Minchan Kim <minchan@kernel.org>, shakeelb@google.com, syzkaller-bugs@googlegroups.com, ying.huang@intel.com

On Tue 19-12-17 14:12:38, Dmitry Vyukov wrote:
> On Tue, Dec 19, 2017 at 2:03 PM, Michal Hocko <mhocko@kernel.org> wrote:
> > Can we silence this duplicates [1] please?
> >
> > [1] http://lkml.kernel.org/r/001a1140f57806ebef05608b25a5@google.com
> 
> Hi Michal,
> 
> What exactly do you mean?
> 
> These 2 are the same email with the same Message-ID just on different
> mailing lists. I don't see anything wrong here.

Hmm the other one has Message-id: 001a1140f57806ebef05608b25a5@google.com
while this one has 001a11452568f5857c0560b0dc0e@google.com
 
> https://marc.info/?l=linux-mm&m=151352562529458&w=2
> https://marc.info/?l=linux-kernel&m=151352563729460&w=2

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
