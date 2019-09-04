Return-Path: <SRS0=zrK/=W7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_2 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2F413C3A5A7
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 12:28:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E18AD21670
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 12:28:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="nOilGNTc"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E18AD21670
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4BA156B0007; Wed,  4 Sep 2019 08:28:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 46A0A6B0008; Wed,  4 Sep 2019 08:28:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 331186B000A; Wed,  4 Sep 2019 08:28:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0087.hostedemail.com [216.40.44.87])
	by kanga.kvack.org (Postfix) with ESMTP id 116066B0007
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 08:28:41 -0400 (EDT)
Received: from smtpin05.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 984CF82437C9
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 12:28:40 +0000 (UTC)
X-FDA: 75897166800.05.dock75_117f052e64856
X-HE-Tag: dock75_117f052e64856
X-Filterd-Recvd-Size: 7008
Received: from mail-qk1-f195.google.com (mail-qk1-f195.google.com [209.85.222.195])
	by imf15.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 12:28:40 +0000 (UTC)
Received: by mail-qk1-f195.google.com with SMTP id f13so19301466qkm.9
        for <linux-mm@kvack.org>; Wed, 04 Sep 2019 05:28:40 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=message-id:subject:from:to:cc:date:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=Phz7WXzv6Ct7YpQWtzarTC/I6lNnHjJSWTLNUVbUJ58=;
        b=nOilGNTc9cCP6FpwLk6qvpoQyoZl90VbEwFYl8NT8jOuHHiEjdeuahcPADU2Pebmis
         NijtefwV+KczPPFXMxNGu848/zzUIUIHi7U7Kn54Ihw+oftFwHim8kSIuZXRuWSdyI9t
         rYubQ8WNr6ppRxODnaQA68xxtNtiOtjNLZCvxbMa3LqKylO4tRazqeqLTLc5KP2d2kRI
         H3pYMcxK0edI+HQoIZlXLPNbUcntA1lwOmyr4l0vGMh9DRI8ZoueYi7w6J7caUqpsGQ4
         JvSM+RxE/a9xhYQKsaQ0g7N6TGlo4U7JXoFfnW3yM9DUWkC+ZYaEq3vzyYjgewiSsaHN
         Tmdg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:message-id:subject:from:to:cc:date:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=Phz7WXzv6Ct7YpQWtzarTC/I6lNnHjJSWTLNUVbUJ58=;
        b=DjC5hgd9us8hUyq29zRXK3AaQc788iocD4P2djjZvDJPnONKwAuZg0d0x623TrxM1b
         90N5AJTGHaNpTl3/GyMD3e598k7x6xRa2XiPNhUQLS840lC3ZxP8BPeyQEcOypcdT7sr
         HnOReF/f+THfmZ0UHdFs5pohzcyE3yEmwcE0SErMcX3BMkk14qbrqDnUOvQpyB4Gfuyd
         4g2U2CHssJBOI1vMKZLUMVR/1RK3KEVDzvWl+455U7OCs6Twq/ZfS188LqYVNYD0z4Fj
         Xdd/EX2aonQEwMXtN/7i5Gxftftd1PagEMbmBNiFnwtgw5ZBdsVvSYuI4PBtG4+YxQl3
         5cQw==
X-Gm-Message-State: APjAAAU6MpoH9/n4FMeps1FHB/DMltwBDeIFWntZd/9eG9U9NwCl1hI5
	X/ZSkikpPMFBDmXbbNuoIhjBnQ==
X-Google-Smtp-Source: APXvYqx8rN7sFPqe6qrKVFbdcUKWdMjPHWcg92o9NcYsHU72G8AgpHj4Tr5vJugp098iNgH2ZDH9rQ==
X-Received: by 2002:a05:620a:1539:: with SMTP id n25mr12867915qkk.0.1567600119605;
        Wed, 04 Sep 2019 05:28:39 -0700 (PDT)
Received: from dhcp-41-57.bos.redhat.com (nat-pool-bos-t.redhat.com. [66.187.233.206])
        by smtp.gmail.com with ESMTPSA id y23sm9544425qki.118.2019.09.04.05.28.37
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Sep 2019 05:28:38 -0700 (PDT)
Message-ID: <1567600117.5576.74.camel@lca.pw>
Subject: Re: [PATCH] net/skbuff: silence warnings under memory pressure
From: Qian Cai <cai@lca.pw>
To: Michal Hocko <mhocko@kernel.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Eric Dumazet
 <eric.dumazet@gmail.com>, davem@davemloft.net, netdev@vger.kernel.org, 
 linux-mm@kvack.org, linux-kernel@vger.kernel.org, Petr Mladek
 <pmladek@suse.com>,  Sergey Senozhatsky <sergey.senozhatsky@gmail.com>,
 Steven Rostedt <rostedt@goodmis.org>
