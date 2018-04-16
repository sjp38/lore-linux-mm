Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9A37A6B0008
	for <linux-mm@kvack.org>; Mon, 16 Apr 2018 11:36:34 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id c85so9577735pfb.12
        for <linux-mm@kvack.org>; Mon, 16 Apr 2018 08:36:34 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id p14si10746292pff.211.2018.04.16.08.36.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Apr 2018 08:36:33 -0700 (PDT)
Date: Mon, 16 Apr 2018 11:36:29 -0400
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH AUTOSEL for 4.14 015/161] printk: Add console owner and
 waiter logic to load balance console writes
Message-ID: <20180416113629.2474ae74@gandalf.local.home>
In-Reply-To: <CA+55aFysLTQN8qRu=nuKttGBZzfQq=BpJBH+TMdgLJR7bgRGYg@mail.gmail.com>
References: <20180409001936.162706-1-alexander.levin@microsoft.com>
	<20180409001936.162706-15-alexander.levin@microsoft.com>
	<20180409082246.34hgp3ymkfqke3a4@pathway.suse.cz>
	<20180415144248.GP2341@sasha-vm>
	<20180416093058.6edca0bb@gandalf.local.home>
	<CA+55aFysLTQN8qRu=nuKttGBZzfQq=BpJBH+TMdgLJR7bgRGYg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Sasha Levin <Alexander.Levin@microsoft.com>, Petr Mladek <pmladek@suse.com>, "stable@vger.kernel.org" <stable@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Byungchul Park <byungchul.park@lge.com>, Tejun Heo <tj@kernel.org>, Pavel Machek <pavel@ucw.cz>

On Mon, 16 Apr 2018 08:18:09 -0700
Linus Torvalds <torvalds@linux-foundation.org> wrote:

> On Mon, Apr 16, 2018 at 6:30 AM, Steven Rostedt <rostedt@goodmis.org> wrote:
> >
> > I wonder if the "AUTOSEL" patches should at least have an "ack-by" from
> > someone before they are pulled in. Otherwise there may be some subtle
> > issues that can find their way into stable releases.  
> 
> I don't know about anybody else, but I  get so many of the patch-bot
> patches for stable etc that I will *not* reply to normal cases. Only
> if there's some issue with a patch will I reply.
> 
> I probably do get more than most, but still - requiring active
> participation for the steady flow of normal stable patches is almost
> pointless.
> 
> Just look at the subject line of this thread. The numbers are so big
> that you almost need exponential notation for them.
> 

I'm worried about just backporting patches that nobody actually looked
at. Is someone going through and vetting that these should definitely
be added to stable. I would like to have some trusted human (doesn't
even need to be the author or maintainer of the patch) to look at all
the patches before they are applied.

I would say anything more than a trivial patch would require author or
sub maintainer ack. Look at this patch, I don't think it should go to
stable, even though it does fix issues. But the fix is for systems
already having issues, and this keeps printk from making things worse.
The fix has side effects that other commits have addressed, and if this
patch gets backported, those other ones must too.

Maybe I was too strong by saying all patches should be acked, but
anything more than buffer overflows and off by one errors probably
require a bit more vetting by a human than to just pull in all patches
that a bot flags to be backported.

-- Steve
