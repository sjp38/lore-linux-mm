Return-Path: <SRS0=euUm=P7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C2845C282C0
	for <linux-mm@archiver.kernel.org>; Wed, 23 Jan 2019 23:14:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7DA9721855
	for <linux-mm@archiver.kernel.org>; Wed, 23 Jan 2019 23:14:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="uGCbI81j"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7DA9721855
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 243678E0060; Wed, 23 Jan 2019 18:14:37 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1F3248E0047; Wed, 23 Jan 2019 18:14:37 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 10CA88E0060; Wed, 23 Jan 2019 18:14:37 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id D52E48E0047
	for <linux-mm@kvack.org>; Wed, 23 Jan 2019 18:14:36 -0500 (EST)
Received: by mail-yw1-f70.google.com with SMTP id d72so2065932ywe.9
        for <linux-mm@kvack.org>; Wed, 23 Jan 2019 15:14:36 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=77nseqghbtkKnRpvB3e475OP+PoAx0CijNQ1xr4WOls=;
        b=oBkXa3hN3/fsntfUbNqB8e6dW3oIDxMbPnt6jypE68j0aLdsfRDBG88O+1gcXDWIoK
         5zwMn7aShFppvmdc2DBHGlkyVFpcD2FJ5viRNCIYHaWAslVv7GcEtvcAuBKjfzqCOzdp
         6bm3t+hdUawczCSDi1KLdFzitH2cT648wUHrK4aqWXVYeQZyH3PEcGxVV5BZKB/AGm1G
         3W9yQvbku6/OlJsAHfW70+G/N9GT7i8fK8yhsIe6SBv9GTyXeQM1RYDny+LUZNJt5VhX
         G7hJiP/aLucUJL6w3jyBcJhnHJPJ3CxaQkNNLzv0qqJmHOAQytAyf/Dp28qtLcLhbVTV
         jBfA==
X-Gm-Message-State: AJcUukcbiofVr+d6tt+mxKRQMBdxBE7mLB3DwXn0ZyQ36ocD2ZXtL0M2
	MPWoxx3gL4xeruJdIm16T5BK12Bo1ebj63tNEkQ0jjOLO/9us9hWmS0PMirWr/NYwO2EZETmg9r
	mK6iu9Con6yA3HwonlPi5hV2+K27j/WEYtAq0TdyLCzSNDnqDr1ZXTCEXau9etfAeZmSLXCQi7d
	HOyiHZRTar5vthG6Snhoy+AR70u66lf6FmMirwOaGvB+5B6xDppttzoFqQ2UOvdAHxGb0I7W6kv
	HFP986wY1pgHupqqJh8NRCZHbAm9o2U2dyGiqTytiHdKNy7aV7FgAOsSO3mZdLOgX/8dKSEIMVC
	ZRbKY0wW3EX4FmAypRMfIv0kClRIv/NSIxxs3AH4uFVSBclAP7X576AbIfAn/a9swYTylLJp3vY
	6
X-Received: by 2002:a25:810c:: with SMTP id o12mr525377ybk.507.1548285276525;
        Wed, 23 Jan 2019 15:14:36 -0800 (PST)
X-Received: by 2002:a25:810c:: with SMTP id o12mr525344ybk.507.1548285275942;
        Wed, 23 Jan 2019 15:14:35 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548285275; cv=none;
        d=google.com; s=arc-20160816;
        b=eNHH058hBeXQNP9CpbexCsy441jrHiP0P8MbwE5EMPnriOkNUBv0SWP4aFPoAeCjcI
         gsmoT1keQJ+inuNrPD4TIKo6wE0IqVlfRdYPeinpI0LkdUb58yknuX+p4ankYk3FKTsn
         UPC5cIwuNF88esNzIqroII+EMBG1BfPyQqrsEWf1OsJNWy1ZQI+bfbWG284fv4puprzc
         VdIXMNBvGN4h155XpB54BDeIAGQpPN//rY79nMSsSLK5GNLm+l2RUlUBesqwtx++TQi2
         tdA1vhTrQPPOzQARON8Filu2nP3uwld2akKXjmdwu9+9ek4Ygz5CHiDMaLMkJubo4ftb
         HlQw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=77nseqghbtkKnRpvB3e475OP+PoAx0CijNQ1xr4WOls=;
        b=Eed1TWB9MJYNgry57j0Ct+LSgNWV0QMeoQM3a3LIt7NUr4U8A1A/cyOOyZA8bsiZJg
         wZq2a8LmRGZ6baKXaXg557hnXGCKBo9gC+H89iG2PSKnbyRTnGMmykep9TQ9ApfN6e02
         YPffEp2V4/C91WJCvLZKsBrRrWDyYeVZodgzgtgqVGKu1P7sY8dbPE5RREFcNVNWTiH0
         qsaAZLWgcxPEqSFrl6i0iy1XQX4FJ4qDY+1kxgUou9RX6tFagMSV7/1Yeb4k60GyPdUf
         1X/IaEy9vHKhDU5KiOA0f84t/c6rQUUWe2PC+ptzwpdumpwmfEDcIWIYQCwi5IK9B5TT
         S3Hw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=uGCbI81j;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x137sor2711312ywg.141.2019.01.23.15.14.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 23 Jan 2019 15:14:35 -0800 (PST)
