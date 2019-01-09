Return-Path: <SRS0=IlG+=PR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8C47EC43612
	for <linux-mm@archiver.kernel.org>; Wed,  9 Jan 2019 10:09:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5277D21738
	for <linux-mm@archiver.kernel.org>; Wed,  9 Jan 2019 10:09:01 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5277D21738
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EA8C98E009F; Wed,  9 Jan 2019 05:09:00 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E57988E0038; Wed,  9 Jan 2019 05:09:00 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D6CCB8E009F; Wed,  9 Jan 2019 05:09:00 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7D8678E0038
	for <linux-mm@kvack.org>; Wed,  9 Jan 2019 05:09:00 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id t7so2732000edr.21
        for <linux-mm@kvack.org>; Wed, 09 Jan 2019 02:09:00 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:in-reply-to:message-id:references:user-agent
         :mime-version;
        bh=becW8LSxSgSTf/7rvTvE8x7OQV0VxXsSuGMisT955rE=;
        b=ma5XmR1AX4jnPlm9kfgamCTcvS9iu3PbI0czpr8aO87YwLb/njyRKOx8zWPTTDUgiI
         F/+PB9pZuFgHN3ZcgIT1Ps9tWKtJSax3IpuEWz8nHny6uskjH89HCET36YwtSoPrQjSb
         3X1wl1gQPSiFDt4ONym0CbuiR+VpZ/Yq61DSOr66fLTasLOCyIXRoTMhzoS0uQSrIL8K
         HI5np172yS26Yi6iGWBtaFwnretpr1xsZgtVCCA52ZEI0TiT0qs0K/CSQHR7uGa0wlJB
         WcifgwG7nb/+eCHUDzwTDPtK7LtNFZyGSzzEloA2sxbdx3kkE9MsAUMm7aceztTKK3VG
         NXgg==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning jikos@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=jikos@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AJcUukdes0O6R0wxWaHnHlN9YS9OG1v1LQN3oi7Wu0DnxwBaXEb0opFy
	73KO8sNNCGeKlstQ8VVuML5BVPTCya5a9VkCw5mUA1KO2H8MjfTuDZCckkeN/Du8M3DFsatWA7g
	oyAMSkffGZ/r6bGmfBxmrIHvfhQzwWj/xLMwSdccAdzBGeVPQnFBfLy316lujPXA=
X-Received: by 2002:a50:ef18:: with SMTP id m24mr5337406eds.136.1547028540054;
        Wed, 09 Jan 2019 02:09:00 -0800 (PST)
X-Google-Smtp-Source: ALg8bN7CtROSewxntINxx0dVemitbMAy/eDkT5Fn2jkOOXqU81Afll14CJMvq7x5kHN1U4Vhgliz
X-Received: by 2002:a50:ef18:: with SMTP id m24mr5337365eds.136.1547028539117;
        Wed, 09 Jan 2019 02:08:59 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547028539; cv=none;
        d=google.com; s=arc-20160816;
        b=Eg3drQkmPOgQpY8WN8iMgq5JEt5/rofKddlgmWj7vfkpixKpyrKSDSj7aDb3ZdtESE
         dqnRYmsL8L6BLMgKkWcO5vk4c06AuYC7Gy58WoBL2e6iuFjLQ6qRRheeBDD0HlgnI7Ff
         8YvLYX0RLK51Mugdc11z2eIz63gTMnEWGgtqwutSA3Fb0giQSqDv6o+KaYNjxdqxJfRU
         hVrh3NvMwn/XPxiKQ7v7NsVRVUkw7tt8HPELNLEgD3nC5qmYY4SKMSM1KJcvpqBuXAws
         L+jHjxPJcMoXS+KucTknfllCFLHA896hZXnQ/jRQjOlIeYsVImodaLZ2jPUHslTFPBBc
         5aOg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date;
        bh=becW8LSxSgSTf/7rvTvE8x7OQV0VxXsSuGMisT955rE=;
        b=VIneeZ5frmG21RAIml6b9MCsSEgqfuKdU2OAoBMhYpYrpG9qwjwYHWImMvPvtyokbd
         CKfW7gcGr1ZWEudiiREPlibnyCULmdgg5UcX8rznoEENiVJQ7UZrt4qODiAXhPWAnaiv
         kPMpPKNMX6NWiD6HfTwv/faZrM65IWgvEMSZTMN0ijpDWawKDub6FwerBffHpaSlk7ab
         W0snG7k7FqKOUPbPsjCBjyptt6HxbLjlaWkpZ+dv+q2jowTnT3sGhwUirHdjZGGeeVbW
         GdzDmotMePfjcDCvveJI8yCh+8NLGmEopyk+wfTz7Be9oPSHX6vYPb2+zmM9YqlbdwKA
         xjnA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning jikos@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=jikos@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b56si1218734eda.336.2019.01.09.02.08.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Jan 2019 02:08:59 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning jikos@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning jikos@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=jikos@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay1.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id A306CAEEB;
	Wed,  9 Jan 2019 10:08:58 +0000 (UTC)
