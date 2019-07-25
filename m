Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A6721C7618B
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 14:53:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 50ED221734
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 14:53:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chrisdown.name header.i=@chrisdown.name header.b="OEpCHpjy"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 50ED221734
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chrisdown.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BB5F96B0003; Thu, 25 Jul 2019 10:53:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B66376B0005; Thu, 25 Jul 2019 10:53:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A556B8E0002; Thu, 25 Jul 2019 10:53:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 824C46B0003
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 10:53:57 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id n190so42617951qkd.5
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 07:53:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=rpQsWh8tKFiB0DisghLGOONFMKT1wn+vfgfBbAUOPSQ=;
        b=PoxtELoYWtBKxudk/6Btgs+BGk1wN5IvhFAGCdgOt89fe0rwzG9xNNxXaxl29hUw6n
         PJP5vLCOV4XvLGqXZirLcn0tCoCTgawla+cZDfxE6BjiEVDEd0t7rPDV3UqDXKVYelWw
         oXlTMVsQrhSwXbG7xKomFTag861Sb6w3JckvyyA/Ug3Zoi7sSEjdyUYcXyXWgHFsh7kN
         UWKBGR0neQoxfqUG3oTIlJRcUAAeps7BSRd/xN0iHypa/dlqqlhPlbcE7UmqfDqasKbI
         8zOr8cM8jWQ4k5g/2FF2U4ELaKfy2cIVVeIr6m1ceZNwl28FktBer1Q+m+RfO4Kp9AOJ
         FZ0g==
X-Gm-Message-State: APjAAAWWTruJCPAS2uz3BHPtXtIBxqOHvTl2wmHh27AJmpKOmZh9flEs
	zBCrnprw1jw1Ko+YiYKZQrFXN3uYOegIk72DYgozzvVYQdp2rN5jEFxm38eDyUvw47aGXY30hsL
	8fdSp/5VxKhdMdx1JfpJK3uI8Kgu9P1KsOQb+6GMhRTebBc0F2mytKFysInr0ZXJ9TA==
X-Received: by 2002:ac8:376e:: with SMTP id p43mr62789718qtb.354.1564066437277;
        Thu, 25 Jul 2019 07:53:57 -0700 (PDT)
X-Received: by 2002:ac8:376e:: with SMTP id p43mr62789681qtb.354.1564066436748;
        Thu, 25 Jul 2019 07:53:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564066436; cv=none;
        d=google.com; s=arc-20160816;
        b=hVEmyPgl52xvK1aGg1hFPlFXnyqIamHDJO8BKSQ2uiwc77KgrKNYUTwFmAXGFQyASA
         s7d5tW2IKBxfd7ME5H9IJ30rKwRXw1tpOJUmhOCs1ncR276HQQnMlKCGo4pcL7vXXGP9
         RmPm46Vc9cgc8xsyFsrrCt/GO2/1lIri2B3LBSVP6W1NgZl+M6psHYIMw30z9Bt3DSw2
         pkcn7NV1lgq+QcEUkDBPREvgKt2OKgAaeeQqCwGvLjrHy8YQssDi845NeQqo/X7Y18dr
         ya5D5jgPzUN2jYs7Jgt7clCLkZgimeF5YDSmpp6EBE3A4Gw0WhPmgm32fiwz0ykly9OQ
         J90Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=rpQsWh8tKFiB0DisghLGOONFMKT1wn+vfgfBbAUOPSQ=;
        b=xZXUiYJSWoGe6AXj4y+2B+6L6OPOLMTkJn9yOJG7/X80AJVLkuuxmsH0Q4mDRc9gra
         nMJKupKkOdONN8SOexA8KeRFeVCMCOzbD1DYZH9RSnGPJzBcqoS+UwmvCdjy9ggoxS5H
         wte3uAtN4kOMTKNi66zIz06Z9RCcA8EiPhn6DLSqrwuTOxKlIc7INq17/alIYO/v0Vv+
         yOu024Vm3nUT4YfAyCXck24omaGjFapnryuK6YS/NF7SI6wK93EDjOYkpG1DmWhxvzyP
         eoIM/Xxwygxr8CIZ0+H/uGQd/1lmx3LO3Uw+RylqvtzoDWiFVQQ2oJeq2hIgZ6IvN33R
         xTJw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chrisdown.name header.s=google header.b=OEpCHpjy;
       spf=pass (google.com: domain of chris@chrisdown.name designates 209.85.220.65 as permitted sender) smtp.mailfrom=chris@chrisdown.name;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chrisdown.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b26sor64940887qtp.58.2019.07.25.07.53.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 25 Jul 2019 07:53:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of chris@chrisdown.name designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chrisdown.name header.s=google header.b=OEpCHpjy;
       spf=pass (google.com: domain of chris@chrisdown.name designates 209.85.220.65 as permitted sender) smtp.mailfrom=chris@chrisdown.name;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chrisdown.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chrisdown.name; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=rpQsWh8tKFiB0DisghLGOONFMKT1wn+vfgfBbAUOPSQ=;
        b=OEpCHpjy+7Mo84hrchMB/6zcHf71ju+A1I4m29ZHJK6VuYG6orfa3YhpmrReIYgGzX
         u5gs0kZveSgwO3shzXd5HocMNEETXZpxDQh8kqAo22eHJvyvOSE+UapcuwoDV3f51dne
         bwohgQ0eeH4JV5ccxn8rysL2tTriLczaCioPE=
