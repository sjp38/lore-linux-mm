Return-Path: <SRS0=eSYi=V6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9A8ACC19759
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 00:00:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 47FC42083B
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 00:00:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 47FC42083B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fromorbit.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E25CC6B0003; Thu,  1 Aug 2019 20:00:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DD5B56B0005; Thu,  1 Aug 2019 20:00:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CC5486B0006; Thu,  1 Aug 2019 20:00:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 95BF46B0003
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 20:00:01 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id i26so46786075pfo.22
        for <linux-mm@kvack.org>; Thu, 01 Aug 2019 17:00:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=GNXufCJL1OGZO1m0cohjpVqXPmZJ/1UkmRzstwugiXI=;
        b=GGvXux1/VASGikoJHtGNNPmvwkow3EXFqPO13j2fqQp2P3UJ0S5j87KeouEctJgQHA
         qz9zHN15bUsZnk5oaD0imFw4L7QCPbmyEyVn3WWxT3r47DtgMU5guJHLXFUqHVhtPtfN
         lok2qMamQdyRdPFLLtu0P53sQnszSHynaybI0rZVhbLlOsO5v+3EDUrQln1r++HfV5xU
         uccJUrVxdVFfyX1k5KUpuRL6TiMTujtR1ju6AvRorIpPiO+E+9hnKuCjkdMpudwoddvL
         9WqaPk1f/1T63d7YFR+rJ0LWiKBvMnj01fnPco7nXnVnAquOXQcBq7WSwiCsd8YEhYuf
         nZWg==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 211.29.132.249 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
X-Gm-Message-State: APjAAAW/4gRCrfE3m/MkcWblbYhm4L4bFjV9QDbpnxRtQgyF0mBYRoLS
	xGDaijKeBQdiR/6hOdS7RwUia1zAbT1y7R8ZzK9HmCR4fhxv1jz5N5SKWBW7iiG3k+Mv7m1V/0U
	5L2RjX0HW8BVcecIoM+pAPrzCEEO8Hk9+K1m9kx8s5iLh4bNNWCFmAhWgQVQTAEE=
X-Received: by 2002:a17:902:9897:: with SMTP id s23mr127537787plp.47.1564704001257;
        Thu, 01 Aug 2019 17:00:01 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyy/YupezZSPCmhn4xc1EZkIJ/hYNFdHXvpnyzRqr5zTTdZ6jbJccndE0fE1RujJgKy6/wd
X-Received: by 2002:a17:902:9897:: with SMTP id s23mr127537735plp.47.1564704000310;
        Thu, 01 Aug 2019 17:00:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564704000; cv=none;
        d=google.com; s=arc-20160816;
        b=h9Pwe3MHbaO3Q0urOVCmkpNGqtgJV1qoUHRZ7SHyfV2NB4XPa7ntjQS0l8RBv6yYUp
         tZOuMVKRoX00bsE44Bi3FPv2u/d28N1dGbdWxiqtk8JRvlKjZQAbjiRikqH3U+t0GLps
         jTrDGZTKUl6dUimMuJ6CvKiF4Zx6wJWlCVepwRgKvUp3mFZJ0q/GB6cHO4mEbmlsnt3P
         YaHZ/7oQ02unCE7Ap3DZtSWHlKV4uEaUtghbOcOeRVRIKKgXz4iwvF12DfVkabWs3OTl
         W5uYsXsSQduhVulANmH2nAf7QtUX89TzI1qt6gnUc/rblAFf08jXYXRRKDqgm+HWJkDT
         J4sA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=GNXufCJL1OGZO1m0cohjpVqXPmZJ/1UkmRzstwugiXI=;
        b=l/4faZsuxLetz4vdzNKPemO7K0C56dSB6Eh+qwfxWoJq2EMiUN1HqSa9w4gzahayMJ
         sgZxzwLsBiOCDIiZNBnNqhComyDhX9KpADFO6boT2fPkIm9LXglQfiiC2levjl3KyyOR
         Eogh+fyqkcygc74OHG4+0eQ2xd1PJGYWlBPurKfitAA283As9KZI+Fa3pq1dp07WLULD
         d6zD9XOuAkBWDt3pUWobouvpH/4EIQjqd6eYMdViW+bDmXmU+Kj+pm4z+PV82KXFlIxB
         MJjm1Z9lKKBUdKnW1WYzRCyyB9VRIN2AJ4thQm+HV2XCFQIiPIIUnwllfXm6FUdRAgcv
         t3dg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 211.29.132.249 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from mail105.syd.optusnet.com.au (mail105.syd.optusnet.com.au. [211.29.132.249])
        by mx.google.com with ESMTP id h31si13058424pgm.129.2019.08.01.16.59.59
        for <linux-mm@kvack.org>;
        Thu, 01 Aug 2019 17:00:00 -0700 (PDT)
