Return-Path: <SRS0=Igro=TR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8B01EC04AB4
	for <linux-mm@archiver.kernel.org>; Fri, 17 May 2019 19:04:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3CF912087B
	for <linux-mm@archiver.kernel.org>; Fri, 17 May 2019 19:04:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="J7bcW3dk"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3CF912087B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C9CED6B0003; Fri, 17 May 2019 15:04:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C4D326B0005; Fri, 17 May 2019 15:04:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B63C66B0006; Fri, 17 May 2019 15:04:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8136D6B0003
	for <linux-mm@kvack.org>; Fri, 17 May 2019 15:04:29 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id 94so4712788plc.19
        for <linux-mm@kvack.org>; Fri, 17 May 2019 12:04:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=xuh8AvfRHyKt8wFOgAYzPXD6mpnRhkLu6Cz7c9n98Ts=;
        b=U5QQtvt94lkpCyMbwZsX3Re+ylpt4N+8fmwQ+eYZSnjD++m7xdNmXPkRrIRsU5lfMn
         tyR8fWEod2Tgjd/n0xcnzmthsoyuIIUwSU3s39LVMs49ibk1n8Hg9VMWeEEpsqcwJauR
         kh9hLaLRCnPW59WAMclOFTfyuLTQIrMH6Yu9zPWf1X9ace3QhOqYdDh3xN9bqf/ixIDa
         jFmkinjeqnNa1dxYDxCWTkequUIGARH8WE6K9Lzqy/7w5pZPrnGsItKSMef37BHPc6LV
         xgEUVuC056mDQn+GFIzH6XknxPOTWbfIn0TUx8Z5bYMhiEAxbJqp+gYGuEuVCjGFDsPl
         Hm+Q==
X-Gm-Message-State: APjAAAXnkXyCj4+/8EZucueXwXqSXZA74/4GMl/+oFwX0+TlDFU/qo18
	vRR95dNWkgj+y3MsNm6t1PBncebiDrWYlqx2gwP+J+wQ+9NhAQcj7hNNjAKoMhHfIRQhX4/UfJ3
	/57ci84vgSWNxvM/MilHX/r5dARDG5RiqJcAG7+I2UVQJKKdKnybqCB20SJaEJCa1dg==
X-Received: by 2002:a63:f754:: with SMTP id f20mr58473293pgk.162.1558119869003;
        Fri, 17 May 2019 12:04:29 -0700 (PDT)
X-Received: by 2002:a63:f754:: with SMTP id f20mr58473131pgk.162.1558119867057;
        Fri, 17 May 2019 12:04:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558119867; cv=none;
        d=google.com; s=arc-20160816;
        b=dGvUDGNp8BOro79iSlxbTWBFmDHUbnLIV72LzvHRuAi0tVTLQUCRjHzUqXDA4iPsWS
         Uz914EPTuvT7WUBZLIzE2+MdEI1gpwoD+juTBnirHI1xJiBhJHy43OKS+goFr9UVZL8c
         4D17b8cOiBP4VKmOJXS9T34emUa15yZ3LXJpYkRfDZewHLNGmyGYxQrhFnzLM4E3s4p3
         w2QSRi6a0mzluPetXAQ5fHfpUnHIv122K5OIBv7tbVT1KmQ8DCAOhQ5KUJY6FUy2XT6G
         qikQi8I9GhgOmAUbcRLnLrWuH85GyyqJJYMcdysIL5GwlPltebTl8ub7f3CL3i+pkWBY
         n3TQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=xuh8AvfRHyKt8wFOgAYzPXD6mpnRhkLu6Cz7c9n98Ts=;
        b=RnjQ4f0bxVCvy+KWa7aBIlQhdNuzIIIk7t6LhraaJEiYmoGsSX9rQ6b7i+91IioRtb
         owfoWfTyTOJVayjle4+mGpcj5bFcc4KpHWe0ovSZb0AAOHx8dw7Bqb3EaWQWKkVeCfBe
         kMemS+QN2jGVy6FaAOL/cxITVgEFQ6R85NRqdE42H55NufE1qh0a+8I4w9ue+ENgFbQ2
         y0QIvYi+9g10nETLybJSgPPXQOfXHVOFTWR8rcaHDSKHjAslmJWBncw5NRp1y14BjHi5
         N+HtQfCDmjY6YIaatwtwwlk7CN23rUsVsHKG+cis3EmRdMKl2vxAnTp5VT5+cmItSbh8
         bULg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=J7bcW3dk;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.41 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id s24sor3653910pfh.12.2019.05.17.12.04.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 17 May 2019 12:04:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=J7bcW3dk;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.41 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=xuh8AvfRHyKt8wFOgAYzPXD6mpnRhkLu6Cz7c9n98Ts=;
        b=J7bcW3dketKiYlf25WPCh4PI8Mbjyiwq4wcw6yR4Vct1Rp3cZlrXethBayJBmPBzEv
         y0DIHHKj6vr07ubFFc+9FzOR1tXcxlcKik+PuLdkDQVhF4MDRYvVRb55+kJLilYmv2kd
         UwGXU71/StM7zN4RjrOUfjVx4luRcvWQblbtxVfXXuKcUM1BEzBtNY9TBchPaKEWMd20
         Vwh0s339HQRIxV+w4CuW+DUijAWDJc3B/XGx6EZgkNsvngKE1Ut3DwZXVTlhWeDWQ89h
         B/XEFLsE33iMXb5ZBxu99aMy7EA8u7TrG9estArZM7d6z77iMavGMq66F1weGtk9TfLj
         W5YQ==
