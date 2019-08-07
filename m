Return-Path: <SRS0=t1E5=WD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A239AC32754
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 20:34:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 66EE121BE3
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 20:34:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="gA2Gxo3V"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 66EE121BE3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 352C46B0003; Wed,  7 Aug 2019 16:34:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 329A56B0006; Wed,  7 Aug 2019 16:34:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 23F176B0007; Wed,  7 Aug 2019 16:34:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 027D86B0003
	for <linux-mm@kvack.org>; Wed,  7 Aug 2019 16:34:18 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id r15so4863266qtt.6
        for <linux-mm@kvack.org>; Wed, 07 Aug 2019 13:34:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=IC+13V8Mtk7y8HC7bnHIWtqIcy1I5HJyllIeTOClBTQ=;
        b=RRo/GOXlQU+KY31Hk3PXMIFZD0gFnVGHAUSsU3HP3pm3nR0hUswS05SqvWIGh0SjmW
         xVEyYV1uHOV+krKkLemigbHqyYz9Q+HDhSWKfXhgRPIV6WV/dry274cxY0lLPcik6LWw
         tXRncQsfgwVtKaOoykuERFs6m3qwDpKP3nZNi1jL0xASAzppcfFVcPnant+Mn2dFWnza
         jvL+GxHQMnWg7zkSAKPrXo7j9cCl+/3ZMXFwF19wE9AXcLe4MnsKuyorfTH9wZspeOg+
         NoAYEm7puqdUkX0T8XlES48ToyuGnD9GKIUPghqyzq97oYXPcGKyNm7Jk/nLteGMWJh3
         bm2A==
X-Gm-Message-State: APjAAAX+QBsVkm89xBcsPq2vOE+zupg2F4pNlgyd+6tXEEJy2g6R43Z5
	Sg3fmsAUl45GNmGxRsA8noYThlJiOEDZIATJ2AAL5G1LYs1RWNGMSQ1C17680hATB/Ljz6AiGyT
	aQmhF+Nla4UP6B3K/CQhxwZJqw7M36HbGSTff9RIeZ/wQRHvHIUCimpiwJ8CdTPY=
X-Received: by 2002:ac8:7488:: with SMTP id v8mr5931697qtq.312.1565210057702;
        Wed, 07 Aug 2019 13:34:17 -0700 (PDT)
