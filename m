Return-Path: <SRS0=zrK/=W7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 04164C3A5A7
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 07:19:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BD6842339D
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 07:19:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="kAd/S4It"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BD6842339D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5035E6B0003; Wed,  4 Sep 2019 03:19:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4B32E6B0006; Wed,  4 Sep 2019 03:19:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3C9166B0007; Wed,  4 Sep 2019 03:19:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0215.hostedemail.com [216.40.44.215])
	by kanga.kvack.org (Postfix) with ESMTP id 1612C6B0003
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 03:19:18 -0400 (EDT)
Received: from smtpin12.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 76276181AC9B6
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 07:19:17 +0000 (UTC)
X-FDA: 75896387154.12.screw51_51104ae65f31b
X-HE-Tag: screw51_51104ae65f31b
X-Filterd-Recvd-Size: 4785
Received: from mail-pf1-f193.google.com (mail-pf1-f193.google.com [209.85.210.193])
	by imf43.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 07:19:16 +0000 (UTC)
Received: by mail-pf1-f193.google.com with SMTP id h195so6103239pfe.5
        for <linux-mm@kvack.org>; Wed, 04 Sep 2019 00:19:16 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=n1xJLcKf6G7UK7Awxu+0eoxUIpLlcPu/xrtHp78aqKs=;
        b=kAd/S4ItI9NfrNpl4fV3Iwmom3OvfqoEARr0paqvmqdlwOatMUrX35wBFrH+vd34o9
         82skrRaOLz+25PCNJzD0/wanlpygzPg4D94SOqVmK/bwNXKcBwMzLSFKW/Q7F+IqqNDb
         16E+YzXxzTGFrevpw+oPQmLAZM5kPNxfjwalJJYMA1qL8+8uW5KPSkiQ0V/HgF3o6Y6l
         W8uRNNygMdlbhE5G9awFudVHh6GGQNxcMNKbrcxGnP3n5b+PlGCKUyHA563NZ3p0gEnD
         z6vvHdrJ3GcWZb2eNVn6uzYfAr6rYxjuAAO5N9Fmpg0ZwxTcXakFTj40FpBFWyIgOodq
         N3Gw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to:user-agent;
        bh=n1xJLcKf6G7UK7Awxu+0eoxUIpLlcPu/xrtHp78aqKs=;
        b=HggtmVljOIDak07qkpF3TzQsBpRgu5xcZ6jfGwLq+V/74mPZdKCXpNBcZoWxq4ap3H
         P2p5DQoWseINtSAel4XXv1xxZdrs31IhJZ6/JyJ0PV+RpfZ8XI4M3DHP/AU330zu365j
         ezR/7/6wNmfDQx9aLuM+wXXdaMJMEycC8py+rEAC5ADTuqhDaSTbXOf4Xx9uLjtOWBiB
         /89DJ3zZo1SxvykcfwtA9OT7A0WHXFlgQhwwxwP2Iln1pnGGfBVU41g3LnTPkGQ8NZA0
         R49PQKVuYeZ1NYeDwpByEVcE1wt+2HZ4yvuZvrxVK2sQedQXdjTwNu1Nd6XCci1lGECY
         Qa4g==
X-Gm-Message-State: APjAAAV4OPxAvPrgMb9crpzYbHvlwG3hm6a1McyrjIxfZ3pIXc2DrcEd
	OjrnjbweOz1kVdlJ0jpik70=
X-Google-Smtp-Source: APXvYqzRaeXZEO+6LGaGeK4K4LMnx1yY/nhZrTQwTO0+RRnG1IFJHv+PBZ1wPsB7+32Gq0gbpGAb7Q==
X-Received: by 2002:a17:90a:8996:: with SMTP id v22mr3517563pjn.131.1567581555849;
        Wed, 04 Sep 2019 00:19:15 -0700 (PDT)
Received: from localhost ([175.223.23.37])
        by smtp.gmail.com with ESMTPSA id s5sm21619783pfm.97.2019.09.04.00.19.13
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 04 Sep 2019 00:19:14 -0700 (PDT)
Date: Wed, 4 Sep 2019 16:19:11 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
To: Michal Hocko <mhocko@kernel.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>,
	Qian Cai <cai@lca.pw>, Eric Dumazet <eric.dumazet@gmail.com>,
	davem@davemloft.net, netdev@vger.kernel.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, Petr Mladek <pmladek@suse.com>,
	Sergey Senozhatsky <sergey.senozhatsky@gmail.com>,
	Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH] net/skbuff: silence warnings under memory pressure
Message-ID: <20190904071911.GB11968@jagdpanzerIV>
References: <6109dab4-4061-8fee-96ac-320adf94e130@gmail.com>
 <1567178728.5576.32.camel@lca.pw>
 <229ebc3b-1c7e-474f-36f9-0fa603b889fb@gmail.com>
 <20190903132231.GC18939@dhcp22.suse.cz>
 <1567525342.5576.60.camel@lca.pw>
 <20190903185305.GA14028@dhcp22.suse.cz>
 <1567546948.5576.68.camel@lca.pw>
 <20190904061501.GB3838@dhcp22.suse.cz>
 <20190904064144.GA5487@jagdpanzerIV>
 <20190904065455.GE3838@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190904065455.GE3838@dhcp22.suse.cz>
User-Agent: Mutt/1.12.1 (2019-06-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.003763, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On (09/04/19 08:54), Michal Hocko wrote:
> I am sorry, I could have been more explicit when CCing you.

Oh, sorry! My bad!

> Sure the ratelimit is part of the problem. But I was more interested
> in the potential livelock (infinite loop) mentioned by Qian Cai. It
> is not important whether we generate one or more lines of output from
> the softirq context as long as the printk generates more irq processing
> which might end up doing the same. Is this really possible?

Hmm. I need to look at this more... wake_up_klogd() queues work only once
on particular CPU: irq_work_queue(this_cpu_ptr(&wake_up_klogd_work));

bool irq_work_queue()
{
	/* Only queue if not already pending */
	if (!irq_work_claim(work))
		return false;

	 __irq_work_queue_local(work);
}

softirqs are processed in batches, right? The softirq batch can add XXXX
lines to printk logbuf, but there will be only one PRINTK_PENDING_WAKEUP
queued. Qian Cai mentioned that "net_rx_action softirqs again which are
plenty due to connected via ssh etc." so the proportion still seems to be
N:1 - we process N softirqs, add 1 printk irq_work.

But need to think more.
Interesting question.

	-ss

