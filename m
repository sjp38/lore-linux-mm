Return-Path: <SRS0=SdaL=XB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 45F55C00307
	for <linux-mm@archiver.kernel.org>; Fri,  6 Sep 2019 19:51:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E1ACB20838
	for <linux-mm@archiver.kernel.org>; Fri,  6 Sep 2019 19:51:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="dPHHuipO"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E1ACB20838
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 44C716B0005; Fri,  6 Sep 2019 15:51:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3FCD96B0006; Fri,  6 Sep 2019 15:51:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2EA5E6B0007; Fri,  6 Sep 2019 15:51:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0120.hostedemail.com [216.40.44.120])
	by kanga.kvack.org (Postfix) with ESMTP id 0778F6B0005
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 15:51:41 -0400 (EDT)
Received: from smtpin19.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 8E603181AC9B4
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 19:51:41 +0000 (UTC)
X-FDA: 75905540802.19.net33_48eb1e9608d32
X-HE-Tag: net33_48eb1e9608d32
X-Filterd-Recvd-Size: 4751
Received: from mail-pf1-f193.google.com (mail-pf1-f193.google.com [209.85.210.193])
	by imf43.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 19:51:40 +0000 (UTC)
Received: by mail-pf1-f193.google.com with SMTP id q5so5205174pfg.13
        for <linux-mm@kvack.org>; Fri, 06 Sep 2019 12:51:40 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:date:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=eGYgkRZj0NcCUP7h3iCHHFaAC43wNkWYu1G5sWIpzZk=;
        b=dPHHuipONUA43OXAQtslB0Nstvm9jMsRi2Xwq5hH50w+aW+QvRYutnw/fm+ZG7i0Uh
         DN6bxh04bPtnh8H+Jckkkjt4tqsrPRncv8LEM/2gGHj3+qgg1UfQcoX+NCedbCemX2hf
         4pPzfsgB+v74/bibFiX73cVqf4tuH5FLNbguQx/Q9kKkjKrICJwZQoTaocu/szf93MIG
         2lt4YqC8QUHBNGVldvYf3HiwJK+S5FJD4dDZozPpjAoh3EhBHkaSGy5yErN0Yiy3xoV4
         fL9Lae/0xrXM1b2WJpTV85MiqBJnBZVNqs+EIjH4ORfj2WDZz5fD77nv4S9gbuWKmMtq
         4tXg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:date:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to:user-agent;
        bh=eGYgkRZj0NcCUP7h3iCHHFaAC43wNkWYu1G5sWIpzZk=;
        b=JsZWNEG3DdUUA2nxXJrXwMglDvHtT7fz8nulpgdF3lQa3IJaeIcwP23embJWPr4LJp
         sDg0PJfA6c09mjXvQcrbHHcf73axkYvEQDDqlaA/0AZNgFuEaI39xIN1YbDeQVBQYSFd
         v+kEJ633JG6MrBNQIlY5tGwt1bxOCCZ8cwgro1Hiypv8QF52xFJd1xfC2lpCdmGVOBNC
         e5qeuNCEVLRqAvu5l7fYhKR0lpAxvoEORAJb6fjOL4r0RHXwfMN48vGkjpAF8c8VGk20
         W9wZLZ4Q+ZsbOFRJen2EXmTeCAW/LpryzjMfTjqmObgyECOz5a5/wwRiDluNRu0IA0pG
         y2uQ==
X-Gm-Message-State: APjAAAXLaN/8QZbq1FRpDun8kuWo/1WpHakniKtB/Uj7rW2IiSZ/cgBc
	Dq9ICn9wa6MVpv7QaY40m78=
X-Google-Smtp-Source: APXvYqxeaSSe8RWvGTP+Hhm0gpdZ9DLJYGvzAcdEP1AdGCDSVlIYbrpuZpy0V2v4ywX7STgoWPxd+A==
X-Received: by 2002:a63:30c6:: with SMTP id w189mr9157795pgw.398.1567799499643;
        Fri, 06 Sep 2019 12:51:39 -0700 (PDT)
Received: from localhost ([121.137.63.184])
        by smtp.gmail.com with ESMTPSA id q4sm7413899pfh.115.2019.09.06.12.51.38
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 06 Sep 2019 12:51:38 -0700 (PDT)
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
X-Google-Original-From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Date: Sat, 7 Sep 2019 04:51:35 +0900
To: Petr Mladek <pmladek@suse.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>,
	Steven Rostedt <rostedt@goodmis.org>, Qian Cai <cai@lca.pw>,
	davem@davemloft.net, Eric Dumazet <eric.dumazet@gmail.com>,
	Sergey Senozhatsky <sergey.senozhatsky@gmail.com>,
	Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Subject: Re: [PATCH] net/skbuff: silence warnings under memory pressure
Message-ID: <20190906195135.GA69785@tigerII.localdomain>
References: <20190904061501.GB3838@dhcp22.suse.cz>
 <20190904064144.GA5487@jagdpanzerIV>
 <20190904065455.GE3838@dhcp22.suse.cz>
 <20190904071911.GB11968@jagdpanzerIV>
 <20190904074312.GA25744@jagdpanzerIV>
 <1567599263.5576.72.camel@lca.pw>
 <20190904144850.GA8296@tigerII.localdomain>
 <1567629737.5576.87.camel@lca.pw>
 <20190905113208.GA521@jagdpanzerIV>
 <20190906145533.4uw43a5pvsawmdov@pathway.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190906145533.4uw43a5pvsawmdov@pathway.suse.cz>
User-Agent: Mutt/1.12.1 (2019-06-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000002, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On (09/06/19 16:55), Petr Mladek wrote:
> > I think we can queue significantly much less irq_work-s from printk().
> > 
> > Petr, Steven, what do you think?
> > 
> > Something like this. Call wake_up_interruptible(), switch to
> > wake_up_klogd() only when called from sched code.
> 
> Replacing irq_work_queue() with wake_up_interruptible() looks
> dangerous to me.
> 
> As a result, all "normal" printk() calls from the scheduler
> code will deadlock. There is almost always a userspace
> logger registered.

I don't see why all printk()-s should deadlock.

A "normal" printk() call will deadlock only when scheduler calls
"normal" printk() under rq or pi locks. But this is illegal anyway,
because console_sem up() calls wake_up_process() - the same function
wake_up_interruptible() calls. IOW "normal" printk() calls from
scheduler end up in scheduler, via console_sem->sched chain. We
already execute wake_up_process()->try_to_wake_up() in printk(),
even when a non-LOGLEVEL_SCHED printk() comes from scheduler.

What am I missing something?

	-ss

