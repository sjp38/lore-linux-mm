Return-Path: <SRS0=idO3=TP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 37FE6C04E53
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 14:00:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CA16220873
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 14:00:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amazonses.com header.i=@amazonses.com header.b="GPh6v1G7"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CA16220873
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3A08D6B0005; Wed, 15 May 2019 10:00:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 351CD6B0006; Wed, 15 May 2019 10:00:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2197C6B0007; Wed, 15 May 2019 10:00:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id F3F6C6B0005
	for <linux-mm@kvack.org>; Wed, 15 May 2019 10:00:11 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id g7so2342758qkb.7
        for <linux-mm@kvack.org>; Wed, 15 May 2019 07:00:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version
         :feedback-id;
        bh=4ieRb2nYTufrIwfIxuW2F44/d/JKF6r4h/5BZmbEcuI=;
        b=ZHVeb1/WyBroCUlhb7XycMobUueQj7lU0kPkCwQervgtqBMzbXckZdz9MfLJQbn3tl
         0Op9qgo1XDycJHbcWed03AzUMrnRuffXij2kXIfPDsuxrrFE+vwcyEaETTCA9+IE/AmB
         rD/BJuNo5axCjF8E7UpvPEuw1OAlJ0itFkOK7hLBdNWI0AOLpWZ+NlMzvHgDBJ/j7Su3
         LYdfUJuWz6BjLo/FeoFDLB/M2mI7hMcXS6oEiV3X+l5KO01Hx9xEQ9hvFaNWGKckvSk5
         G/SK4uZEzMY8GQ88w0wlt/bRorFDyMMGkvYi3uPt32vmM6mTBhORxKLRVcO/smxnsykU
         UZjw==
X-Gm-Message-State: APjAAAX3nzvBijM7L0virYxLRoqGbHeGANxTIsEHdwemc0kZQXkIcj9G
	qW/+mAcb9sFel3Z3mlOh+qfoosklIJglH8eIcIVDs0yw2fER/SVQlaSkhm/wTD6qWUqaJXzsyIr
	sS8R9ixWzKOX4/4+Ny64HFOV/vRNg6+cCZLYsr6uh7a5BidDewXK7ewlRRQ0k4EQ=
X-Received: by 2002:aed:354c:: with SMTP id b12mr36557019qte.251.1557928811786;
        Wed, 15 May 2019 07:00:11 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxlz2ABnLZSughq8/V9DPAsLFsLqVOj+XVVL/6q5pM/Kpcbqm4qicoL5aqRR0M4YENC9dxZ
X-Received: by 2002:aed:354c:: with SMTP id b12mr36556820qte.251.1557928809988;
        Wed, 15 May 2019 07:00:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557928809; cv=none;
        d=google.com; s=arc-20160816;
        b=whA4cckSRvLJ6Wu0luJyIkANfs1cG/OuVbv1GbX5X1SLoVq6NXwoyzcr1KEP3TDYTl
         wt9Pa9QPkd4f8fir8/yUFXjk3rdSOitAA8txSTpB+dyu9TmSCdheW8GjkiGZiDmOrIFi
         0upWp7oPQ10QpKZxEx3EmyYyWqirI4kc4s3zHBFsO5kq9cJgjz4qK6ev/QYxlYL7dloE
         JED5N+CvzNxqmgOjQKt4QcHstLM7GdowM83kVMCW/eeGuYoOyBA+MTOAnK/tYvWzZqlI
         E/io69Y6jgpmre1pGPu/u1wiqdAAnWinLUfZzo5GS9cyZQEQ9dRS3ycwwPb31WCggVj5
         SM3w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=feedback-id:mime-version:user-agent:references:message-id
         :in-reply-to:subject:cc:to:from:date:dkim-signature;
        bh=4ieRb2nYTufrIwfIxuW2F44/d/JKF6r4h/5BZmbEcuI=;
        b=ryrnJxanDBuI6+flHTPfsUMrUfkPKfmRPkHcc2ngXhcdTJfVgTNq4o6pvcffZN7Kkq
         wsxbGxCip0/O8kG3D9u2oUsVQ0964WzTm5dbFf2XIZO9Z77QKkps62wMKSy/fKpFqo2L
         lVv70FDNQyxnhygTnqKuqWizrvKaUJUwHLpxsjJ4C2Ig5cEgpgEU8C34p5kHmo1bkT0u
         tq2oRSOhzXM9+LkPlj4OHR0ScC6aBBD5neNNpBLRo0H/T2RVLw6gLKUnFUSrOpIcr3Wv
         ATnFZJ+07PiHVUoMZbM+7I/bSbj7ghHWwL+FjyuYtGm1qlflXRPeM6nkmVEhdHsjTA9G
         drkA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw header.b=GPh6v1G7;
       spf=pass (google.com: domain of 0100016abbcb13b1-a1f70846-1d8c-4212-8e74-2b9be8c32ce7-000000@amazonses.com designates 54.240.9.34 as permitted sender) smtp.mailfrom=0100016abbcb13b1-a1f70846-1d8c-4212-8e74-2b9be8c32ce7-000000@amazonses.com
