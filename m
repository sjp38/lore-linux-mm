Return-Path: <SRS0=ftCo=XA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_2 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AEBA4C43140
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 14:16:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B085A214DB
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 14:09:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="CGS+Y0/k"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B085A214DB
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 38FC86B027F; Thu,  5 Sep 2019 10:09:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3418B6B0282; Thu,  5 Sep 2019 10:09:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1E1836B0284; Thu,  5 Sep 2019 10:09:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0152.hostedemail.com [216.40.44.152])
	by kanga.kvack.org (Postfix) with ESMTP id F14606B027F
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 10:09:19 -0400 (EDT)
Received: from smtpin24.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 920D1824CA39
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 14:09:19 +0000 (UTC)
X-FDA: 75901049238.24.veil08_5152a12ff474b
X-HE-Tag: veil08_5152a12ff474b
X-Filterd-Recvd-Size: 5907
Received: from mail-qt1-f195.google.com (mail-qt1-f195.google.com [209.85.160.195])
	by imf32.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 14:09:18 +0000 (UTC)
Received: by mail-qt1-f195.google.com with SMTP id a13so2981492qtj.1
        for <linux-mm@kvack.org>; Thu, 05 Sep 2019 07:09:18 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=message-id:subject:from:to:cc:date:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=FFKCLx1ZTffOOXr+c5burImaG/QEO33EIYNJs82DHGc=;
        b=CGS+Y0/k65fgJjtFUA7ymuubqBxt1JxeEefetXkqu7/vRpmmtGHONutXFYSbTgrnjT
         3bEMI/a0HyARCdfX2w9Rr0OFORbj8lamMcbM8vqsUsGj3CzAXhRy3RzG3YMOGVne3loy
         yOfNsNjUIWrXHNHzzbspCfFtCe6U9j+Awzohwzifwgs8lHqzzqV8GfWvdSdhtrzPXENP
         NhRgDl3jfC5aKR5ai6Y7XH2iit1T35rt318wlewfYqJNHc4ffCxD3tictRIMrbqj6PU7
         jeuEdwWrlTQ/SvcF8yJH7VLm66geMBO71SfrU2htJLEGCBtjl25lzmXaYLlX7cRQo5k4
         md7A==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:message-id:subject:from:to:cc:date:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=FFKCLx1ZTffOOXr+c5burImaG/QEO33EIYNJs82DHGc=;
        b=nc3q7ehSMIrOu0ZWNpJxjlqJekFdDnspWra5PYjHxBR6m9g5/PnegcEejnJG0fJmMP
         VqQp1M5ZzypyMmwlaFhpR9KECrkI9708VpDjifg5Neia97HFRXp9WtelslAgdQXGwYuC
         E1wqvCULMkfgg5qSEWI5pSW9RmN8DMCKeA1M2UCS4pEoXtsWIJJhup7C5s7W2kMqi+hY
         xmFEBEnTnEI9rbGmj3zMS020gYgOiNIZCsSLGU3gRzgd5DtzPxMBnCOYMpWzRJsZb5py
         q0KQiUpB3x0lnZ3x1W0h12sUeuBu47D6m8yg6QWt1xe4zl0rR58r9uRCZ5nvkf9rtpW4
         NpIA==
X-Gm-Message-State: APjAAAW24b+X0wPpQXqgBe/g7+XUSzTFMJVqQVjy9kRps9JNpDhQjeRu
	b+Im2g2hhmG5phDQmwKax933IA==
X-Google-Smtp-Source: APXvYqxOjeu9YseRhHkNZQDe/DgQebxTQtNXWMqwhUN6xx7RCrpmhYL5puojh/TW0jeQaFAyOxtKtQ==
X-Received: by 2002:a0c:b251:: with SMTP id k17mr1826118qve.132.1567692558028;
        Thu, 05 Sep 2019 07:09:18 -0700 (PDT)
