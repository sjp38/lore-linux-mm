Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1A62E6B0038
	for <linux-mm@kvack.org>; Mon, 13 Mar 2017 09:45:22 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id y136so122480306iof.3
        for <linux-mm@kvack.org>; Mon, 13 Mar 2017 06:45:22 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id r23si10978152ioi.218.2017.03.13.06.45.20
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 13 Mar 2017 06:45:21 -0700 (PDT)
Subject: Re: [PATCH v7] mm: Add memory allocation watchdog kernel thread.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20170310104047.GF3753@dhcp22.suse.cz>
	<201703102019.JHJ58283.MQHtVFOOFOLFJS@I-love.SAKURA.ne.jp>
	<20170310152611.GM3753@dhcp22.suse.cz>
	<201703111046.FBB87020.OVOOQFMHFSJLtF@I-love.SAKURA.ne.jp>
	<20170313094504.GH31518@dhcp22.suse.cz>
In-Reply-To: <20170313094504.GH31518@dhcp22.suse.cz>
Message-Id: <201703132245.FBC17698.VtLSFMFOOFOJQH@I-love.SAKURA.ne.jp>
Date: Mon, 13 Mar 2017 22:45:05 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, hannes@cmpxchg.org, mgorman@techsingularity.net, david@fromorbit.com, apolyakov@beget.ru

Michal Hocko wrote:
> On Sat 11-03-17 10:46:58, Tetsuo Handa wrote:
> > In most cases, administrators can't capture even SysRq-t; let alone vmcore.
> > Therefore, automatic watchdog is highly appreciated. Have you considered this aspect?
> 
> yes I have. I tend to work with our SUSE L3 and enterprise customer a
> lot last 10 years. And what I claim is that adding more watchdog doesn't
> necessarily mean we will get better bug reports. I do not have any exact
> statistics but my perception is that allocation lockups tends to be less
> than 1% of reported bugs. You seem to make a huge issue from this
> particular class of issues basing your argumentation on "unknown
> issues which might have been allocation lockups etc." I am not feeling
> comfortable with this kind of arguing and making any decision on them.

Allocation lockups might be less than 1% of _reported_ bugs.
What I'm talking about is that there will be _unreported_ (and therefore
unrecognized/unsolved) bugs caused by memory allocation behavior.
You are refusing to make an attempt to prove/verify/handle it.

> 
> So let me repeat (for the last time). I find your watchdog interesting
> for stress testing but I am not convinced this is generally useful for
> real workloads and the maintenance burden is worth it. I _might_ be
> wrong here and that is why this is _no_ a NAK from me but I feel
> uncomfortable how hard you are pushing this.

If you worry about false positives and/or side effects of watchdog, you can
disable it in your distribution (i.e. SUSE). There are developers/users/customers
who will be helped by it.

> 
> I expect this is my last word on this.

After all, there is no real objection. Andrew, what do you think?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