Received-SPF: pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=uGCbI81j;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=77nseqghbtkKnRpvB3e475OP+PoAx0CijNQ1xr4WOls=;
        b=uGCbI81jfiPjJKcNJOeEOOYc7D+GD5tAx5o4QqDcnN2jXkUw6RH7RZtHQT84tsntVh
         6tGdeExAIGA/05gxxWyhyckbR128hFtWJ4u8WdBxZ+dtJ+QNDHe3RRM8jgohOmOt/nXD
         BXmVp0sM2UnzA4l/Jt0lqcA9NcW+L+Dk1cFJneL5YS1QF6GwyalZlc382VyMuTPnMF4K
         taJCuZ9PVnjNnzvpp2ji+/FLFqXflAfQzzr1QiWbJbw58ibrqT40MxR4NKVw7Pmct/Gt
         sFvECnkjmmS1a0OndhB3jDCTfyFMoHCwEIGFARGXzkd/MTbhk3/IM6ezw6KdHQsx4srJ
         7fxw==
X-Google-Smtp-Source: ALg8bN5/2AzYRxKLMu5LI/hDbLHSR/jN9IBZ4A2oLxjcFDGOySnrBCBRZaPkMbQWulmQXz9os4q4lrzOE3Th0laJ28c=
X-Received: by 2002:a81:ee07:: with SMTP id l7mr4081632ywm.489.1548285275451;
 Wed, 23 Jan 2019 15:14:35 -0800 (PST)
MIME-Version: 1.0
References: <20190121215850.221745-1-shakeelb@google.com> <20190123225747.8715120856@mail.kernel.org>
In-Reply-To: <20190123225747.8715120856@mail.kernel.org>
From: Shakeel Butt <shakeelb@google.com>
Date: Wed, 23 Jan 2019 15:14:24 -0800
Message-ID:
 <CALvZod5h7fSoZTA+3bDTn93JuFgY=SUGEq=gpDYE8rdSfuNcPQ@mail.gmail.com>
Subject: Re: [PATCH v3 1/2] mm, oom: fix use-after-free in oom_kill_process
To: Sasha Levin <sashal@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Linux MM <linux-mm@kvack.org>, 
	LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, 
	David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, 
	stable@kernel.org, stable@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190123231424.7Kf7ciC27b4ZRaTuYBFFq8pzNzknrgTfcbgL0p6I8-k@z>

On Wed, Jan 23, 2019 at 2:57 PM Sasha Levin <sashal@kernel.org> wrote:
>
> Hi,
>
> [This is an automated email]
>
> This commit has been processed because it contains a "Fixes:" tag,
> fixing commit: 6b0c81b3be11 mm, oom: reduce dependency on tasklist_lock.
>
> The bot has tested the following trees: v4.20.3, v4.19.16, v4.14.94, v4.9.151, v4.4.171, v3.18.132.
>
> v4.20.3: Build OK!
> v4.19.16: Build OK!
> v4.14.94: Failed to apply! Possible dependencies:
>     5989ad7b5ede ("mm, oom: refactor oom_kill_process()")
>

Very easy to resolve the conflict. Please let me know if you want me
to send a version for 4.14-stable kernel.

> v4.9.151: Build OK!
> v4.4.171: Build OK!
> v3.18.132: Build OK!
>
>
> How should we proceed with this patch?
>

We do want to backport this patch to stable kernels. However shouldn't
we wait for this patch to be applied to Linus's tree first.

Shakeel

