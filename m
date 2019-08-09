Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CDE5FC433FF
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 22:14:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 94A74208C3
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 22:14:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 94A74208C3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fromorbit.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 14E036B0005; Fri,  9 Aug 2019 18:14:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0FF556B0006; Fri,  9 Aug 2019 18:14:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F2F2E6B0007; Fri,  9 Aug 2019 18:14:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id B8C636B0005
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 18:14:02 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id d6so58152204pls.17
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 15:14:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=xXAQi+C/0cFWu15a2YAoL7pawf7TDnZ80o+p3MerDFs=;
        b=Mn57WjPdmnzlh5aBQ1IpkNjpdn0Hxtddg/wYjydsCJ37qZ//+iLGEwSLaoeYF8ax6L
         8iGnN57UzdCBhRBMaRTT3OHDC1Lr5R5nao5rh4etmQpOzb8o+l+p9onbgbA/BiDeP0n2
         NYm+X8gDAEsp0NW9DzIURHinX+6/+sbiFXhvkeStpMD2QFoVMZOo6/iv7cR11hpbNj89
         uXtDDREn8hJreYLk69kbYNvPRRJHiFl8+ALXBYLxWBacI+YXpJrrqETLTQYB/u4LHfZr
         5cZ+bHwrl5tekhKl5mG47HNv9rA2BaMXMNaJfrvOoxyKLMCdWoaVXZv2tWM81EhztdX3
         jkJQ==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 211.29.132.249 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
X-Gm-Message-State: APjAAAUkwv2bb4SKGxVgCJaabxrQHcKNejhCgMxlshuf1tLcx2Tp2rcK
	c0mYxAhQ19P++KS17Xoi33qILV1eKd1Ofu2H68bFzBmGLNxFLnNqMRESe2icQKQtCJOrGKzEuCk
	8NiSqC5iCVJ4oEa/6WoGiZ93vfXXyCNHtI8DJcEQjIXytq50ABmKjlqde0GNNeiI=
X-Received: by 2002:a17:90a:ad86:: with SMTP id s6mr11755752pjq.42.1565388842387;
        Fri, 09 Aug 2019 15:14:02 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxIt4FYysHTBzOw36xD0dIwHEtwFmOSqjpct7p59q1xhYGZdMxa9/EdOn+pdd5vklWETlyC
X-Received: by 2002:a17:90a:ad86:: with SMTP id s6mr11755693pjq.42.1565388841532;
        Fri, 09 Aug 2019 15:14:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565388841; cv=none;
        d=google.com; s=arc-20160816;
        b=XtTMEe0IQrMcmxX8AZVtGJ3NbVS5YF5gPo/khNkQBC2K8hk7QrwnwRDhRob8JZPm7P
         ArpfZ1nmIyUgig/VY8AD3/yxdNySBtHqqVLgCL9RRQQqr2yMh/mB3gHKL0a9vxeIuGub
         FamkW3wCcVtdWiMrHlfydeuhzwBvUMZHKb/A+NivlC7anAA0cDPFxWQaEzJsSG4Otbfp
         AFlCU2hHw02TNFQrIQm4WTCyd5l2meqIqDTPIGQ2I9/IRq+UvNSnwXihzIPVFuXCeu1S
         DIvvcgc/bUVpNWB/5Upq8kdVcJegZE/h+WLQA/8sF2q+gfX3ePj6M6mqsP3/+Nx+nrU0
         ASvQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=xXAQi+C/0cFWu15a2YAoL7pawf7TDnZ80o+p3MerDFs=;
        b=jurTRTUc1O6i7PYwLtgHIVoJ6KvNVE5L4rdLj4Kw64QvJEjhK+NcynHNtD/lgJ98KK
         cRwRia+/vegJ9w4mW4CvJZjHGFhaPcdLuBvCGuP6ckRbHlNLENvrh9gjE71eQiH7jlhI
         WzdoJyJ/RxW8hvqajY7I1tgnhzwYKVezAvS2ba9sUh5y8HQzJIVM/Nrtfb9AsrV+9AIy
         209lh/e+oVl6e+KImsbEn8nYtckxyAcMQiCDap3GJvNo24q8LmjP/2dQDK3mrqM7b68O
         ln5DettijU1l5TPar3g1S+yJ1NIDeG6dNorrSeWP8cz5syAV329X/yBuJV0m8Bgoxr94
         XJMQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 211.29.132.249 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from mail105.syd.optusnet.com.au (mail105.syd.optusnet.com.au. [211.29.132.249])
        by mx.google.com with ESMTP id s7si53662898plp.66.2019.08.09.15.14.01
        for <linux-mm@kvack.org>;
        Fri, 09 Aug 2019 15:14:01 -0700 (PDT)