X-Google-Smtp-Source: APXvYqyuIk+UkPjjkd1V+6w1s2mmy7Z9ea6q8FLScbdq74OswTvSQoEo52OQ8Nb0o4d/RevpxkuEMQ==
X-Received: by 2002:a62:ea0a:: with SMTP id t10mr62261738pfh.236.1558119864166;
        Fri, 17 May 2019 12:04:24 -0700 (PDT)
Received: from localhost ([2620:10d:c090:180::b0f6])
        by smtp.gmail.com with ESMTPSA id s134sm15617911pfc.110.2019.05.17.12.04.22
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 17 May 2019 12:04:23 -0700 (PDT)
Date: Fri, 17 May 2019 15:04:21 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Michal Hocko <mhocko@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	mm-commits@vger.kernel.org, Tejun Heo <tj@kernel.org>,
	Roman Gushchin <guro@fb.com>, Dennis Zhou <dennis@kernel.org>,
	Chris Down <chris@chrisdown.name>,
	cgroups mailinglist <cgroups@vger.kernel.org>,
	Linux MM <linux-mm@kvack.org>
Subject: Re: + mm-consider-subtrees-in-memoryevents.patch added to -mm tree
Message-ID: <20190517190421.GA6166@cmpxchg.org>
References: <20190212224542.ZW63a%akpm@linux-foundation.org>
 <20190213124729.GI4525@dhcp22.suse.cz>
 <CALvZod6c9OCy9p79hTgByjn+_BmnQ6p216kD9dgEhCSNFzpeKw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALvZod6c9OCy9p79hTgByjn+_BmnQ6p216kD9dgEhCSNFzpeKw@mail.gmail.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, May 17, 2019 at 06:00:11AM -0700, Shakeel Butt wrote:
> On Wed, Feb 13, 2019 at 4:47 AM Michal Hocko <mhocko@kernel.org> wrote:
> > > notifications.
> > >
> > > After this patch, events are propagated up the hierarchy:
> > >
> > >     [root@ktst ~]# cat /sys/fs/cgroup/system.slice/memory.events
> > >     low 0
> > >     high 0
> > >     max 0
> > >     oom 0
> > >     oom_kill 0
> > >     [root@ktst ~]# systemd-run -p MemoryMax=1 true
> > >     Running as unit: run-r251162a189fb4562b9dabfdc9b0422f5.service
> > >     [root@ktst ~]# cat /sys/fs/cgroup/system.slice/memory.events
> > >     low 0
> > >     high 0
> > >     max 7
> > >     oom 1
> > >     oom_kill 1
> > >
> > > As this is a change in behaviour, this can be reverted to the old
> > > behaviour by mounting with the `memory_localevents' flag set.  However, we
> > > use the new behaviour by default as there's a lack of evidence that there
> > > are any current users of memory.events that would find this change
> > > undesirable.
> > >
> > > Link: http://lkml.kernel.org/r/20190208224419.GA24772@chrisdown.name
> > > Signed-off-by: Chris Down <chris@chrisdown.name>
> > > Acked-by: Johannes Weiner <hannes@cmpxchg.org>
> 
> Reviewed-by: Shakeel Butt <shakeelb@google.com>

Thanks, Shakeel.

> However can we please have memory.events.local merged along with this one?

Could I ask you to send a patch for this? It's not really about the
code - that should be trivial. Rather it's about laying out the exact
usecase for that, which is harder for me/Chris/FB since we don't have
one. I imagine simliar arguments could be made for memory.stat.local,
memory.pressure.local etc. since they're also reporting events and
behavior manifesting in different levels of the cgroup subtree?