Received: from dhcp-41-57.bos.redhat.com (nat-pool-bos-t.redhat.com. [66.187.233.206])
        by smtp.gmail.com with ESMTPSA id q6sm956751qtr.23.2019.09.05.07.09.16
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Sep 2019 07:09:17 -0700 (PDT)
Message-ID: <1567692555.5576.91.camel@lca.pw>
Subject: Re: [PATCH] net/skbuff: silence warnings under memory pressure
From: Qian Cai <cai@lca.pw>
To: Eric Dumazet <eric.dumazet@gmail.com>, Sergey Senozhatsky
	 <sergey.senozhatsky@gmail.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Michal Hocko
 <mhocko@kernel.org>, davem@davemloft.net, netdev@vger.kernel.org, 
 linux-mm@kvack.org, linux-kernel@vger.kernel.org, Petr Mladek
 <pmladek@suse.com>,  Steven Rostedt <rostedt@goodmis.org>
Date: Thu, 05 Sep 2019 10:09:15 -0400
In-Reply-To: <165827b5-6783-f4f8-69d6-b088dd97eb45@gmail.com>
References: <20190903132231.GC18939@dhcp22.suse.cz>
	 <1567525342.5576.60.camel@lca.pw> <20190903185305.GA14028@dhcp22.suse.cz>
	 <1567546948.5576.68.camel@lca.pw> <20190904061501.GB3838@dhcp22.suse.cz>
	 <20190904064144.GA5487@jagdpanzerIV> <20190904065455.GE3838@dhcp22.suse.cz>
	 <20190904071911.GB11968@jagdpanzerIV> <20190904074312.GA25744@jagdpanzerIV>
	 <1567599263.5576.72.camel@lca.pw>
	 <20190904144850.GA8296@tigerII.localdomain>
	 <1567629737.5576.87.camel@lca.pw>
	 <165827b5-6783-f4f8-69d6-b088dd97eb45@gmail.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.22.6 (3.22.6-10.el7) 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 2019-09-05 at 10:32 +0200, Eric Dumazet wrote:
> 
> On 9/4/19 10:42 PM, Qian Cai wrote:
> 
> > To summary, those look to me are all good long-term improvement that would
> > reduce the likelihood of this kind of livelock in general especially for
> > other
> > unknown allocations that happen while processing softirqs, but it is still
> > up to
> > the air if it fixes it 100% in all situations as printk() is going to take
> > more
> > time and could deal with console hardware that involve irq_exit() anyway.
> > 
> > On the other hand, adding __GPF_NOWARN in the build_skb() allocation will
> > fix
> > this known NET_TX_SOFTIRQ case which is common when softirqd involved at
> > least
> > in short-term. It even have a benefit to reduce the overall warn_alloc()
> > noise
> > out there.
> > 
> > I can resubmit with an update changelog. Does it make any sense?
> 
> It does not make sense.
> 
> We have thousands other GFP_ATOMIC allocations in the networking stacks.

Instead of repeatedly make generalize statements, could you enlighten me with
some concrete examples that have the similar properties which would trigger a
livelock,

- guaranteed GFP_ATOMIC allocations when processing softirq batches.
- the allocation has a fallback mechanism that is unnecessary to warn a failure.

I thought "skb" is a special-case here as every packet sent or received is
handled using this data structure.

> 
> Soon you will have to send more and more patches adding __GFP_NOWARN once
> your workloads/tests can hit all these various points.

I doubt so.

> 
> It is really time to fix this problem generically, instead of having
> to review hundreds of patches.
> 
> This was my initial feedback really, nothing really has changed since.

I feel like you may not follow the thread closely. There are more details
uncovered in the last few days and narrowed down to the culprits.

> 
> The ability to send a warning with a stack trace, holding the cpu
> for many milliseconds should not be decided case by case, otherwise
> every call points will decide to opt-out from the harmful warnings.

That is not really the reasons anymore why I asked to add a __GPF_NOWARN here.

