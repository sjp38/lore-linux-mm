Return-Path: <SRS0=RE7g=PQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CC524C43612
	for <linux-mm@archiver.kernel.org>; Tue,  8 Jan 2019 17:58:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 704E2206A3
	for <linux-mm@archiver.kernel.org>; Tue,  8 Jan 2019 17:58:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=linux-foundation.org header.i=@linux-foundation.org header.b="GokJAs66"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 704E2206A3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C29FA8E0087; Tue,  8 Jan 2019 12:58:12 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BAF398E0038; Tue,  8 Jan 2019 12:58:12 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A76778E0087; Tue,  8 Jan 2019 12:58:12 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f71.google.com (mail-lf1-f71.google.com [209.85.167.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3655E8E0038
	for <linux-mm@kvack.org>; Tue,  8 Jan 2019 12:58:12 -0500 (EST)
Received: by mail-lf1-f71.google.com with SMTP id y24so369457lfh.4
        for <linux-mm@kvack.org>; Tue, 08 Jan 2019 09:58:12 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=db+M0hMXHCoSkBdeDd5EZtIcwj8USIPc3aH5GApnu2E=;
        b=rnhhp4ECAeRE8osonW6CCYHV8raAl2qbyySOC2v1Njwpe9pEV9V2DsFUEt79DHm19g
         H515fXiI8iHrvKEfEbbdIiPP2HF4RdVCP9JuN0NZXXtMPwC1yW1qfT5ZlhhrrK7JJkkg
         T6kCaebIl87zWghM0RvjiOxcViXOND7kfsC7eRrAOlP529zUGLvB/UJeuAuoV92FLoPJ
         KBh2g7J2p0F+cP1yWcD+DOMEzS7NcbmOw8GrCpMC9jTWz0Gb/CKEKD4gfhbMsT+qDA/q
         KdZ1cb90EuAnQspaDbHiuDb+P5m53QfiS4ZAKFNYfxpzX39kvbNiCKqJKJC20eyFto1y
         R76g==
X-Gm-Message-State: AJcUukcAHzWLKvQSkM99o4YV/3EY7KtUH29CiLpvExdHxtm7pYr+s+x/
	qf8wQEMmhDd+n40q1P4cShkrwrTIymKo9nlHnVIdQYH4rH1s661HV6DZ1VPb3AgfpQWVIEtPRC1
	BZjXsIfSP8gH5NTF3FUBdO0J5ym2qUN0BRMJoT/TOqtd1WSvCDT5Trc0AACAxHnb27tntD1RLp2
	5/90knv2OIEr9GL1IvMPBbeB5JVNKUrjyMemiulTrQy0RjfxQ68JWTC+IzGpKEMeragyVcNd9iZ
	TECUUOk1zeZVnpNk4kek/MRdrQKCxRDa8fu0w6Ip9zwIxrjLoRXIs2XA/hNBaBcEyfuwqdD4DAR
	mSmsijl/rlq4kTjPljrDX/AVrwUPfeYCh4H4pNvtwl3ZDOP5sXqsbwZHrM1D+Vts3kTEdliq2vK
	m
X-Received: by 2002:a19:5e5d:: with SMTP id z29mr1581144lfi.105.1546970291450;
        Tue, 08 Jan 2019 09:58:11 -0800 (PST)
X-Received: by 2002:a19:5e5d:: with SMTP id z29mr1581101lfi.105.1546970290283;
        Tue, 08 Jan 2019 09:58:10 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1546970290; cv=none;
        d=google.com; s=arc-20160816;
        b=hoHo63Y6bRPeDrJgwiY8pln5HU7yxzx4DMNKBisPkcjyHcfYgfWjJIB8gZhfDIDhI+
         H9VGeRyOfK6ownOrnE7morvCDibIbc/9wtOX2MwW7/CvaNcOkFVy1BYbSACB7YpdNi/V
         WG5fNipjWoWDnpMWL/b/TjKlB/y893HMvEtVpUo8VfrkEVZ6w2Nye7w3DMsXBHoMoy2T
         BIjEekWO1VCxmBIcFvkzPoPRP62+gh9FmVodUFqlklhk4QR7ovoqY1EQrh4+wpSCsCwo
         joUPEyOEHkx6nSTunB3poZtLxyfWqIrYX5wSt4dyU8fg3WSe0lRPHCEymT5YHOQnOZIF
         hpyQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=db+M0hMXHCoSkBdeDd5EZtIcwj8USIPc3aH5GApnu2E=;
        b=d6ULeWwUXsJi3C+LJTmY6OUgSCF6viBc8WNSsVXTPErtsZ/OZsemgQVjpaJ0ce5eQU
         BxpN3fOiBsQFiYfwFdbOShXVeSzqrT7VZqxlx8eO6rIs6R5rzIsw/3UkdfhenmHJgxyF
         MAHC3r67UBPvC8PJsrhIiSP06Y01dbwaujCesGfuJG6VzA2ECsIlI0bRr8i+w3sFvjRU
         PF/Xf5g6msfGsr6waZlo4JB1G+OsVqkLNsKW2YVd41Ub4LTLNx5ulT2h2J7262epIPTh
         sbqNex9pf0OSnKJwElJ312BvLtm7hfw6p61MxoqOj0psffyZs+pBTcW9Q/Djzn7dN/Qq
         0iYA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b=GokJAs66;
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y24-v6sor39689068ljy.1.2019.01.08.09.58.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 08 Jan 2019 09:58:10 -0800 (PST)
Received-SPF: pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b=GokJAs66;
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linux-foundation.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=db+M0hMXHCoSkBdeDd5EZtIcwj8USIPc3aH5GApnu2E=;
        b=GokJAs66VB328JuQAj7nCMPOAKLlFcIc1p0dIohaE7gWVg6SFWJMtUNk8AtOJne6fl
         ykxMuYplWSTTnqZD6aJrfG9Fs/q+OYzkO7lTF3D5CUolWfqub2ihmQauLhXG90AsQt1c
         6/pQk57mtM2CylvQftRJfayqv1m0lTg+9u4aM=
X-Google-Smtp-Source: ALg8bN48sB8A8awIAr5+4gNwM+4+n2bja/bWpR3KbkkAHv/PgCNdhLbgwoJjVjFRdunP51T/ebO5PQ==
X-Received: by 2002:a2e:890b:: with SMTP id d11-v6mr1590673lji.113.1546970288648;
        Tue, 08 Jan 2019 09:58:08 -0800 (PST)
Received: from mail-lf1-f53.google.com (mail-lf1-f53.google.com. [209.85.167.53])
        by smtp.gmail.com with ESMTPSA id u65sm14080720lff.54.2019.01.08.09.58.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Jan 2019 09:58:07 -0800 (PST)
Received: by mail-lf1-f53.google.com with SMTP id u18so3579379lff.10
        for <linux-mm@kvack.org>; Tue, 08 Jan 2019 09:58:06 -0800 (PST)
X-Received: by 2002:a19:6e0b:: with SMTP id j11mr1719606lfc.124.1546970286304;
 Tue, 08 Jan 2019 09:58:06 -0800 (PST)
MIME-Version: 1.0
References: <nycvar.YFH.7.76.1901051817390.16954@cbobk.fhfr.pm>
 <CAG48ez2jAp9xkPXQmVXm0PqNrFGscg9BufQRem2UD8FGX-YzPw@mail.gmail.com>
 <CAHk-=whL4sZiM=JcdQAYQvHm7h7xEtVUh+gYGYhoSk4vi38tXg@mail.gmail.com>
 <CAHk-=wg5Kk+r36=jcGBaLUj+gjopjgiW5eyvkdMqvn0jFkD_iQ@mail.gmail.com>
 <CAHk-=wiMQeCEKESWTmm15x79NjEjNwFvjZ=9XenxY7yH8zqa7A@mail.gmail.com>
 <20190106001138.GW6310@bombadil.infradead.org> <CAHk-=wiT=ov+6zYcnw_64ihYf74Amzqs67iVGtJMQq65PxiVYw@mail.gmail.com>
 <CAHk-=wg1A44Roa8C4dmfdXLRLmNysEW36=3R7f+tzZzbcJ2d2g@mail.gmail.com>
 <CAHk-=wiqbKEC5jUXr3ax+oUuiRrp=QMv_ZnUfO-SPv=UNJ-OTw@mail.gmail.com> <20190108044336.GB27534@dastard>
In-Reply-To: <20190108044336.GB27534@dastard>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 8 Jan 2019 09:57:49 -0800
X-Gmail-Original-Message-ID: <CAHk-=wjvzEFQcTGJFh9cyV_MPQftNrjOLon8YMMxaX0G1TLqkg@mail.gmail.com>
Message-ID:
 <CAHk-=wjvzEFQcTGJFh9cyV_MPQftNrjOLon8YMMxaX0G1TLqkg@mail.gmail.com>
Subject: Re: [PATCH] mm/mincore: allow for making sys_mincore() privileged
To: Dave Chinner <david@fromorbit.com>
Cc: Matthew Wilcox <willy@infradead.org>, Jann Horn <jannh@google.com>, 
	Jiri Kosina <jikos@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, 
	Greg KH <gregkh@linuxfoundation.org>, Peter Zijlstra <peterz@infradead.org>, 
	Michal Hocko <mhocko@suse.com>, Linux-MM <linux-mm@kvack.org>, 
	kernel list <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190108175749.OEKWJcx_j0MIynW0W2EBZJ0o7Z-wfrDtbzuB-SRxCKs@z>

On Mon, Jan 7, 2019 at 8:43 PM Dave Chinner <david@fromorbit.com> wrote:
>
> So, I read the paper and before I was half way through it I figured
> there are a bunch of other similar page cache invalidation attacks
> we can perform without needing mincore. i.e. Focussing on mmap() and
> mincore() misses the wider issues we have with global shared caches.

Oh, agreed, and that was discussed in the original report too.

The thing is, you can also depend on our pre-faulting of pages in the
page fault handler, and use that to get the cached status of nearby
pages. So do something like "fault one page, then do mincore() to see
how many pages near it were mapped". See our "do_fault_around()"
logic.

But mincore is certainly the easiest interface, and the one that
doesn't require much effort or setup. It's also the one where our old
behavior was actually arguably simply stupid and actively wrong (ie
"in caches" isn't even strictly speaking a valid question, since the
caches in question may be invalid). So let's try to see if giving
mincore() slightly more well-defined semantics actually causes any
pain.

I do think that the RWF_NOWAIT case might also be interesting to look at.

                 Linus