Date: Wed, 9 Jan 2019 11:08:57 +0100 (CET)
From: Jiri Kosina <jikos@kernel.org>
To: Dave Chinner <david@fromorbit.com>
cc: Linus Torvalds <torvalds@linux-foundation.org>, 
    Matthew Wilcox <willy@infradead.org>, Jann Horn <jannh@google.com>, 
    Andrew Morton <akpm@linux-foundation.org>, 
    Greg KH <gregkh@linuxfoundation.org>, 
    Peter Zijlstra <peterz@infradead.org>, Michal Hocko <mhocko@suse.com>, 
    Linux-MM <linux-mm@kvack.org>, kernel list <linux-kernel@vger.kernel.org>, 
    Linux API <linux-api@vger.kernel.org>
Subject: Re: [PATCH] mm/mincore: allow for making sys_mincore() privileged
In-Reply-To: <20190109043906.GF27534@dastard>
Message-ID: <nycvar.YFH.7.76.1901091050560.16954@cbobk.fhfr.pm>
References: <CAHk-=wg5Kk+r36=jcGBaLUj+gjopjgiW5eyvkdMqvn0jFkD_iQ@mail.gmail.com> <CAHk-=wiMQeCEKESWTmm15x79NjEjNwFvjZ=9XenxY7yH8zqa7A@mail.gmail.com> <20190106001138.GW6310@bombadil.infradead.org> <CAHk-=wiT=ov+6zYcnw_64ihYf74Amzqs67iVGtJMQq65PxiVYw@mail.gmail.com>
 <CAHk-=wg1A44Roa8C4dmfdXLRLmNysEW36=3R7f+tzZzbcJ2d2g@mail.gmail.com> <CAHk-=wiqbKEC5jUXr3ax+oUuiRrp=QMv_ZnUfO-SPv=UNJ-OTw@mail.gmail.com> <20190108044336.GB27534@dastard> <CAHk-=wjvzEFQcTGJFh9cyV_MPQftNrjOLon8YMMxaX0G1TLqkg@mail.gmail.com>
 <20190109022430.GE27534@dastard> <nycvar.YFH.7.76.1901090326460.16954@cbobk.fhfr.pm> <20190109043906.GF27534@dastard>
User-Agent: Alpine 2.21 (LSU 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190109100857.rnmCkhisaX5auhlXVJHOzyXAlu1HziGGeZ-nXqTEB4E@z>

On Wed, 9 Jan 2019, Dave Chinner wrote:

> FWIW, I just realised that the easiest, most reliable way to invalidate 
> the page cache over a file range is simply to do a O_DIRECT read on it. 

Neat, good catch indeed. Still, it's only the invalidation part, but the 
residency check is the crucial one.

> > Rationale has been provided by Daniel Gruss in this thread -- if the 
> > attacker is left with cache timing as the only available vector, he's 
> > going to be much more successful with mounting hardware cache timing 
> > attack anyway.
> 
> No, he said:
> 
> "Restricting mincore() is sufficient to fix the hardware-agnostic
> part."
> 
> That's not correct - preadv2(RWF_NOWAIT) is also hardware agnostic and 
> provides exactly the same information about the page cache as mincore.  

Yeah, preadv2(RWF_NOWAIT) is in the same teritory as mincore(), it has 
"just" been overlooked. I can't speak for Daniel, but I believe he might 
be ok with rephrasing the above as "Restricting mincore() and RWF_NOWAIT 
is sufficient ...".

> Timed read/mmap access loops for cache observation are also hardware 
> agnostic, and on fast SSD based storage will only be marginally slower 
> bandwidth than preadv2(RWF_NOWAIT).
> 
> Attackers will pick whatever leak vector we don't fix, so we either fix 
> them all (which I think is probably impossible without removing caching 
> altogether) 

We can't really fix the fact that it's possible to do the timing on the HW 
caches though.

> or we start thinking about how we need to isolate the page cache so that 
> information isn't shared across important security boundaries (e.g. page 
> cache contents are per-mount namespace).

Umm, sorry for being dense, but how would that help that particular attack 
scenario on a system that doesn't really employ any namespacing? (which I 
still believe is a majority of the systems out there, but I might have 
just missed the containers train long time ago :) ).

-- 
Jiri Kosina
SUSE Labs

