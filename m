Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9D5D16B0027
	for <linux-mm@kvack.org>; Mon, 16 Apr 2018 12:30:24 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id t13so1026783pgu.23
        for <linux-mm@kvack.org>; Mon, 16 Apr 2018 09:30:24 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id s3si1789742pfg.175.2018.04.16.09.30.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Apr 2018 09:30:23 -0700 (PDT)
Date: Mon, 16 Apr 2018 12:30:19 -0400
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH AUTOSEL for 4.14 015/161] printk: Add console owner and
 waiter logic to load balance console writes
Message-ID: <20180416123019.4d235374@gandalf.local.home>
In-Reply-To: <20180416161911.GA2341@sasha-vm>
References: <20180409001936.162706-1-alexander.levin@microsoft.com>
	<20180409001936.162706-15-alexander.levin@microsoft.com>
	<20180409082246.34hgp3ymkfqke3a4@pathway.suse.cz>
	<20180415144248.GP2341@sasha-vm>
	<20180416093058.6edca0bb@gandalf.local.home>
	<CA+55aFysLTQN8qRu=nuKttGBZzfQq=BpJBH+TMdgLJR7bgRGYg@mail.gmail.com>
	<20180416113629.2474ae74@gandalf.local.home>
	<20180416160200.GY2341@sasha-vm>
	<20180416121224.2138b806@gandalf.local.home>
	<20180416161911.GA2341@sasha-vm>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <Alexander.Levin@microsoft.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Petr Mladek <pmladek@suse.com>, "stable@vger.kernel.org" <stable@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Byungchul Park <byungchul.park@lge.com>, Tejun Heo <tj@kernel.org>, Pavel Machek <pavel@ucw.cz>

On Mon, 16 Apr 2018 16:19:14 +0000
Sasha Levin <Alexander.Levin@microsoft.com> wrote:

> >Wait! What does that mean? What's the purpose of stable if it is as
> >broken as mainline?  
> 
> This just means that if there is a fix that went in mainline, and the
> fix is broken somehow, we'd rather take the broken fix than not.
> 
> In this scenario, *something* will be broken, it's just a matter of
> what. We'd rather have the same thing broken between mainline and
> stable.

Honestly, I think that removes all value of the stable series. I
remember when the stable series were first created. People were saying
that it wouldn't even get to more than 5 versions, because the bar for
backporting was suppose to be very high. Today it's just a fork of the
kernel at a given version. No more features, but we will be OK with
regressions. I'm struggling to see what the benefit of it is suppose to
be?

-- Steve