Received-SPF: neutral (google.com: 211.29.132.249 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) client-ip=211.29.132.249;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 211.29.132.249 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from dread.disaster.area (pa49-181-167-148.pa.nsw.optusnet.com.au [49.181.167.148])
	by mail105.syd.optusnet.com.au (Postfix) with ESMTPS id 6AD0036420D;
	Sat, 10 Aug 2019 08:13:56 +1000 (AEST)
Received: from dave by dread.disaster.area with local (Exim 4.92)
	(envelope-from <david@fromorbit.com>)
	id 1hwD7w-000108-Ua; Sat, 10 Aug 2019 08:12:48 +1000
Date: Sat, 10 Aug 2019 08:12:48 +1000
From: Dave Chinner <david@fromorbit.com>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Jens Axboe <axboe@kernel.dk>, Andrew Morton <akpm@linux-foundation.org>,
	linux-mm@kvack.org, linux-btrfs@vger.kernel.org,
	linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	linux-block@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH RESEND] block: annotate refault stalls from IO submission
Message-ID: <20190809221248.GK7689@dread.disaster.area>
References: <20190808190300.GA9067@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190808190300.GA9067@cmpxchg.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Optus-CM-Score: 0
X-Optus-CM-Analysis: v=2.2 cv=P6RKvmIu c=1 sm=1 tr=0
	a=gu9DDhuZhshYSb5Zs/lkOA==:117 a=gu9DDhuZhshYSb5Zs/lkOA==:17
	a=jpOVt7BSZ2e4Z31A5e1TngXxSK0=:19 a=kj9zAlcOel0A:10 a=FmdZ9Uzk2mMA:10
	a=7-415B0cAAAA:8 a=tU5beferOtS2JaHV9NYA:9 a=CjuIK1q_8ugA:10
	a=biEYGPWJfzWAr4FL6Ov7:22
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 08, 2019 at 03:03:00PM -0400, Johannes Weiner wrote:
> psi tracks the time tasks wait for refaulting pages to become
> uptodate, but it does not track the time spent submitting the IO. The
> submission part can be significant if backing storage is contended or
> when cgroup throttling (io.latency) is in effect - a lot of time is

Or the wbt is throttling.

> spent in submit_bio(). In that case, we underreport memory pressure.
> 
> Annotate submit_bio() to account submission time as memory stall when
> the bio is reading userspace workingset pages.

PAtch looks fine to me, but it raises another question w.r.t. IO
stalls and reclaim pressure feedback to the vm: how do we make use
of the pressure stall infrastructure to track inode cache pressure
and stalls?

With the congestion_wait() and wait_iff_congested() being entire
non-functional for block devices since 5.0, there is no IO load
based feedback going into memory reclaim from shrinkers that might
require IO to free objects before they can be reclaimed. This is
directly analogous to page reclaim writing back dirty pages from
the LRU, and as I understand it one of things the PSI is supposed
to be tracking.

Lots of workloads create inode cache pressure and often it can
dominate the time spent in memory reclaim, so it would seem to me
that having PSI only track/calculate pressure and stalls from LRU
pages misses a fair chunk of the memory pressure and reclaim stalls
that can be occurring.

Any thoughts of how we might be able to integrate more of the system
caches into the PSI infrastructure, Johannes?

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

