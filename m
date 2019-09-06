Return-Path: <SRS0=SdaL=XB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0B0D2C43331
	for <linux-mm@archiver.kernel.org>; Fri,  6 Sep 2019 03:39:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E82BE206B8
	for <linux-mm@archiver.kernel.org>; Fri,  6 Sep 2019 03:39:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Q21vkhzu"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E82BE206B8
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 466F26B0003; Thu,  5 Sep 2019 23:39:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3F1386B0006; Thu,  5 Sep 2019 23:39:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2997D6B0007; Thu,  5 Sep 2019 23:39:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0152.hostedemail.com [216.40.44.152])
	by kanga.kvack.org (Postfix) with ESMTP id 016EF6B0003
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 23:39:06 -0400 (EDT)
Received: from smtpin27.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id A8C87824CA36
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 03:39:06 +0000 (UTC)
X-FDA: 75903089892.27.rat08_15484076e4452
X-HE-Tag: rat08_15484076e4452
X-Filterd-Recvd-Size: 4317
Received: from mail-pl1-f196.google.com (mail-pl1-f196.google.com [209.85.214.196])
	by imf32.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 03:39:06 +0000 (UTC)
Received: by mail-pl1-f196.google.com with SMTP id d3so2453087plr.1
        for <linux-mm@kvack.org>; Thu, 05 Sep 2019 20:39:06 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=PXYF1M03RrcZFiPVCr+oafxI5KwHAQlJ1LzSSGxpPe0=;
        b=Q21vkhzuAlNVXS4iv5SGd/V6DPV1QKXyuezlpF/KupK8aco7bH8L6xFRe+3rzjhuIi
         LAAgTEASWHEHYVoAj7FVyFx3Xp5PZbquc6w1OkYAtwZ31L53Gw7JXTOe8GkX29sSmyjV
         NqjvYJ/6KjMr5tH9UVt7rQsEBIztiZMRWNJ+YYvVx2fp9XRuNC/ZzQX2uySLo8ZgybfR
         GJGLOSv0jY6mSzp91+tHXpjAgj9SSldX+EL6SzTMQdjoT8/KD5f31faQ7+RyIc/SPXp6
         /32KsQdGPtu1HZwBEeCpce7NjL4p+ZDjPUPLNPaKFefZuIpcg1hxseD8csAyztj6AZPM
         R4+Q==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to:user-agent;
        bh=PXYF1M03RrcZFiPVCr+oafxI5KwHAQlJ1LzSSGxpPe0=;
        b=DjIIy/bBC2CPGbJBXeq4dm3meRxFJ2ByITZqp99m2iAGp0RcPpTEXKGumH6vewaSCy
         j5BBz3HDVIiBhJs3MTW8U/FXXe0IvWQ9gE2H0AyeAMzioHK3hNUl5iiVwyTLF5dLetfu
         qRNwPqeNhbIvOG6DaisXv/NhfpAl71D8LRXvcwPrNVZ+U2wcAFdHh5t4US/tF1rlGmkT
         z5PCQRXxZjRxOolSsTch+iC3YF9MXwEcI/P2buOGXw063aBlk8y2uTF1hm4Ywf7ice0j
         L9iDEeQ13ynWDeFgg8RorOBE2mycwScWUgPwziJP6Qc/Q9wiAyu5K/2iAlbrbLd4a/Qg
         wjeA==
X-Gm-Message-State: APjAAAVL12+9FovllcdVzco3MJwXVLgQ+cMa/5ah7ygP8K/n62XRZGWK
	rZPxlrOZ2cFhQ5zWYF7wUFU=
X-Google-Smtp-Source: APXvYqzgmhLuIsIaUW3PQSBJiLj2kLVGPu55mYjmZmnUcycRvpUbGvdC1nBjLxYMCIJYaHa9rSMSYA==
X-Received: by 2002:a17:902:4381:: with SMTP id j1mr6842157pld.318.1567741145109;
        Thu, 05 Sep 2019 20:39:05 -0700 (PDT)
Received: from localhost ([175.223.27.235])
        by smtp.gmail.com with ESMTPSA id i6sm9072040pfq.20.2019.09.05.20.39.03
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 05 Sep 2019 20:39:03 -0700 (PDT)
Date: Fri, 6 Sep 2019 12:39:00 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>,
	Qian Cai <cai@lca.pw>, Petr Mladek <pmladek@suse.com>,
	Sergey Senozhatsky <sergey.senozhatsky@gmail.com>,
	Michal Hocko <mhocko@kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>, davem@davemloft.net,
	netdev@vger.kernel.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH] net/skbuff: silence warnings under memory pressure
Message-ID: <20190906033900.GB1253@jagdpanzerIV>
References: <20190904061501.GB3838@dhcp22.suse.cz>
 <20190904064144.GA5487@jagdpanzerIV>
 <20190904065455.GE3838@dhcp22.suse.cz>
 <20190904071911.GB11968@jagdpanzerIV>
 <20190904074312.GA25744@jagdpanzerIV>
 <1567599263.5576.72.camel@lca.pw>
 <20190904144850.GA8296@tigerII.localdomain>
 <1567629737.5576.87.camel@lca.pw>
 <20190905113208.GA521@jagdpanzerIV>
 <20190905132334.52b13d95@oasis.local.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190905132334.52b13d95@oasis.local.home>
User-Agent: Mutt/1.12.1 (2019-06-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On (09/05/19 13:23), Steven Rostedt wrote:
> > I think we can queue significantly much less irq_work-s from printk().
> > 
> > Petr, Steven, what do you think?

[..]
> I mean, really, do we need to keep calling wake up if it
> probably never even executed?

I guess ratelimiting you are talking about ("if it probably never even
executed") would be to check if we have already called wake up on the
log_wait ->head. For that we need to, at least, take log_wait spin_lock
and check that ->head is still in TASK_INTERRUPTIBLE; which is (quite,
but not exactly) close to what wake_up_interruptible() does - it doesn't
wake up the same task twice, it bails out on `p->state & state' check.

Or did I miss something?

	-ss

