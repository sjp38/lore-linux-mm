Return-Path: <SRS0=IGNm=TV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: *
X-Spam-Status: No, score=1.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	FSL_HELO_FAKE,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 33FEFC04E87
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 11:06:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DE714217D4
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 11:06:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="CA08YdMI"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DE714217D4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 560FD6B0003; Tue, 21 May 2019 07:06:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 511896B0005; Tue, 21 May 2019 07:06:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3D9EC6B0006; Tue, 21 May 2019 07:06:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 080096B0003
	for <linux-mm@kvack.org>; Tue, 21 May 2019 07:06:01 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id 94so11180927plc.19
        for <linux-mm@kvack.org>; Tue, 21 May 2019 04:06:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=KOZb8yQcjy+VjCqxduvm6OD6AUx3NXKhaQcxseL+T4k=;
        b=NzsUyOCvitr++UyEpWjJyTzyzy9JOVRfgz+oVlPAYWNhe3j09l7PxnArDSbawdQxo1
         mfDhbciWNWWBFueItLx/N0MPZRP4RbDoJkE0M1BXharM5ZQoh2rlUBWNZ6f06nlygkc3
         jVSiM/zefpL1ZQ+zg0YlUIg5K7936MJsST4TsnLzkyYwf4kKbDq5RdRg0N2Lzhk9BTxS
         /yxOjkEiePmoyLCf3xTMUv5bgWUQgXXNpck+0OF5HtzW+PuY/R2F57h2Csj9y+9WlQw+
         Ej4J0LJAznb6mWOoZfROe9j41oXV1Agu2KdET80DOtkbz1RjnMyUByDhPmBX8UfJdwHr
         kzVg==
X-Gm-Message-State: APjAAAUdQ1tZiwr71QUB4dxjFCW6D5Ry1znSfBUcjEzPHn7+lSr6/TVe
	o6MuVVqn4hAKtUirFVHEJi5UdD3pT+PKcZCHGXH4EcAnFZ1jNYkj4+PlUoTvBBl+sGZqkXsFyc8
	nVvaGNHSdIkVbI5hZ4BVrzr/jbTmFpUGkp8hAJmeiLvOd+vFxgA4XvVALM8y0qj4=
X-Received: by 2002:a62:1846:: with SMTP id 67mr67675091pfy.33.1558436760632;
        Tue, 21 May 2019 04:06:00 -0700 (PDT)
X-Received: by 2002:a62:1846:: with SMTP id 67mr67675008pfy.33.1558436759830;
        Tue, 21 May 2019 04:05:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558436759; cv=none;
        d=google.com; s=arc-20160816;
        b=ngXvDpPPbbVD7ZZesIxjOg8gwn06gybhEX4WkNXazUU/xgUz0VaqEKtr7TXApJ/Y1W
         M9GNIJR7IPQcBnZbfo8G1IrYTxTrGNOZJu2laEjTkVM8Mnu0GFmXVkn22cFxzUOVhVn/
         Q1T5k5/okmmeJyGNSIq6GZ12hxKIborSLeyH/YhEb26ZsvPzdjXOgfXyYW/J4YycAW9k
         0Lx80D/9Wy0batuFKdiQGYFSAWvQ4o6Fw16NydA9H0lYjA38MK8VKIBCemH7/DcHc35J
         JLeZRanvSyeRyDYNO58rutithDb23zux9UHQu7+feMuZ6vWf/a4oHfedwZd1aGvGe0Cu
         ORFA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date:sender:dkim-signature;
        bh=KOZb8yQcjy+VjCqxduvm6OD6AUx3NXKhaQcxseL+T4k=;
        b=hQP1anU6i7prYftmG6e9IRkSSC3mvPKVm1fhkbj5N7izZI7iyOgo1UW2a2RTICD5VU
         F9WK4AyGpIyAXLEu7QkKmKJT84qFj9sTmGG3VOA27yTbwP/UfmhDV26+RRuy0guxlJK9
         ew1yaw2DMX+M8ZKR1xVS19B0JAKKqBKnwOD+kRQX6eLKFlOsR2OLG7b8DGRHRZHPrE08
         Yhfogs+S5TjjlePEbm3wVRfsYjyyPK/4HZiZOpJH1kZWciWA/XBv8Pvu/Sb2cP2p9xq1
         4FtL151YSSK15/lyWbS0wgt9YXraEfBs+hoSOfDpXVdAxvUw5J2hpTmb6Kix6ITMpPQo
         BoOA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=CA08YdMI;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x26sor559120pff.43.2019.05.21.04.05.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 21 May 2019 04:05:59 -0700 (PDT)