X-Received: by 2002:ac8:7488:: with SMTP id v8mr5931663qtq.312.1565210057104;
        Wed, 07 Aug 2019 13:34:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565210057; cv=none;
        d=google.com; s=arc-20160816;
        b=gSebMxeysPMSgT8U40sbNbfJFSbFGUsOXF0iOQWTG1UYGAHgAi+0OpfNpNwCJRICLe
         Lou0N0p4Rii2hPhnPTdEc61dli2qT7RWB4YjfgKgnY7frlq/c1gWyWtyBz0JIX6SMisc
         WAzxVpy5QS2JXn+lcCbTUlYWiLvx2heojVIypfJldOEGM7Ejfu9XytmVRXCpn34rxLR1
         f/8SW+yy5fy/eFczJ2cpyG5Hss6Mz4BCxgHb1iLdAhqNxyzCWu6BiCgTCCjad43LGufU
         x5drHdibCZkl+7sbhQMFNJECDcywcLvwri5JHOX8OLsK0ji2sOTt61tkWLe90P54jjPl
         nVMQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:sender:dkim-signature;
        bh=IC+13V8Mtk7y8HC7bnHIWtqIcy1I5HJyllIeTOClBTQ=;
        b=Iv7tWCUYFAEKT/PkIxou1sa6goqXLlEyvhze/m0eOVzeY9+zOPoZFD/cCcHPrikjOH
         gepVrkTQ8k4dMX9zvQsgFZrYlpKNOmeahWPZ0aC9Xkst53RCh3K2kgvJPWGzEAjBdKb8
         7pKwoPcRnTMF2JYD9gCu7/zKpZn6KJFf3OcRpLIT1Fppkr0+0LmjEM+9sahOE7u0B9Le
         NYOYB+iXGP6gdnKYTRiHv4L3rMqjSFzSsEX36VpX9MDtlCEZ/tTKHADmY2NTvQtqaJWT
         5bfjG0I3uTRBoWatVEvpo+4LVslVsKqmd3vxtkIqT1aodAGQrz9fkiNsIaaGIV00FTJl
         Kseg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=gA2Gxo3V;
       spf=pass (google.com: domain of htejun@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=htejun@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n16sor2343464qtl.23.2019.08.07.13.34.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 07 Aug 2019 13:34:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of htejun@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=gA2Gxo3V;
       spf=pass (google.com: domain of htejun@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=htejun@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=IC+13V8Mtk7y8HC7bnHIWtqIcy1I5HJyllIeTOClBTQ=;
        b=gA2Gxo3VVUUiZocJ2EWD7FWO7YBQ8ft67UkLPK3AQg2nN2DoElFq/GksGEaLO+Xxs7
         yBG49lmFjj6YiLTjAaIGIQ41gk0yijO+ArJDE8dr0MOM8hPWXP6zZJu4zTmZ5U0pgrQi
         HknnD6KZRyK/MCSoGtYJTTYotU0YW8UoTRgeuRn+pC5MZtc7pzuYv6kj3xs5K4Iq01gZ
         86PLHXMC6iInXVPSj6NydUiB8ADQvz4JihwAriUqmR/FNZBo1PmtDfw6VQ/NCCRIFgf2
         ZxOvpizlKlGxc62Gw+giLRS40hco+rKNH4/JXvGmrSXjrc5JQOrAHKmp7zbC6NOQ0jDG
         Tr4A==
X-Google-Smtp-Source: APXvYqzu1jOsh0kIjF9dIWwpYxRpLf5Yj5gvt8IrWIJbtljX2Px5uBUwWjZwjoub/a03bW3NQndjfA==
X-Received: by 2002:ac8:45d2:: with SMTP id e18mr9931619qto.258.1565210056622;
        Wed, 07 Aug 2019 13:34:16 -0700 (PDT)
Received: from localhost ([2620:10d:c091:500::2:49ab])
        by smtp.gmail.com with ESMTPSA id t11sm6284977qkt.85.2019.08.07.13.34.15
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Aug 2019 13:34:15 -0700 (PDT)
Date: Wed, 7 Aug 2019 13:34:14 -0700
From: Tejun Heo <tj@kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: axboe@kernel.dk, jack@suse.cz, hannes@cmpxchg.org, mhocko@kernel.org,
	vdavydov.dev@gmail.com, cgroups@vger.kernel.org, linux-mm@kvack.org,
	linux-block@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-team@fb.com, guro@fb.com
Subject: Re: [PATCH 2/4] bdi: Add bdi->id
Message-ID: <20190807203414.GA554060@devbig004.ftw2.facebook.com>
References: <20190803140155.181190-1-tj@kernel.org>
 <20190803140155.181190-3-tj@kernel.org>
 <20190806160102.11366694af6b56d9c4ca6ea3@linux-foundation.org>
 <20190807183151.GM136335@devbig004.ftw2.facebook.com>
 <20190807120037.72018c136db40e88d89c05d1@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190807120037.72018c136db40e88d89c05d1@linux-foundation.org>
User-Agent: Mutt/1.5.21 (2010-09-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hello,

On Wed, Aug 07, 2019 at 12:00:37PM -0700, Andrew Morton wrote:
> OK, but why is recycling a problem?  For example, file descriptors
> recycle as aggressively as is possible, and that doesn't cause any
> trouble.  Presumably recycling is a problem with cgroups because of
> some sort of stale reference problem?

Oh, because there are use cases where the consumers are detached from
the lifetime synchronization.  In this example, the benefit of using
IDs is that memcgs don't need to pin foreign bdi_wb's and just look up
and verify when it wants to flush them.  If we use pointers, we have
to pin the objects which then requires either shooting down those
references with timers or somehow doing reverse lookup to shoot them
down when bdi_wb is taken offline.  If we use IDs which can be
recycling aggressively, there can be pathological cases where remote
flushes are issued on the wrong target possibly repeatedly, which may
or may not be a real problem.

For cgroup ID, the problem is more immediate.  We give out the IDs to
userspace and there is no way to shoot those references down when the
cgroup goes away and the ID gets recycled, so when the user comes back
and asks "I want to attach this bpf program to the cgroup identified
with this ID", we can end up attaching it to the wrong cgroup if we
recycle IDs.  cgroup ended up with two separate IDs, which is kinda
dumb.

tl;dr is that it's either cumbersome or impossible to synchronize the
users of these IDs, so if they get recycled, they end up identifying
the wrong thing.

Thanks.

-- 
tejun

