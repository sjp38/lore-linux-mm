Return-Path: <SRS0=ftCo=XA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6B4DFC3A5A5
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 08:32:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 04CD020870
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 08:32:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="VQMAQB/p"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 04CD020870
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4DB696B026F; Thu,  5 Sep 2019 04:32:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 48D276B0270; Thu,  5 Sep 2019 04:32:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3A23F6B0271; Thu,  5 Sep 2019 04:32:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0128.hostedemail.com [216.40.44.128])
	by kanga.kvack.org (Postfix) with ESMTP id 13C996B026F
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 04:32:15 -0400 (EDT)
Received: from smtpin23.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id ABCA6824CA39
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 08:32:14 +0000 (UTC)
X-FDA: 75900199788.23.stone50_30a5b34953e46
X-HE-Tag: stone50_30a5b34953e46
X-Filterd-Recvd-Size: 5179
Received: from mail-wr1-f68.google.com (mail-wr1-f68.google.com [209.85.221.68])
	by imf37.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 08:32:14 +0000 (UTC)
Received: by mail-wr1-f68.google.com with SMTP id l16so1611300wrv.12
        for <linux-mm@kvack.org>; Thu, 05 Sep 2019 01:32:14 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=subject:to:cc:references:from:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=gj2R3r9NNYbhdgbLaHqDj//ho1s/xwwXxZcAR2ovCss=;
        b=VQMAQB/pJH8KCeBzd0DPGyKZzigzXkSt0nKUUsbn5uhglssFidXE1D8uc3p/A+xlQA
         YlcJiGu6FkxEPqRAgGs8bH4mprOxSq9FwCTVoUtpuMsx+KSTisZbaeyFRRE35bA9ClLg
         LATSH9OQtt3/JOFw1VoIHtzzbQIlnxJEcq4qHCVw70EaBaJjhF5t+i0s/+o6CaTbsIE0
         WOuyJsZrYFmPxoiezZFBRZJGK274Ub4zaFSiIXrsm8i8MmuKSPGJ12QZDxJr2SRE33jS
         QOelFgrUcOlfyqGS18sj5sl/fvOGp6NtNlpSg7T9+OrjjC1fO0ZjN0bu2H8m7qIGuyBH
         Xesw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=gj2R3r9NNYbhdgbLaHqDj//ho1s/xwwXxZcAR2ovCss=;
        b=ko0ZQ2f0m8PUMfOhusklNXzHbarPUvUPxCFIclmpHMh/ytqBPMft0RtAAmITrHv+SE
         9nUGDnkRGcJ1EvfV6Pe33SzxondiQR0ZrWLhy7E+oM/5mPz3xGJBaLAnRAcVdZmkDDPO
         Vdb4Eh+jGzRExM+XjrDYwSLnQC+gWSmwufLxR52hdvr7lLaVMrUAbk1DHct0GoL4ag60
         DitJGyDjjzNwSlA3yvSvi3IbwB42F7JmEHqH5IYX8nGu5c7F+uy4FbuCZt3VQS1oHeph
         bXL2PZY+ivkae9HDVOoHrJKMC34QjRSGYtp6QTvn8RXeb2A+ugRiQRumXperNFpA8LI5
         Pq2w==
X-Gm-Message-State: APjAAAUFUAHsHbDg7+efY7/mrX+d0GOHzEZW3N0LVp6JvQWnHHM7ncn6
	H1gdwLfVIq5bzc4RbL17n4Y=
X-Google-Smtp-Source: APXvYqykNnBQp+iBilSuDo0K9RJD9YgUJBErhXCd11xD/5ghRbmyt+hDLpVibs2nWtu76Weaarx/xw==
X-Received: by 2002:adf:8527:: with SMTP id 36mr1602341wrh.206.1567672333034;
        Thu, 05 Sep 2019 01:32:13 -0700 (PDT)
Received: from [192.168.8.147] (238.165.185.81.rev.sfr.net. [81.185.165.238])
        by smtp.gmail.com with ESMTPSA id y3sm7468107wmg.2.2019.09.05.01.32.11
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Thu, 05 Sep 2019 01:32:12 -0700 (PDT)
Subject: Re: [PATCH] net/skbuff: silence warnings under memory pressure
To: Qian Cai <cai@lca.pw>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>,
 Michal Hocko <mhocko@kernel.org>, Eric Dumazet <eric.dumazet@gmail.com>,
 davem@davemloft.net, netdev@vger.kernel.org, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org, Petr Mladek <pmladek@suse.com>,
 Steven Rostedt <rostedt@goodmis.org>
References: <20190903132231.GC18939@dhcp22.suse.cz>
 <1567525342.5576.60.camel@lca.pw> <20190903185305.GA14028@dhcp22.suse.cz>
 <1567546948.5576.68.camel@lca.pw> <20190904061501.GB3838@dhcp22.suse.cz>
 <20190904064144.GA5487@jagdpanzerIV> <20190904065455.GE3838@dhcp22.suse.cz>
 <20190904071911.GB11968@jagdpanzerIV> <20190904074312.GA25744@jagdpanzerIV>
 <1567599263.5576.72.camel@lca.pw> <20190904144850.GA8296@tigerII.localdomain>
 <1567629737.5576.87.camel@lca.pw>
From: Eric Dumazet <eric.dumazet@gmail.com>
Message-ID: <165827b5-6783-f4f8-69d6-b088dd97eb45@gmail.com>
Date: Thu, 5 Sep 2019 10:32:10 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <1567629737.5576.87.camel@lca.pw>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000002, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 9/4/19 10:42 PM, Qian Cai wrote:

> To summary, those look to me are all good long-term improvement that would
> reduce the likelihood of this kind of livelock in general especially for other
> unknown allocations that happen while processing softirqs, but it is still up to
> the air if it fixes it 100% in all situations as printk() is going to take more
> time and could deal with console hardware that involve irq_exit() anyway.
> 
> On the other hand, adding __GPF_NOWARN in the build_skb() allocation will fix
> this known NET_TX_SOFTIRQ case which is common when softirqd involved at least
> in short-term. It even have a benefit to reduce the overall warn_alloc() noise
> out there.
> 
> I can resubmit with an update changelog. Does it make any sense?

It does not make sense.

We have thousands other GFP_ATOMIC allocations in the networking stacks.

Soon you will have to send more and more patches adding __GFP_NOWARN once
your workloads/tests can hit all these various points.

It is really time to fix this problem generically, instead of having
to review hundreds of patches.

This was my initial feedback really, nothing really has changed since.

The ability to send a warning with a stack trace, holding the cpu
for many milliseconds should not be decided case by case, otherwise
every call points will decide to opt-out from the harmful warnings.

