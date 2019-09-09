Return-Path: <SRS0=8wNw=XE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 07EE3C4360D
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 01:10:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C097020854
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 01:10:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="lbxLDfcL"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C097020854
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 59B7C6B0005; Sun,  8 Sep 2019 21:10:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 524786B0006; Sun,  8 Sep 2019 21:10:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3EC7E6B0007; Sun,  8 Sep 2019 21:10:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0003.hostedemail.com [216.40.44.3])
	by kanga.kvack.org (Postfix) with ESMTP id 154186B0005
	for <linux-mm@kvack.org>; Sun,  8 Sep 2019 21:10:25 -0400 (EDT)
Received: from smtpin01.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id B30D58243762
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 01:10:24 +0000 (UTC)
X-FDA: 75913601568.01.elbow94_3dbd7525e3552
X-HE-Tag: elbow94_3dbd7525e3552
X-Filterd-Recvd-Size: 5137
Received: from mail-pg1-f196.google.com (mail-pg1-f196.google.com [209.85.215.196])
	by imf06.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 01:10:24 +0000 (UTC)
Received: by mail-pg1-f196.google.com with SMTP id x15so6799999pgg.8
        for <linux-mm@kvack.org>; Sun, 08 Sep 2019 18:10:24 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=OIovLqZ8dndVfgy4bS5bku+Skn01UN36L7YbEWe4yhw=;
        b=lbxLDfcLHoEKq7QwulF8CGpwNbxQWZEmLCfz/9fdnClPG6kBHrUkUA87vaBr5UNBdS
         b+8jWVpHZ1drk30QaPgcvQNO7LtwRn5uadC72pzEBiJUIx+X1tBFQ1XlQiayEsqRe74w
         jCTab/fObzBXTYSVNx0DlDtckQzubsesiDGy+Oa//B0aXtJpRFB0snA1tjOKNeLySXaU
         BF70FBEwh04yA41fAXtr79jeOqocLTWCq1Z5V0wZjZxxYO6/hs0YIF95wGFS1rYroFet
         uhz1gSTV5eIHjp/f1WeABeVgz7DPHh4Fw42QOcIfDeWzqrOeiphZrfuzwIHu1MtBJzVi
         zRRw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to:user-agent;
        bh=OIovLqZ8dndVfgy4bS5bku+Skn01UN36L7YbEWe4yhw=;
        b=XsFntqubeL0cu7c02WVJJz0rA3JM2sYe4bnCQ2bpWAtY5geqF9kDtyLvqaxGWpxqUT
         JCyjb1/93zDhUuo0BchwxdrHlki8l+jgB9khyK+j/YUDh/H0861+jqYJr7l/HqOvPSA0
         Ai/Sf4mV9+aMgTzqeodFAN6wnw5d/wd1xdFywLuEkoZsOrxqEfziLE6Ika1obQ0MH0ZU
         blb8N5CklKhQ83fXDr4zGcMEQblzur7u9/te5DOiYetXE8Tv8JBsA+SMe0mkVzFJKX2o
         mTzn8AwRSs/YMZwyMgmhp93bhKH49et9weN588vW7XbWuL+soxY1azmZ8rVQ9O0ROH14
         tW1A==
X-Gm-Message-State: APjAAAWZRdMnjyO5Ke9wzAJx7NUw2IAu6P6FZI5LQwiogZ06lMDfsdzn
	3ugShH/9GUx8TZgrMCpbD3Q=
X-Google-Smtp-Source: APXvYqzYZOL2H+AO47roS6quUoNyMxcsV/gsDZ5uGmZvAcUnt1tQhmDYovzK8DvnQqwgXxNF0LA8bQ==
X-Received: by 2002:a63:1020:: with SMTP id f32mr19739610pgl.203.1567991423070;
        Sun, 08 Sep 2019 18:10:23 -0700 (PDT)
Received: from localhost ([110.70.15.13])
        by smtp.gmail.com with ESMTPSA id v43sm24235493pjb.1.2019.09.08.18.10.21
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Sun, 08 Sep 2019 18:10:22 -0700 (PDT)
Date: Mon, 9 Sep 2019 10:10:18 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
To: Petr Mladek <pmladek@suse.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>,
	Steven Rostedt <rostedt@goodmis.org>, davem@davemloft.net,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Sergey Senozhatsky <sergey.senozhatsky@gmail.com>,
	Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org,
	Qian Cai <cai@lca.pw>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Subject: Re: [PATCH] net/skbuff: silence warnings under memory pressure
Message-ID: <20190909011018.GB816@jagdpanzerIV>
References: <20190904065455.GE3838@dhcp22.suse.cz>
 <20190904071911.GB11968@jagdpanzerIV>
 <20190904074312.GA25744@jagdpanzerIV>
 <1567599263.5576.72.camel@lca.pw>
 <20190904144850.GA8296@tigerII.localdomain>
 <1567629737.5576.87.camel@lca.pw>
 <20190905113208.GA521@jagdpanzerIV>
 <20190905132334.52b13d95@oasis.local.home>
 <20190906033900.GB1253@jagdpanzerIV>
 <20190906153209.ugkeuaespn2q5yix@pathway.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190906153209.ugkeuaespn2q5yix@pathway.suse.cz>
User-Agent: Mutt/1.12.1 (2019-06-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On (09/06/19 17:32), Petr Mladek wrote:
> > [..]
> > > I mean, really, do we need to keep calling wake up if it
> > > probably never even executed?
> > 
> > I guess ratelimiting you are talking about ("if it probably never even
> > executed") would be to check if we have already called wake up on the
> > log_wait ->head. For that we need to, at least, take log_wait spin_lock
> > and check that ->head is still in TASK_INTERRUPTIBLE; which is (quite,
> > but not exactly) close to what wake_up_interruptible() does - it doesn't
> > wake up the same task twice, it bails out on `p->state & state' check.
> 
> I have just realized that only sleeping tasks are in the waitqueue.
> It is already handled by waitqueue_active() check.

Yes.

> I am afraid that we could not ratelimit the wakeups. The userspace
> loggers might then miss the last lines for a long.

That's my concern as well.

> We could move wake_up_klogd() back to console_unlock(). But it might
> end up with a back-and-forth games according to who is currently
> complaining.

We still don't need irq_work, tho.

If we can do
	printk()->console_unlock()->up()->try_to_wake_up()
then we can also do
	printk()           ->             try_to_wake_up()

It's LOGLEVEL_SCHED which tells us if we can try_to_wake_up()
or cannot.

> Sigh, I still suggest to ratelimit the warning about failed
> allocation.

Hard to imagine how many printk()-s we will have to ratelimit.
To imagine NET maintainers being OK with this is even harder.

	-ss

