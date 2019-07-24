Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DF273C7618B
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 08:07:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A9FC121873
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 08:07:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A9FC121873
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5ADC16B0003; Wed, 24 Jul 2019 04:07:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 55F6E6B0005; Wed, 24 Jul 2019 04:07:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 474CF6B0006; Wed, 24 Jul 2019 04:07:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 11B936B0003
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 04:07:29 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id o13so29728225edt.4
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 01:07:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=d5nGHwz1qmXETyeN4Nwd6NgsthuhYK/aPlV7ITNUtWw=;
        b=D1ZHtK0qqR5BSfxIfFXWvcSaotJZF6D7OGHRVAJAtwBs3si25ljqCIemlMGD1NjcLF
         ZSal/A/Dm1FUGxChpdEfUEKXpYgXNuRxm6RqACuWY3FnR45Nu5g4F7Pcl+EJoerH9NwP
         gZ5Cuf1vjOaSa4JGMIyqZ3Xuyx1eRX1TgcfvmfJWt6uY/yArkbw303HzvdTQQ1ci92kH
         h6eHaRcmmm4U76Iz9fg768yXIR0XAFtE2rrR3QY4TQ9q/1UaaeGw/QQ3JuRry3khtPkt
         uGKckr1e1C7cTIohMBCA0rW9zKrskJva6p8J3sIQAZSWo2+QnQVfvy2UBZm1RTgnd5af
         BirA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@suse.com
X-Gm-Message-State: APjAAAU1JuhChDrOEam626SPYudQTdYQ7ex2/7vUyu7VdVjf/av3AJ23
	SKGaLS5oBZ5P8M3yL7M5fP8Y0jnoJf1j+dRwC+ujvyLxAglgZdc7zyoe46fySY/C4TAm+l5VC7N
	vWN2FM35J5uO78UfpwaBnjY2fw/QwHjoMvtkGixDa1vLZGhD93O5umcFvkS56n+MqSA==
X-Received: by 2002:a17:906:b2cd:: with SMTP id cf13mr60893216ejb.197.1563955648661;
        Wed, 24 Jul 2019 01:07:28 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy3kQcBJDv516qeCkfZvGqISJIh0fvNXEdLnvn+9QsoSyzUK0v4Rklj+HrxBNPrgHaF/cOI
X-Received: by 2002:a17:906:b2cd:: with SMTP id cf13mr60893169ejb.197.1563955647980;
        Wed, 24 Jul 2019 01:07:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563955647; cv=none;
        d=google.com; s=arc-20160816;
        b=i9XMqsvN/kV9uBax5bXCsxclNZB5KRJTMaIC35G6gUCtPNSnnF8laG2yhSDCGjQcev
         o3GpUzWsxk0KqyzYD1/BUftVPvqKFilASCEaDp+nvDYE00ZuohnEZ3IotuDWapQbaW7Y
         VvNuAMWKybehbtKUcE9bQZY2Frqf/2WQ9qflCA7nzAKC8Qe8q41/bnoZOexi5teorNRp
         Ut5Bi38zXwwobFJCwxxy+R+wa6KmK7G5hpO+bX1touSS7Iu5T7dRArwLJw1nA8aQC1n+
         LdkqnKNr5kukUxip1L9fPSLsa8OBfCujQ/YXLcTZKvpcoawd7qA6g1HdA8bGKRwfJiZw
         wTgA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=d5nGHwz1qmXETyeN4Nwd6NgsthuhYK/aPlV7ITNUtWw=;
        b=JrC3B0ZBZsxZol2g54xT9yVu+r7O8lTSE4qrCAnONmYGaxQyXC2NuZmM1NUyHQ7CHP
         ZpcxcPnB8VSd50N8CTAQs63x+eQH7OKf1ZJ5VMYoZKpjIzASPd6CdF9/s8M4w01NkttG
         Pk0RcooESbRQkA0gSXsrBNiRUYvQ9M7Dr/REAU2GxCowAfCq6c5S0e1pIETcOPjxvldv
         QmgQSZoUnr3+9t8uGZW4p52E7Jv3ZxKtcjpBedTIp+GtLdI4HdBiwOwk+86vhzpAruCh
         3eyumtUVxqWcQNxs5uEiDDCyCCAHi3XwEGt37j6MJI0OvXjdzy1xYEZuT7eWX/xlL+JC
         kkKw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@suse.com
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e52si8253327ede.345.2019.07.24.01.07.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Jul 2019 01:07:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@suse.com
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 14DCEAD3E;
	Wed, 24 Jul 2019 08:07:27 +0000 (UTC)
Date: Wed, 24 Jul 2019 10:07:26 +0200
From: Michal Hocko <mhocko@suse.com>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Roman Gushchin <guro@fb.com>, David Rientjes <rientjes@google.com>,
	Shakeel Butt <shakeelb@google.com>, linux-mm@kvack.org,
	Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm, oom: simplify task's refcount handling
Message-ID: <20190724080726.GA5584@dhcp22.suse.cz>
References: <1563940476-6162-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20190724064110.GC10882@dhcp22.suse.cz>
 <d6aebef5-60f8-a61c-0564-5bb4595e8e2c@i-love.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <d6aebef5-60f8-a61c-0564-5bb4595e8e2c@i-love.sakura.ne.jp>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 24-07-19 16:37:35, Tetsuo Handa wrote:
> On 2019/07/24 15:41, Michal Hocko wrote:
[...]
> > That being said, I do not think this patch gives any improvement.
> > 
> 
> This patch avoids RCU during select_bad_process().

It just shifts where the RCU is taken. Do you have any numbers to show
that this is an improvement? Basically the only potentially expensive
thing down the oom_evaluate_task that I can see is the task_lock but I
am not aware of a single report that this would be a contributor for RCU
stalls. I can be proven wrong but 

> This patch allows
> possibility of doing reschedulable things there; e.g. directly reaping
> only a portion of OOM victim's memory rather than wasting CPU resource
> by spinning until MMF_OOM_SKIP is set by the OOM reaper.

We have been through direct oom reaping before and I haven't changed my
possition there. It is just too tricky to be worth it.
-- 
Michal Hocko
SUSE Labs

