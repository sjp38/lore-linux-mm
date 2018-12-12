Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id CE5C88E00E5
	for <linux-mm@kvack.org>; Wed, 12 Dec 2018 16:43:40 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id x7so13701324pll.23
        for <linux-mm@kvack.org>; Wed, 12 Dec 2018 13:43:40 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id i33si16049183pld.329.2018.12.12.13.43.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Dec 2018 13:43:39 -0800 (PST)
Date: Wed, 12 Dec 2018 16:43:37 -0500
From: Sasha Levin <sashal@kernel.org>
Subject: Re: 4.14 backport request for dbdda842fe96f: "printk: Add console
 owner and waiter logic to load balance console writes"
Message-ID: <20181212214337.GD2746@sasha-vm>
References: <CAJmjG28Q8pEpr67LC+Un8m+Qii58FTd1esp6Zc47TnMsw50QEw@mail.gmail.com>
 <20181212052126.GF431@jagdpanzerIV>
 <CAJmjG29a7Fax5ZW5Q+W+-1xPEXVUqdrMYwoUpSwL1Msiso6gtw@mail.gmail.com>
 <20181212062841.GI431@jagdpanzerIV>
 <20181212064841.GB2746@sasha-vm>
 <20181212081034.GA32687@jagdpanzerIV>
 <20181212133603.yyu2zvw7g454zdqd@pathway.suse.cz>
 <20181212135939.GA10170@tigerII.localdomain>
 <20181212174333.GC2746@sasha-vm>
 <CAJmjG2_zey77QxMzq997ALkD56d0UtHmGjF4dhq=TbEc2gox5A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <CAJmjG2_zey77QxMzq997ALkD56d0UtHmGjF4dhq=TbEc2gox5A@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Wang <wonderfly@google.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Steven Rostedt <rostedt@goodmis.org>, stable@vger.kernel.org, Alexander.Levin@microsoft.com, Andrew Morton <akpm@linux-foundation.org>, byungchul.park@lge.com, dave.hansen@intel.com, hannes@cmpxchg.org, jack@suse.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Mel Gorman <mgorman@suse.de>, mhocko@kernel.org, pavel@ucw.cz, penguin-kernel@i-love.sakura.ne.jp, Peter Zijlstra <peterz@infradead.org>, tj@kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, vbabka@suse.cz, Cong Wang <xiyou.wangcong@gmail.com>, Peter Feiner <pfeiner@google.com>

On Wed, Dec 12, 2018 at 12:11:29PM -0800, Daniel Wang wrote:
>On Wed, Dec 12, 2018 at 9:43 AM Sasha Levin <sashal@kernel.org> wrote:
>>
>> On Wed, Dec 12, 2018 at 10:59:39PM +0900, Sergey Senozhatsky wrote:
>> >On (12/12/18 14:36), Petr Mladek wrote:
>> >> > OK, really didn't know that! I wasn't Cc-ed on that AUTOSEL email,
>> >> > and I wasn't Cc-ed on this whole discussion and found it purely
>> >> > accidentally while browsing linux-mm list.
>> >>
>> >> I am sorry that I did not CC you. There were so many people in CC.
>> >> I expected that all people mentioned in the related commit message
>> >> were included by default.
>> >
>> >No worries! I'm not blaming anyone.
>> >
>> >> > So if you are willing to backport this set to -stable, then I wouldn't
>> >> > mind, probably would be more correct if we don't advertise this as a
>> >> > "panic() deadlock fix"
>> >>
>> >> This should not be a problem. I guess that stable does not modify
>> >> the original commit messages unless there is a change.
>> >
>> >Agreed.
>>
>> I'll be happy to add anything you want to the commit message. Do you
>> have a blurb you want to use?
>
>If we still get to amend the commit message, I'd like to add "Cc:
>stable@vger.kernel.org" in the sign-off area. According to
>https://www.kernel.org/doc/html/v4.12/process/stable-kernel-rules.html#option-1
>patches with that tag will be automatically applied to -stable trees.
>It's unclear though if it'll get applied to ALL -stable trees. For my
>request, I care at least about 4.19 and 4.14. So maybe we can add two
>lines, "Cc: <stable@vger.kernel.org> # 4.14.x" and "Cc:
><stable@vger.kernel.org> # 4.19.x".

We can't change the original commit message (but that's fine, the
purpose of that tag is to let us know that this commit should go in
stable - and no we do :) ).

I was under the impression that Sergey or Petr wanted to add more
information about the purpose of this patch and the issue it solves.

--
Thanks,
Sasha