Received-SPF: pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=CA08YdMI;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:content-transfer-encoding:in-reply-to
         :user-agent;
        bh=KOZb8yQcjy+VjCqxduvm6OD6AUx3NXKhaQcxseL+T4k=;
        b=CA08YdMIhOU/VrYm5k9zPXXxOIVVirvReQ8Y2vIbgjyvR/my+aC7evfjsYLMswEKYu
         2WAIX7SPn9ewBv3dRf5ErbnWeoH3xnY9J8WBoppqqmKLckLRXJgjedKaZkx8GNdOUFQU
         dDtuCcAcSjT/ENaln53Wnl7gArCEAukOPQ5ksWGjz8LdjWv9eLudbpaBY1RHZ47ZY0jD
         lr5tYJNYv77s6nCydHZUSzJAvSZftVRePPQnEgENa+BRrGzYNVdqv78HJd97q5qtcmSF
         K3cjY0TWfVcUl0KewMvxp6yT85emXsT3Ydg4x3M0GvNpBMbIGCwl/a1huFd0FZFA+p6m
         +pUg==
X-Google-Smtp-Source: APXvYqxlqlFPB+NUCI72RbnbT2TM6iFMigkYLu0cELmj7et0/QOSGQxsMk8DSdijr03Yep9LS5ijzw==
X-Received: by 2002:a62:87c6:: with SMTP id i189mr88245711pfe.65.1558436759441;
        Tue, 21 May 2019 04:05:59 -0700 (PDT)
Received: from google.com ([2401:fa00:d:0:98f1:8b3d:1f37:3e8])
        by smtp.gmail.com with ESMTPSA id x7sm15581305pfm.82.2019.05.21.04.05.55
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 21 May 2019 04:05:58 -0700 (PDT)
Date: Tue, 21 May 2019 20:05:52 +0900
From: Minchan Kim <minchan@kernel.org>
To: Christian Brauner <christian@brauner.io>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
	Michal Hocko <mhocko@suse.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Tim Murray <timmurray@google.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Daniel Colascione <dancol@google.com>,
	Shakeel Butt <shakeelb@google.com>, Sonny Rao <sonnyrao@google.com>,
	Brian Geffon <bgeffon@google.com>, jannh@google.com
Subject: Re: [RFC 0/7] introduce memory hinting API for external process
Message-ID: <20190521110552.GG219653@google.com>
References: <20190520035254.57579-1-minchan@kernel.org>
 <20190521084158.s5wwjgewexjzrsm6@brauner.io>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190521084158.s5wwjgewexjzrsm6@brauner.io>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 21, 2019 at 10:42:00AM +0200, Christian Brauner wrote:
