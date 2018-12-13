Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 739F98E0161
	for <linux-mm@kvack.org>; Wed, 12 Dec 2018 21:08:00 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id h11so432812pfj.13
        for <linux-mm@kvack.org>; Wed, 12 Dec 2018 18:08:00 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q2sor683417plh.10.2018.12.12.18.07.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 12 Dec 2018 18:07:59 -0800 (PST)
Date: Thu, 13 Dec 2018 11:07:54 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: 4.14 backport request for dbdda842fe96f: "printk: Add console
 owner and waiter logic to load balance console writes"
Message-ID: <20181213020754.GB4860@jagdpanzerIV>
References: <20181212062841.GI431@jagdpanzerIV>
 <20181212064841.GB2746@sasha-vm>
 <20181212081034.GA32687@jagdpanzerIV>
 <20181212133603.yyu2zvw7g454zdqd@pathway.suse.cz>
 <20181212135939.GA10170@tigerII.localdomain>
 <20181212174333.GC2746@sasha-vm>
 <CAJmjG2_zey77QxMzq997ALkD56d0UtHmGjF4dhq=TbEc2gox5A@mail.gmail.com>
 <20181212214337.GD2746@sasha-vm>
 <CAJmjG2_C0YRtVmNh2sg4JqhJJ11LMmbRHqwADxyO9CGh9ixQbA@mail.gmail.com>
 <20181212215225.GE2746@sasha-vm>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181212215225.GE2746@sasha-vm>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sashal@kernel.org>
Cc: Daniel Wang <wonderfly@google.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Steven Rostedt <rostedt@goodmis.org>, stable@vger.kernel.org, Alexander.Levin@microsoft.com, Andrew Morton <akpm@linux-foundation.org>, byungchul.park@lge.com, dave.hansen@intel.com, hannes@cmpxchg.org, jack@suse.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Mel Gorman <mgorman@suse.de>, mhocko@kernel.org, pavel@ucw.cz, penguin-kernel@i-love.sakura.ne.jp, Peter Zijlstra <peterz@infradead.org>, tj@kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, vbabka@suse.cz, Cong Wang <xiyou.wangcong@gmail.com>, Peter Feiner <pfeiner@google.com>

On (12/12/18 16:52), Sasha Levin wrote:
> On Wed, Dec 12, 2018 at 01:49:25PM -0800, Daniel Wang wrote:
> > Thanks for the clarification. So I guess I don't need to start another
> > thread for it? What are the next steps?
> 
> Nothing here, I'll queue it once Sergey or Petr clarify if they wanted
> additional information in the -stable commit message.

Hi Sasha,

No, no commit message change requests from my side.

	-ss