Received-SPF: neutral (google.com: 211.29.132.249 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) client-ip=211.29.132.249;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 211.29.132.249 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from dread.disaster.area (pa49-181-167-148.pa.nsw.optusnet.com.au [49.181.167.148])
	by mail105.syd.optusnet.com.au (Postfix) with ESMTPS id 7201F363416;
	Fri,  2 Aug 2019 09:59:56 +1000 (AEST)
Received: from dave by dread.disaster.area with local (Exim 4.92)
	(envelope-from <david@fromorbit.com>)
	id 1htKy9-0003Va-4v; Fri, 02 Aug 2019 09:58:49 +1000
Date: Fri, 2 Aug 2019 09:58:49 +1000
From: Dave Chinner <david@fromorbit.com>
To: Chris Mason <clm@fb.com>
Cc: "linux-xfs@vger.kernel.org" <linux-xfs@vger.kernel.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
	Jens Axboe <axboe@kernel.dk>
Subject: Re: [PATCH 09/24] xfs: don't allow log IO to be throttled
Message-ID: <20190801235849.GO7777@dread.disaster.area>
References: <20190801021752.4986-1-david@fromorbit.com>
 <20190801021752.4986-10-david@fromorbit.com>
 <F1E7CC65-D2CB-4078-9AA3-9D172ECDE17B@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <F1E7CC65-D2CB-4078-9AA3-9D172ECDE17B@fb.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Optus-CM-Score: 0
X-Optus-CM-Analysis: v=2.2 cv=P6RKvmIu c=1 sm=1 tr=0 cx=a_idp_d
	a=gu9DDhuZhshYSb5Zs/lkOA==:117 a=gu9DDhuZhshYSb5Zs/lkOA==:17
	a=jpOVt7BSZ2e4Z31A5e1TngXxSK0=:19 a=kj9zAlcOel0A:10 a=FmdZ9Uzk2mMA:10
	a=20KFwNOVAAAA:8 a=7-415B0cAAAA:8 a=j1scD-lSN6Y4ri9hJcUA:9
	a=CjuIK1q_8ugA:10 a=biEYGPWJfzWAr4FL6Ov7:22
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 01, 2019 at 01:39:34PM +0000, Chris Mason wrote:
> On 31 Jul 2019, at 22:17, Dave Chinner wrote:
> 
> > From: Dave Chinner <dchinner@redhat.com>
> >
> > Running metadata intensive workloads, I've been seeing the AIL
> > pushing getting stuck on pinned buffers and triggering log forces.
> > The log force is taking a long time to run because the log IO is
> > getting throttled by wbt_wait() - the block layer writeback
> > throttle. It's being throttled because there is a huge amount of
> > metadata writeback going on which is filling the request queue.
> >
> > IOWs, we have a priority inversion problem here.
> >
> > Mark the log IO bios with REQ_IDLE so they don't get throttled
> > by the block layer writeback throttle. When we are forcing the CIL,
> > we are likely to need to to tens of log IOs, and they are issued as
> > fast as they can be build and IO completed. Hence REQ_IDLE is
> > appropriate - it's an indication that more IO will follow shortly.
> >
> > And because we also set REQ_SYNC, the writeback throttle will no
> > treat log IO the same way it treats direct IO writes - it will not
> > throttle them at all. Hence we solve the priority inversion problem
> > caused by the writeback throttle being unable to distinguish between
> > high priority log IO and background metadata writeback.
> >
>   [ cc Jens ]
> 
> We spent a lot of time getting rid of these inversions in io.latency 
> (and the new io.cost), where REQ_META just blows through the throttling 
> and goes into back charging instead.

Which simply reinforces the fact that that request type based
throttling is a fundamentally broken architecture.

> It feels awkward to have one set of prio inversion workarounds for io.* 
> and another for wbt.  Jens, should we make an explicit one that doesn't 
> rely on magic side effects, or just decide that metadata is meta enough 
> to break all the rules?

The problem isn't REQ_META blows throw the throttling, the problem
is that different REQ_META IOs have different priority.

IOWs, the problem here is that we are trying to infer priority from
the request type rather than an actual priority assigned by the
submitter. There is no way direct IO has higher priority in a
filesystem than log IO tagged with REQ_META as direct IO can require
log IO to make progress. Priority is a policy determined by the
submitter, not the mechanism doing the throttling.

Can we please move this all over to priorites based on
bio->b_ioprio? And then document how the range of priorities are
managed, such as:

(99 = highest prio to 0 = lowest)

swap out
swap in				>90
User hard RT max		89
User hard RT min		80
filesystem max			79
ionice max			60
background data writeback	40
ionice min			20
filesystem min			10
idle				0

So that we can appropriately prioritise different types of kernel
internal IO w.r.t user controlled IO priorities? This way we can
still tag the bios with the type of data they contain, but we
no longer use that to determine whether to throttle that IO or not -
throttling/scheduling should be done entirely on a priority basis.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

