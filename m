Return-Path: <SRS0=UfqE=T4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 49345C04E84
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 22:00:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0B103208CB
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 22:00:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="UZzU4SeJ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0B103208CB
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7CC8C6B028F; Tue, 28 May 2019 18:00:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 756546B0290; Tue, 28 May 2019 18:00:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5F7346B0291; Tue, 28 May 2019 18:00:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 243A56B028F
	for <linux-mm@kvack.org>; Tue, 28 May 2019 18:00:33 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id c3so60087plr.16
        for <linux-mm@kvack.org>; Tue, 28 May 2019 15:00:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=Zz3efGRJMkCi9u1FMXnDOgSGtU0NK8c6CTTxYaLRlUk=;
        b=LKEganydbPdrBLqikOF5Ka7mvCB3sti/Vx25i2/YVQLnMgmvXgzqvz0Ogm4Ju4wKXV
         4uoVrEfZJQK9EyvLU+LbN+ViDMGJQxyDXKOx75Y4kQ4Q3pTdsLGTEQd5g18ILN3aRZmv
         xqrXHJeIA0DvwvYVF5LeLiQTOksFtXcnvOXMY6qwWEFen56dbdhGLAwLnQFQdqmFuTAP
         mP9x8Sp/OMNS6zM8d/eiFL/5O/6OmuxE34UXOrlar9b1NKRoA8VW83HbKyNydXkt0nNM
         6p9D9lhAAfM2g3LVhPeMZlBvL35VWyYisO+mQKkpsz1BQCL3Dx3so+4HwP+VOjo7sT9U
         qw4w==
X-Gm-Message-State: APjAAAV25n1OSM5egjdaya8Zu4m5KVMN34nPCF0BGmFZh1BvVBOD6e81
	u/RbgpYhpfFf+vJ3EzbPs2DTuLh75kRDvLl5HAHHZeg8EKa62limS2tK3qrMlOyW59HK1Ycmw1K
	Flrutr7vzKLMlx/EXWfI2SlAFMn0WDijcxu8cw/lXbz/Pjfs1+4JP2M7p712vB9/sdg==
X-Received: by 2002:a65:44cb:: with SMTP id g11mr133384190pgs.193.1559080832793;
        Tue, 28 May 2019 15:00:32 -0700 (PDT)
X-Received: by 2002:a65:44cb:: with SMTP id g11mr133384133pgs.193.1559080832133;
        Tue, 28 May 2019 15:00:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559080832; cv=none;
        d=google.com; s=arc-20160816;
        b=RiTDMgqF9EvGE9M5czLAQfc+7DuYfrns0iPhMybHXRJ0UeLx2BNCAiq/bhV/V3+0me
         Xpgf0sHELLerWKDT/qQgUJAoebo5JE16qGnhVNDWXBSQujRFmMR5GVBGgN0UtGlEC+XY
         /Flvmi44DKQ79uX99VcD6B7zn/KrEbgEq4mwwPmuvuP1SLhjXpLkcTt4cGtJd6mgS8ju
         XJ51CYcw0TbvURKqLmZndwbST9D0liv0CEmlqzUTGY9f+Evo4QjK3bgClAXhaA1EHqit
         TRtUdYCB5ABsLx82gKKZrDwZCbWqJ7Pf7qY10fhSUXKE+/6DhUGlVOk8N6P9Kvu2CArP
         SYIA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=Zz3efGRJMkCi9u1FMXnDOgSGtU0NK8c6CTTxYaLRlUk=;
        b=nzEVQZmVnWy1RGD/OTrLjkrLVvt1YgwC86i8Yv3v6w52gDGcyvk+sF+rI8HqQWumxI
         joaEP/g4z85cs9S+RUduD9+cHKXwT2yQ3KOubJSxQMtk2h4VtazmXsFHlXTfSZHgDQwB
         XzY1AScOIlAHGl2h14jSdE7JYr4cA9ugjfZ8VAGq5aowdhrtNqIz21PVlzvyM1Z/nk2r
         kPFmnyiY/eVPiyD8Li4z+XKacArnwSft3WgqiGfYgHEz/ZBhMWTnxrKYBmqLKiubfXib
         vuAcymaA8n+M8A/2Ky/WUnTepkzlTfAGqsuhh5CRi18LgCaZa/VNnYjorQdHhWNzWbfi
         6eyQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=UZzU4SeJ;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x20sor16052384pfm.73.2019.05.28.15.00.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 28 May 2019 15:00:31 -0700 (PDT)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=UZzU4SeJ;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=Zz3efGRJMkCi9u1FMXnDOgSGtU0NK8c6CTTxYaLRlUk=;
        b=UZzU4SeJuNsj1RuhrcyrwW4MS5X4kGC8Ge0T2obb1h/h/CTewhMxNkcfTqUtxV7Ybt
         l9JJno+dbcn1nkV0bH46Xhs3idLMJ4T/k55B/bpWBy9ryQnadZtrxLIcchZWxAkYBAbu
         fbhRFIDfo0/NnrAyNaE2ecYXcWho1QdaI0s/85/A+X7r9AK+tHFK+6aNWEpQy9HQs8Bb
         Li6LBCRaI75me6R17Qp1LTHnXDTPmx2UWK0vuWad9yeDuO3j4ni9wGrrdVO0l8uqGxHW
         8Dsgz6ec6+oz4dmuhnZIKpxAgp6jx6+atPwCgm0WJQwwyg81bncpkILNj4fcw8WBEp02
         G2HA==
X-Google-Smtp-Source: APXvYqzcjXyIC37ZtNb/BvRceiRze2ZuMVZOqei3nfqsf/GzOqhW1pZLQ48briznsQGYnG3llCRAQA==
X-Received: by 2002:aa7:8c1a:: with SMTP id c26mr146120273pfd.25.1559080831650;
        Tue, 28 May 2019 15:00:31 -0700 (PDT)
Received: from localhost ([2620:10d:c091:500::1:77ab])
        by smtp.gmail.com with ESMTPSA id i3sm8919865pfa.175.2019.05.28.15.00.30
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 28 May 2019 15:00:30 -0700 (PDT)
Date: Tue, 28 May 2019 18:00:28 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
To: Roman Gushchin <guro@fb.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, kernel-team@fb.com,
	Michal Hocko <mhocko@kernel.org>, Rik van Riel <riel@surriel.com>,
	Shakeel Butt <shakeelb@google.com>,
	Christoph Lameter <cl@linux.com>,
	Vladimir Davydov <vdavydov.dev@gmail.com>, cgroups@vger.kernel.org,
	Waiman Long <longman@redhat.com>
Subject: Re: [PATCH v5 4/7] mm: unify SLAB and SLUB page accounting
Message-ID: <20190528220028.GB26614@cmpxchg.org>
References: <20190521200735.2603003-1-guro@fb.com>
 <20190521200735.2603003-5-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190521200735.2603003-5-guro@fb.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 21, 2019 at 01:07:32PM -0700, Roman Gushchin wrote:
> Currently the page accounting code is duplicated in SLAB and SLUB
> internals. Let's move it into new (un)charge_slab_page helpers
> in the slab_common.c file. These helpers will be responsible
> for statistics (global and memcg-aware) and memcg charging.
> So they are replacing direct memcg_(un)charge_slab() calls.
> 
> Signed-off-by: Roman Gushchin <guro@fb.com>
> Reviewed-by: Shakeel Butt <shakeelb@google.com>
> Acked-by: Christoph Lameter <cl@linux.com>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

