Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 11EF66B0028
	for <linux-mm@kvack.org>; Mon, 16 Apr 2018 12:53:13 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id x184so9721881pfd.14
        for <linux-mm@kvack.org>; Mon, 16 Apr 2018 09:53:13 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id b2si10038378pgc.275.2018.04.16.09.53.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Apr 2018 09:53:11 -0700 (PDT)
Date: Mon, 16 Apr 2018 12:53:07 -0400
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH AUTOSEL for 4.14 015/161] printk: Add console owner and
 waiter logic to load balance console writes
Message-ID: <20180416125307.0c4f6f28@gandalf.local.home>
In-Reply-To: <20180416164310.GF2341@sasha-vm>
References: <20180409082246.34hgp3ymkfqke3a4@pathway.suse.cz>
	<20180415144248.GP2341@sasha-vm>
	<20180416093058.6edca0bb@gandalf.local.home>
	<CA+55aFysLTQN8qRu=nuKttGBZzfQq=BpJBH+TMdgLJR7bgRGYg@mail.gmail.com>
	<20180416153031.GA5039@amd>
	<20180416155031.GX2341@sasha-vm>
	<20180416160608.GA7071@amd>
	<20180416122019.1c175925@gandalf.local.home>
	<20180416162757.GB2341@sasha-vm>
	<20180416163952.GA8740@amd>
	<20180416164310.GF2341@sasha-vm>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <Alexander.Levin@microsoft.com>
Cc: Pavel Machek <pavel@ucw.cz>, Linus Torvalds <torvalds@linux-foundation.org>, Petr Mladek <pmladek@suse.com>, "stable@vger.kernel.org" <stable@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Byungchul Park <byungchul.park@lge.com>, Tejun Heo <tj@kernel.org>, Greg KH <gregkh@linuxfoundation.org>

On Mon, 16 Apr 2018 16:43:13 +0000
Sasha Levin <Alexander.Levin@microsoft.com> wrote:

> >If you are worried about people not putting enough "Stable: " tags in
> >their commits, perhaps you can write them emails "hey, I think this
> >should go to stable, do you agree"? You should get people marking
> >their commits themselves pretty quickly...  
> 
> Greg has been doing this for years, ask him how that worked out for him.

Then he shouldn't pull in the fix. Let it be broken. As soon as someone
complains about it being broken, then bug the maintainer again. "Hey,
this is broken in 4.x, and this looks like the fix for it. Do you
agree?"

I agree that some patches don't need this discussion. Things that are
obvious. Off-by-one and stack-overflow and other bugs like that. Or
another common bug is error paths that don't release locks. These
should just be backported. But subtle fixes like this thread should
default to (not backport unless someones complains or the
author/maintainer acks it).

-- Steve