> On Mon, May 20, 2019 at 12:52:47PM +0900, Minchan Kim wrote:
> > - Background
> > 
> > The Android terminology used for forking a new process and starting an app
> > from scratch is a cold start, while resuming an existing app is a hot start.
> > While we continually try to improve the performance of cold starts, hot
> > starts will always be significantly less power hungry as well as faster so
> > we are trying to make hot start more likely than cold start.
> > 
> > To increase hot start, Android userspace manages the order that apps should
> > be killed in a process called ActivityManagerService. ActivityManagerService
> > tracks every Android app or service that the user could be interacting with
> > at any time and translates that into a ranked list for lmkd(low memory
> > killer daemon). They are likely to be killed by lmkd if the system has to
> > reclaim memory. In that sense they are similar to entries in any other cache.
> > Those apps are kept alive for opportunistic performance improvements but
> > those performance improvements will vary based on the memory requirements of
> > individual workloads.
> > 
> > - Problem
> > 
> > Naturally, cached apps were dominant consumers of memory on the system.
> > However, they were not significant consumers of swap even though they are
> > good candidate for swap. Under investigation, swapping out only begins
> > once the low zone watermark is hit and kswapd wakes up, but the overall
> > allocation rate in the system might trip lmkd thresholds and cause a cached
> > process to be killed(we measured performance swapping out vs. zapping the
> > memory by killing a process. Unsurprisingly, zapping is 10x times faster
> > even though we use zram which is much faster than real storage) so kill
> > from lmkd will often satisfy the high zone watermark, resulting in very
> > few pages actually being moved to swap.
> > 
> > - Approach
> > 
> > The approach we chose was to use a new interface to allow userspace to
> > proactively reclaim entire processes by leveraging platform information.
> > This allowed us to bypass the inaccuracy of the kernel’s LRUs for pages
> > that are known to be cold from userspace and to avoid races with lmkd
> > by reclaiming apps as soon as they entered the cached state. Additionally,
> > it could provide many chances for platform to use much information to
> > optimize memory efficiency.
> > 
> > IMHO we should spell it out that this patchset complements MADV_WONTNEED
> > and MADV_FREE by adding non-destructive ways to gain some free memory
> > space. MADV_COLD is similar to MADV_WONTNEED in a way that it hints the
> > kernel that memory region is not currently needed and should be reclaimed
> > immediately; MADV_COOL is similar to MADV_FREE in a way that it hints the
> > kernel that memory region is not currently needed and should be reclaimed
> > when memory pressure rises.
> > 
> > To achieve the goal, the patchset introduce two new options for madvise.
> > One is MADV_COOL which will deactive activated pages and the other is
> > MADV_COLD which will reclaim private pages instantly. These new options
> > complement MADV_DONTNEED and MADV_FREE by adding non-destructive ways to
> > gain some free memory space. MADV_COLD is similar to MADV_DONTNEED in a way
> > that it hints the kernel that memory region is not currently needed and
> > should be reclaimed immediately; MADV_COOL is similar to MADV_FREE in a way
> > that it hints the kernel that memory region is not currently needed and
> > should be reclaimed when memory pressure rises.
> > 
> > This approach is similar in spirit to madvise(MADV_WONTNEED), but the
> > information required to make the reclaim decision is not known to the app.
> > Instead, it is known to a centralized userspace daemon, and that daemon
> > must be able to initiate reclaim on its own without any app involvement.
> > To solve the concern, this patch introduces new syscall -
> > 
> > 	struct pr_madvise_param {
> > 		int size;
> > 		const struct iovec *vec;
> > 	}
> > 
> > 	int process_madvise(int pidfd, ssize_t nr_elem, int *behavior,
> > 				struct pr_madvise_param *restuls,
> > 				struct pr_madvise_param *ranges,
> > 				unsigned long flags);
> > 
> > The syscall get pidfd to give hints to external process and provides
> > pair of result/ranges vector arguments so that it could give several
> > hints to each address range all at once.
> > 
> > I guess others have different ideas about the naming of syscall and options
> > so feel free to suggest better naming.
> 
> Yes, all new syscalls making use of pidfds should be named
> pidfd_<action>. So please make this pidfd_madvise.

I don't have any particular preference but just wondering why pidfd is
so special to have it as prefix of system call name.

> 
> Please make sure to Cc me on this in the future as I'm maintaining
> pidfds. Would be great to have Jann on this too since he's been touching
> both mm and parts of the pidfd stuff with me.

Sure!