Date: Wed, 04 Sep 2019 08:28:37 -0400
In-Reply-To: <20190904120707.GU3838@dhcp22.suse.cz>
References: <229ebc3b-1c7e-474f-36f9-0fa603b889fb@gmail.com>
	 <20190903132231.GC18939@dhcp22.suse.cz> <1567525342.5576.60.camel@lca.pw>
	 <20190903185305.GA14028@dhcp22.suse.cz> <1567546948.5576.68.camel@lca.pw>
	 <20190904061501.GB3838@dhcp22.suse.cz> <20190904064144.GA5487@jagdpanzerIV>
	 <20190904070042.GA11968@jagdpanzerIV>
	 <20190904082540.GI3838@dhcp22.suse.cz> <1567598357.5576.70.camel@lca.pw>
	 <20190904120707.GU3838@dhcp22.suse.cz>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.22.6 (3.22.6-10.el7) 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2019-09-04 at 14:07 +0200, Michal Hocko wrote:
> On Wed 04-09-19 07:59:17, Qian Cai wrote:
> > On Wed, 2019-09-04 at 10:25 +0200, Michal Hocko wrote:
> > > On Wed 04-09-19 16:00:42, Sergey Senozhatsky wrote:
> > > > On (09/04/19 15:41), Sergey Senozhatsky wrote:
> > > > > But the thing is different in case of dump_stack() + show_mem() +
> > > > > some other output. Because now we ratelimit not a single printk()
> > > > > line,
> > > > > but hundreds of them. The ratelimit becomes - 10 * $$$ lines in 5
> > > > > seconds
> > > > > (IOW, now we talk about thousands of lines).
> > > > 
> > > > And on devices with slow serial consoles this can be somewhat close to
> > > > "no ratelimit". *Suppose* that warn_alloc() adds 700 lines each time.
> > > > Within 5 seconds we can call warn_alloc() 10 times, which will add 7000
> > > > lines to the logbuf. If printk() can evict only 6000 lines in 5 seconds
> > > > then we have a growing number of pending logbuf messages.
> > > 
> > > Yes, ratelimit is problematic when the ratelimited operation is slow. I
> > > guess that is a well known problem and we would need to rework both the
> > > api and the implementation to make it work in those cases as well.
> > > Essentially we need to make the ratelimit act as a gatekeeper to an
> > > operation section - something like a critical section except you can
> > > tolerate more code executions but not too many. So effectively
> > > 
> > > 	start_throttle(rate, number);
> > > 	/* here goes your operation */
> > > 	end_throttle();
> > > 
> > > one operation is not considered done until the whole section ends.
> > > Or something along those lines.
> > > 
> > > In this particular case we can increase the rate limit parameters of
> > > course but I think that longterm we need a better api.
> > 
> > The problem is when a system is under heavy memory pressure, everything is
> > becoming slower, so I don't know how to come up with a sane default for rate
> > limit parameters as a generic solution that would work for every machine out
> > there. Sure, it is possible to set a limit as low as possible that would
> > work
> > for the majority of systems apart from people may complain that they are now
> > missing important warnings, but using __GFP_NOWARN in this code would work
> > for
> > all systems. You could even argument there is even a separate benefit that
> > it
> > could reduce the noise-level overall from those build_skb() allocation
> > failures
> > as it has a fall-back mechanism anyway.
> 
> As Vlastimil already pointed out, __GFP_NOWARN would hide that reserves
> might be configured too low.

Tune "min_free_kbytes" is also an unreliable solution and situational as the
same reason mentioned previously. It may also need a lot of testing to find out
the right value of it on one particular system.

"
When there is a heavy memory pressure, the system is trying hard to reclaim
memory to fill up the watermark. However, the IO is slow to page out, but the
memory pressure keep draining atomic reservoir, and some of those skb_build()
will fail eventually.

Only if there is a fast IO, it will finish swapping sooner and then invoke the
OOM to end the memory pressure.
"

It also have a drawback that "waste" precious memory resources, as allocations
other than GPF_ATOMIC are unable to use those reserved memory anymore.