X-Google-Smtp-Source: APXvYqwe4cQgpMJVUKQnSVY0whP34x+pDj462jqi9VovQ4DrUT1xMj2tqY2ZAtDTxO7BBE70mMKlXg==
X-Received: by 2002:ac8:1c42:: with SMTP id j2mr62197636qtk.68.1564066436199;
        Thu, 25 Jul 2019 07:53:56 -0700 (PDT)
Received: from localhost (rrcs-24-103-44-77.nyc.biz.rr.com. [24.103.44.77])
        by smtp.gmail.com with ESMTPSA id a6sm22200235qkd.135.2019.07.25.07.53.55
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 25 Jul 2019 07:53:55 -0700 (PDT)
Date: Thu, 25 Jul 2019 10:53:55 -0400
From: Chris Down <chris@chrisdown.name>
To: Stefan Priebe - Profihost AG <s.priebe@profihost.ag>
Cc: cgroups@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>,
	Michal Hocko <mhocko@kernel.org>,
	Johannes Weiner <hannes@cmpxchg.org>,
	"n.fahldieck@profihost.ag" <n.fahldieck@profihost.ag>,
	Daniel Aberger - Profihost AG <d.aberger@profihost.ag>,
	p.kramme@profihost.ag
Subject: Re: No memory reclaim while reaching MemoryHigh
Message-ID: <20190725145355.GA7347@chrisdown.name>
References: <496dd106-abdd-3fca-06ad-ff7abaf41475@profihost.ag>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <496dd106-abdd-3fca-06ad-ff7abaf41475@profihost.ag>
User-Agent: Mutt/1.12.1 (2019-06-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Stefan,

Stefan Priebe - Profihost AG writes:
>While using kernel 4.19.55 and cgroupv2 i set a MemoryHigh value for a
>varnish service.
>
>It happens that the varnish.service cgroup reaches it's MemoryHigh value
>and stops working due to throttling.

In that kernel version, the only throttling we have is reclaim-based throttling 
(I also have a patch out to do schedule-based throttling, but it's not in 
mainline yet). If the application is slowing down, it likely means that we are 
struggling to reclaim pages.

>But i don't understand is that the process itself only consumes 40% of
>it's cgroup usage.
>
>So the other 60% is dirty dentries and inode cache. If i issue an
>echo 3 > /proc/sys/vm/drop_caches
>
>the varnish cgroup memory usage drops to the 50% of the pure process.

As a caching server, doesn't Varnish have a lot of hot inodes/dentries in 
memory? If they are hot, it's possible it's hard for us to evict them.

>I thought that the kernel would trigger automatic memory reclaim if a
>cgroup reaches is memory high value to drop caches.

It does, that's the throttling you're seeing :-) I think more information is 
needed to work out what's going on here. For example: what do your kswapd 
counters look like? What does "stops working due to throttling" mean -- are you 
stuck in reclaim?

Thanks,

Chris

