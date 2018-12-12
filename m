Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8BADE8E00E5
	for <linux-mm@kvack.org>; Wed, 12 Dec 2018 12:43:36 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id l131so12627087pga.2
        for <linux-mm@kvack.org>; Wed, 12 Dec 2018 09:43:36 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id e68si15159009pfb.101.2018.12.12.09.43.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Dec 2018 09:43:35 -0800 (PST)
Date: Wed, 12 Dec 2018 12:43:33 -0500
From: Sasha Levin <sashal@kernel.org>
Subject: Re: 4.14 backport request for dbdda842fe96f: "printk: Add console
 owner and waiter logic to load balance console writes"
Message-ID: <20181212174333.GC2746@sasha-vm>
References: <CAJmjG2-c4e_1999n0OV5B9ABG9rF6n=myThjgX+Ms1R-vc3z+A@mail.gmail.com>
 <20181109064740.GE599@jagdpanzerIV>
 <CAJmjG28Q8pEpr67LC+Un8m+Qii58FTd1esp6Zc47TnMsw50QEw@mail.gmail.com>
 <20181212052126.GF431@jagdpanzerIV>
 <CAJmjG29a7Fax5ZW5Q+W+-1xPEXVUqdrMYwoUpSwL1Msiso6gtw@mail.gmail.com>
 <20181212062841.GI431@jagdpanzerIV>
 <20181212064841.GB2746@sasha-vm>
 <20181212081034.GA32687@jagdpanzerIV>
 <20181212133603.yyu2zvw7g454zdqd@pathway.suse.cz>
 <20181212135939.GA10170@tigerII.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <20181212135939.GA10170@tigerII.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: Petr Mladek <pmladek@suse.com>, Daniel Wang <wonderfly@google.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Steven Rostedt <rostedt@goodmis.org>, stable@vger.kernel.org, Alexander.Levin@microsoft.com, Andrew Morton <akpm@linux-foundation.org>, byungchul.park@lge.com, dave.hansen@intel.com, hannes@cmpxchg.org, jack@suse.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Mel Gorman <mgorman@suse.de>, mhocko@kernel.org, pavel@ucw.cz, penguin-kernel@i-love.sakura.ne.jp, Peter Zijlstra <peterz@infradead.org>, tj@kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, vbabka@suse.cz, Cong Wang <xiyou.wangcong@gmail.com>, Peter Feiner <pfeiner@google.com>

On Wed, Dec 12, 2018 at 10:59:39PM +0900, Sergey Senozhatsky wrote:
>On (12/12/18 14:36), Petr Mladek wrote:
>> > OK, really didn't know that! I wasn't Cc-ed on that AUTOSEL email,
>> > and I wasn't Cc-ed on this whole discussion and found it purely
>> > accidentally while browsing linux-mm list.
>>
>> I am sorry that I did not CC you. There were so many people in CC.
>> I expected that all people mentioned in the related commit message
>> were included by default.
>
>No worries! I'm not blaming anyone.
>
>> > So if you are willing to backport this set to -stable, then I wouldn't
>> > mind, probably would be more correct if we don't advertise this as a
>> > "panic() deadlock fix"
>>
>> This should not be a problem. I guess that stable does not modify
>> the original commit messages unless there is a change.
>
>Agreed.

I'll be happy to add anything you want to the commit message. Do you
have a blurb you want to use?

--
Thanks,
Sasha
