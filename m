Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id B9F276B0003
	for <linux-mm@kvack.org>; Thu, 19 Apr 2018 07:43:50 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id v198-v6so9348lfa.17
        for <linux-mm@kvack.org>; Thu, 19 Apr 2018 04:43:50 -0700 (PDT)
Received: from mx2.yrkesakademin.fi (mx2.yrkesakademin.fi. [85.134.45.195])
        by mx.google.com with ESMTPS id c25si1366438ljb.189.2018.04.19.04.43.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Apr 2018 04:43:48 -0700 (PDT)
Subject: Re: [PATCH AUTOSEL for 4.14 015/161] printk: Add console owner and
 waiter logic to load balance console writes
References: <20180409001936.162706-1-alexander.levin@microsoft.com>
 <20180409001936.162706-15-alexander.levin@microsoft.com>
 <20180409082246.34hgp3ymkfqke3a4@pathway.suse.cz>
 <20180415144248.GP2341@sasha-vm> <20180416093058.6edca0bb@gandalf.local.home>
 <CA+55aFysLTQN8qRu=nuKttGBZzfQq=BpJBH+TMdgLJR7bgRGYg@mail.gmail.com>
 <20180416113629.2474ae74@gandalf.local.home> <20180416160200.GY2341@sasha-vm>
 <20180416121224.2138b806@gandalf.local.home> <20180416161911.GA2341@sasha-vm>
From: Thomas Backlund <tmb@mageia.org>
Message-ID: <7d5de770-aee7-ef71-3582-5354c38fc176@mageia.org>
Date: Thu, 19 Apr 2018 14:41:33 +0300
MIME-Version: 1.0
In-Reply-To: <20180416161911.GA2341@sasha-vm>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Language: sv
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <Alexander.Levin@microsoft.com>, Steven Rostedt <rostedt@goodmis.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Petr Mladek <pmladek@suse.com>, "stable@vger.kernel.org" <stable@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Byungchul Park <byungchul.park@lge.com>, Tejun Heo <tj@kernel.org>, Pavel Machek <pavel@ucw.cz>

Den 16-04-2018 kl. 19:19, skrev Sasha Levin:
> On Mon, Apr 16, 2018 at 12:12:24PM -0400, Steven Rostedt wrote:
>> On Mon, 16 Apr 2018 16:02:03 +0000
>> Sasha Levin <Alexander.Levin@microsoft.com> wrote:
>>
>>> One of the things Greg is pushing strongly for is "bug compatibility":
>>> we want the kernel to behave the same way between mainline and stable.
>>> If the code is broken, it should be broken in the same way.
>>
>> Wait! What does that mean? What's the purpose of stable if it is as
>> broken as mainline?
> 
> This just means that if there is a fix that went in mainline, and the
> fix is broken somehow, we'd rather take the broken fix than not.
> 
> In this scenario, *something* will be broken, it's just a matter of
> what. We'd rather have the same thing broken between mainline and
> stable.
> 

Yeah, but _intentionally_ breaking existing setups to stay "bug 
compatible" _is_ a _regression_ you _really_ _dont_ want in a stable
supported distro. Because end-users dont care about upstream breaking
stuff... its the distro that takes the heat for that...

Something "already broken" is not a regression...

As distro maintainer that means one now have to review _every_ patch 
that carries "AUTOSEL", follow all the mail threads that comes up about 
it, then track if it landed in -stable queue, and read every response 
and possible objection to all patches in the -stable queue a second time 
around... then check if it still got included in final stable point 
relase and then either revert them in distro kernel or go track down all 
the follow-up fixes needed...

Just to avoid being "bug compatible with master"

--
Thomas
