Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id AE9166B0038
	for <linux-mm@kvack.org>; Tue, 19 Dec 2017 11:40:41 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id f7so14810329pfa.21
        for <linux-mm@kvack.org>; Tue, 19 Dec 2017 08:40:41 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id u12sor3638542pgq.389.2017.12.19.08.40.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 19 Dec 2017 08:40:40 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171219134235.GW2787@dhcp22.suse.cz>
References: <001a11452568f5857c0560b0dc0e@google.com> <20171219130337.GU2787@dhcp22.suse.cz>
 <CACT4Y+Ye=gdP4tv1T4mGuTsDB0uDGkYncg5LC0X10ab6=xXm9A@mail.gmail.com>
 <20171219132209.GV2787@dhcp22.suse.cz> <CACT4Y+aqFuVToOQH8RnfahhonaQ=qvq5JTvL-9aAKBQAa7UOug@mail.gmail.com>
 <20171219134235.GW2787@dhcp22.suse.cz>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Tue, 19 Dec 2017 17:40:19 +0100
Message-ID: <CACT4Y+YqwhSyxRAGVQNQBqKPVe4WKa=5ZyKfW78qY9CDOs1r3w@mail.gmail.com>
Subject: Re: BUG: unable to handle kernel NULL pointer dereference in __list_del_entry_valid
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: syzbot <bot+83f46cd25e266359cd056c91f6ecd20b04eddf42@syzkaller.appspotmail.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Mel Gorman <mgorman@techsingularity.net>, Minchan Kim <minchan@kernel.org>, shakeelb@google.com, syzkaller-bugs@googlegroups.com, ying.huang@intel.com, syzkaller <syzkaller@googlegroups.com>

On Tue, Dec 19, 2017 at 2:42 PM, Michal Hocko <mhocko@kernel.org> wrote:
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


So are these duplicates? If yes, we need to tell this syzbot:

> syzbot will keep track of this bug report.
> To mark this as a duplicate of another syzbot report, please reply with:
> #syz dup: exact-subject-of-another-report
> Note: all commands must start from beginning of the line in the email body.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
