Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 10F896B02F7
	for <linux-mm@kvack.org>; Tue, 28 Nov 2017 06:05:56 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id h205so345745iof.15
        for <linux-mm@kvack.org>; Tue, 28 Nov 2017 03:05:56 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id f84sor14006434ioi.360.2017.11.28.03.05.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 28 Nov 2017 03:05:55 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171128104810.5f3lvby64i6x54id@dhcp22.suse.cz>
References: <1506592464-30962-1-git-send-email-laoar.shao@gmail.com>
 <cdfce9d0-9542-3fd1-098c-492d8d9efc11@I-love.SAKURA.ne.jp>
 <20171127091939.tahb77nznytcxw55@dhcp22.suse.cz> <20171128103723.GK5977@quack2.suse.cz>
 <20171128104810.5f3lvby64i6x54id@dhcp22.suse.cz>
From: Yafang Shao <laoar.shao@gmail.com>
Date: Tue, 28 Nov 2017 19:05:54 +0800
Message-ID: <CALOAHbC8DXrk0g-PTizp1rmcXOGATHLWmhBTF20AJHjrXsU0mg@mail.gmail.com>
Subject: Re: [PATCH] Revert "mm/page-writeback.c: print a warning if the vm
 dirtiness settings are illogical" (was: Re: [PATCH] mm: print a warning once
 the vm dirtiness settings is illogical)
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: Jan Kara <jack@suse.cz>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>

2017-11-28 18:48 GMT+08:00 Michal Hocko <mhocko@suse.com>:
> On Tue 28-11-17 11:37:23, Jan Kara wrote:
>> On Mon 27-11-17 10:19:39, Michal Hocko wrote:
>> > Andrew,
>> > could you simply send this to Linus. If we _really_ need something to
>> > prevent misconfiguration, which I doubt to be honest, then it should be
>> > thought through much better.
>>
>> What's so bad about the warning? I think warning about such
>> misconfiguration is not a bad thing per se. Maybe it should be ratelimited
>> and certainly the condition is too loose as your example shows but in
>> principle I'm not against it and e.g. making the inequality in the condition
>> strict like:
>>
>>       if (unlikely(bg_thresh > thresh))
>>
>> or at least
>>
>>       if (unlikely(bg_thresh >= thresh && thresh > 0))
>>
>> would warn about cases where domain_dirty_limits() had to fixup bg_thresh
>> manually to make writeback throttling work and avoid reclaim stalls which
>> is IMHO a sane thing...
>
> If it generates false positives then it is more harmful than useful. And
> even if it doesn't, what is the point? Do we check that other related
> knobs are configured properly? I do not think so, we simply rely on
> admins doing sane things.

Not all admins are good at tuning this.
I don't think every SE knows how to tune vm.dirty_background_bytes and
vm.dirty_background_bytes. Only kernel experts could do that.

At least this warning could help them to learn what happend instead of
knowing nothing.



> Otherwise we would have a lot of warnings like
> that. They would be pain to maintain and I believe the additional value
> is quite dubious.
> --

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
