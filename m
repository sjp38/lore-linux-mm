Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 159716B029B
	for <linux-mm@kvack.org>; Tue, 19 Dec 2017 08:13:01 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id y2so12551344pgv.8
        for <linux-mm@kvack.org>; Tue, 19 Dec 2017 05:13:01 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id u8sor4027060pgp.171.2017.12.19.05.12.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 19 Dec 2017 05:12:59 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171219130337.GU2787@dhcp22.suse.cz>
References: <001a11452568f5857c0560b0dc0e@google.com> <20171219130337.GU2787@dhcp22.suse.cz>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Tue, 19 Dec 2017 14:12:38 +0100
Message-ID: <CACT4Y+Ye=gdP4tv1T4mGuTsDB0uDGkYncg5LC0X10ab6=xXm9A@mail.gmail.com>
Subject: Re: BUG: unable to handle kernel NULL pointer dereference in __list_del_entry_valid
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: syzbot <bot+83f46cd25e266359cd056c91f6ecd20b04eddf42@syzkaller.appspotmail.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Hillf Danton <hillf.zj@alibaba-inc.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Mel Gorman <mgorman@techsingularity.net>, Minchan Kim <minchan@kernel.org>, shakeelb@google.com, syzkaller-bugs@googlegroups.com, ying.huang@intel.com

On Tue, Dec 19, 2017 at 2:03 PM, Michal Hocko <mhocko@kernel.org> wrote:
> Can we silence this duplicates [1] please?
>
> [1] http://lkml.kernel.org/r/001a1140f57806ebef05608b25a5@google.com

Hi Michal,

What exactly do you mean?

These 2 are the same email with the same Message-ID just on different
mailing lists. I don't see anything wrong here.

https://marc.info/?l=linux-mm&m=151352562529458&w=2
https://marc.info/?l=linux-kernel&m=151352563729460&w=2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
