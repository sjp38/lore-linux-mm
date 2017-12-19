Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id A25056B0069
	for <linux-mm@kvack.org>; Tue, 19 Dec 2017 08:54:46 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id a2so1770769pgw.15
        for <linux-mm@kvack.org>; Tue, 19 Dec 2017 05:54:46 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id z7sor4367495pfk.96.2017.12.19.05.54.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 19 Dec 2017 05:54:45 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171219134235.GW2787@dhcp22.suse.cz>
References: <001a11452568f5857c0560b0dc0e@google.com> <20171219130337.GU2787@dhcp22.suse.cz>
 <CACT4Y+Ye=gdP4tv1T4mGuTsDB0uDGkYncg5LC0X10ab6=xXm9A@mail.gmail.com>
 <20171219132209.GV2787@dhcp22.suse.cz> <CACT4Y+aqFuVToOQH8RnfahhonaQ=qvq5JTvL-9aAKBQAa7UOug@mail.gmail.com>
 <20171219134235.GW2787@dhcp22.suse.cz>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Tue, 19 Dec 2017 14:54:24 +0100
Message-ID: <CACT4Y+YAQGj6j+YJZuqGZYrDLYrY3K3sC1MOx9HvOJH=vbjxvQ@mail.gmail.com>
Subject: Re: BUG: unable to handle kernel NULL pointer dereference in __list_del_entry_valid
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: syzbot <bot+83f46cd25e266359cd056c91f6ecd20b04eddf42@syzkaller.appspotmail.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Hillf Danton <hillf.zj@alibaba-inc.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Mel Gorman <mgorman@techsingularity.net>, Minchan Kim <minchan@kernel.org>, shakeelb@google.com, syzkaller-bugs@googlegroups.com, ying.huang@intel.com, syzkaller <syzkaller@googlegroups.com>

On Tue, Dec 19, 2017 at 2:42 PM, Michal Hocko <mhocko@kernel.org> wrote:
> On Tue 19-12-17 14:38:35, Dmitry Vyukov wrote:
>> On Tue, Dec 19, 2017 at 2:22 PM, Michal Hocko <mhocko@kernel.org> wrote:
>> > On Tue 19-12-17 14:12:38, Dmitry Vyukov wrote:
>> >> On Tue, Dec 19, 2017 at 2:03 PM, Michal Hocko <mhocko@kernel.org> wrote:
>> >> > Can we silence this duplicates [1] please?
>> >> >
>> >> > [1] http://lkml.kernel.org/r/001a1140f57806ebef05608b25a5@google.com
>> >>
>> >> Hi Michal,
>> >>
>> >> What exactly do you mean?
>> >>
>> >> These 2 are the same email with the same Message-ID just on different
>> >> mailing lists. I don't see anything wrong here.
>> >
>> > Hmm the other one has Message-id: 001a1140f57806ebef05608b25a5@google.com
>> > while this one has 001a11452568f5857c0560b0dc0e@google.com
>>
>> Ah, I see.
>> These are reported separately because the crashes are titled
>> differently. Kernel titled one as "general protection fault" and
>> another as "BUG: unable to handle kernel NULL pointer dereference".
>
> Ahh, OK, so I've missed that part ;) I just thought it was duplicate
> because the report seemed very familiar.
>
>> What algorithm do you propose to use to merge them?
>
> Maybe based on the stack trace?

You are subscribing to _lots_ of mail ;)
syzbot has reported 250 bugs in 2 months:
https://groups.google.com/forum/#!forum/syzkaller-bugs
with stacks it will be thousands and that will produce lots of other
duplicates (same functionality accessible from different stacks).

Also, linux kernel does not allow reliable stack extraction since it
doesn't stop other CPUs, frequently reports look as complete
intermixed mess with lines coming from different reports, lines split
in half, etc. To rely on stacks we need to be able to _very_ reliably
extract whole stack, but it's hardly possible today.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