Received: from a9-34.smtp-out.amazonses.com (a9-34.smtp-out.amazonses.com. [54.240.9.34])
        by mx.google.com with ESMTPS id g123si1430429qkd.172.2019.05.15.07.00.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 15 May 2019 07:00:09 -0700 (PDT)
Received-SPF: pass (google.com: domain of 0100016abbcb13b1-a1f70846-1d8c-4212-8e74-2b9be8c32ce7-000000@amazonses.com designates 54.240.9.34 as permitted sender) client-ip=54.240.9.34;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw header.b=GPh6v1G7;
       spf=pass (google.com: domain of 0100016abbcb13b1-a1f70846-1d8c-4212-8e74-2b9be8c32ce7-000000@amazonses.com designates 54.240.9.34 as permitted sender) smtp.mailfrom=0100016abbcb13b1-a1f70846-1d8c-4212-8e74-2b9be8c32ce7-000000@amazonses.com
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/simple;
	s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw; d=amazonses.com; t=1557928809;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:MIME-Version:Content-Type:Feedback-ID;
	bh=4ieRb2nYTufrIwfIxuW2F44/d/JKF6r4h/5BZmbEcuI=;
	b=GPh6v1G7tBjvpfFjo9hMZCwciiN03v/sot2b6JO2p5YHO8lXYBnhnIAa773fVXRu
	NGiplz1lNIFeTYhBR7fj8DXMn08uMJgxeOHgROgOZJOZJdlyx8cjerUOr72NjVKKNYE
	reEPlVqpmXBv9O4oVqSDSIIrIfo8rpP9+X97ikkw=
Date: Wed, 15 May 2019 14:00:09 +0000
From: Christopher Lameter <cl@linux.com>
X-X-Sender: cl@nuc-kabylake
To: Roman Gushchin <guro@fb.com>
cc: Andrew Morton <akpm@linux-foundation.org>, 
    Shakeel Butt <shakeelb@google.com>, linux-mm@kvack.org, 
    linux-kernel@vger.kernel.org, kernel-team@fb.com, 
    Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, 
    Rik van Riel <riel@surriel.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, 
    cgroups@vger.kernel.org
Subject: Re: [PATCH v4 5/7] mm: rework non-root kmem_cache lifecycle
 management
In-Reply-To: <20190514213940.2405198-6-guro@fb.com>
Message-ID: <0100016abbcb13b1-a1f70846-1d8c-4212-8e74-2b9be8c32ce7-000000@email.amazonses.com>
References: <20190514213940.2405198-1-guro@fb.com> <20190514213940.2405198-6-guro@fb.com>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-SES-Outgoing: 2019.05.15-54.240.9.34
Feedback-ID: 1.us-east-1.fQZZZ0Xtj2+TD7V5apTT/NrT6QKuPgzCT/IC7XYgDKI=:AmazonSES
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000002, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 14 May 2019, Roman Gushchin wrote:

> To make this possible we need to introduce a new percpu refcounter
> for non-root kmem_caches. The counter is initialized to the percpu
> mode, and is switched to atomic mode after deactivation, so we never
> shutdown an active cache. The counter is bumped for every charged page
> and also for every running allocation. So the kmem_cache can't
> be released unless all allocations complete.

Increase refcounts during each allocation? Looks to be quite heavy
processing.

