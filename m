Return-Path: <SRS0=9Pd6=UE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,T_DKIMWL_WL_MED,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 77D1CC28CC5
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 16:31:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 33220206C3
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 16:31:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="fsssAC2j"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 33220206C3
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D2A1D6B026C; Wed,  5 Jun 2019 12:31:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D01366B026D; Wed,  5 Jun 2019 12:31:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BEF3C6B026E; Wed,  5 Jun 2019 12:31:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f200.google.com (mail-yb1-f200.google.com [209.85.219.200])
	by kanga.kvack.org (Postfix) with ESMTP id A56736B026C
	for <linux-mm@kvack.org>; Wed,  5 Jun 2019 12:31:49 -0400 (EDT)
Received: by mail-yb1-f200.google.com with SMTP id y3so14051661ybp.23
        for <linux-mm@kvack.org>; Wed, 05 Jun 2019 09:31:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=Y1OYtud6ynRddkkX+/uoFR8oepImmq49z7SkEsX+oO8=;
        b=an7cZuuvxGFIUIm9iXzfK//NxeMajo4yKO11x1c+yb7xyfWhZfwCJp+sCnKlTTP285
         E8CFc+quCbF6yinhIKUdc8s2yGr7pkeutAhDStI6t7tyPM5PclOQwksz5tPdUyIPXMoa
         uu+LGXxWknIFLLaGhpyC1hKw0yPqTuQXZ4f1/SypcI1En2donywW9zlrujlXQeeGl0mG
         kl122wqow4VX1E6TyqMt9LNBNvN59nlSUBUEnpnp4TrG3L2nOkhTZxh4HlUkOuJCmB3u
         SwYvSznqfClOFnEONW6y4/1j4cGl8axzb/hylFc3wyUVfZdi4NGnzsmCLsjSNOdoxG5C
         Cvog==
X-Gm-Message-State: APjAAAX1a+n+EAPCLMCN36MPXP8QgnjfcU02l0uMQAdh5c/0n3BQwlNy
	oMk36o2dgqp4rs6gLcx13SUwLEX2J0hVf+nmKBoTOCZ2uWp0hXJutGQNBr/4O15eB4ca9drDbiR
	JnJBiF+r9sPkOXRPLRlOEHLTNRYy/zJ3xqheuBaHYlTDEbRQr9Fe/9uaJos4DjWbWTg==
X-Received: by 2002:a25:24f:: with SMTP id 76mr1812456ybc.37.1559752309371;
        Wed, 05 Jun 2019 09:31:49 -0700 (PDT)
X-Received: by 2002:a25:24f:: with SMTP id 76mr1812418ybc.37.1559752308866;
        Wed, 05 Jun 2019 09:31:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559752308; cv=none;
        d=google.com; s=arc-20160816;
        b=i9t+p4q2FyvZvEGSPnfIYR6iAlfFyqjtbvSAsKFAzdh4S/E6aYsToHLx6VbeqWOCbb
         0Wrm67DIGI/729v8WtQhN54E/5jya1GXA4tvvO12K+JbY5hY8qgTLNLYIl7S+9EwOTKo
         yZ2+5/roUzEQTQysujsKhSsrRfQpS++VBFB5LTwaycSSMa2sVP8tDeiYJCQbzmowO0B0
         3pamwpm5h3zaGpF2DiomQVPX4ZnLnDW1QSravw6hwDZqpEVHy9rZWJIDBCD7e+EU0tZV
         TMk0o8q2PNA8kdOrp8gmc0vSkF2Ylr5DRx7UxO9g/ViGnmZjM60+KKa0juAww6o+qmkK
         Biww==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=Y1OYtud6ynRddkkX+/uoFR8oepImmq49z7SkEsX+oO8=;
        b=dUadQWCk5Xrh/Ii54LjU3t1Az4U6QxehJJrECvOjMHLCJ+CeUjQ+9WBu2dsYDTSj4R
         3qSk48IyNlH78ktu0hgb5gg3J7kPhBN9D/Gx2u1XApa6Q49N8WZjbMNqn0CG8+hJKVne
         0uJ2qZXrvuhnkFOBXiNzsn25N5p2OYEuFBYRlvk7frQTWVTQFe6v/orMxcDC6wL/cLqm
         sRqgxP8TOjP3ba218WdtR+QyqLEWMLA4rx2xZXf0+n/DPudNuDHcREtmPDvIqzA/vZFg
         dR1Lict9gjOmYFzl6GJY2oH8qaoh0aRM+XyMKDZRZOAjpb2ePmdTFUr4uHa7DS6RKgrR
         J4Vw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=fsssAC2j;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i4sor5894866ywi.114.2019.06.05.09.31.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 05 Jun 2019 09:31:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=fsssAC2j;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=Y1OYtud6ynRddkkX+/uoFR8oepImmq49z7SkEsX+oO8=;
        b=fsssAC2jxc6N9VdT89cO2W5eloOCThusSzDuCWrmX8rL3p6SjRfShWT9Ro4szdGWzg
         /OwLlE2zuZq1k+E8NKL6Xu/Yc3B7S/ZovUxRpqbTsCHZMOXnmF0hs/zz2rhKakBnZLfC
         WxRN7X8xH5uToK3wDHNPnz1yMhJO9l9jPaHQxME5Hqv5eEaBJCkkjhdrboGh8/CUCNm0
         2W34/DSB6kwzLbcW2AZIaxX8tiZzKXecdR3H9p8CJGlR6wsHg/fnJ0rJFoxBzBmjc5od
         5u3Xyb8WSMOKFxSX+mkDCMW7LSojKD32zNQwJHPpEcsoz//DqbhhpWOo7EN8uXo3Fc5s
         GYEg==
X-Google-Smtp-Source: APXvYqwxp/w9I6RVMYzDSCXTuAeWq+uS/Kgz+ePstY0WG1Azd+0j00estnaPcFznlN81K3EH8wYJ8SzOBLDgFkoIAME=
X-Received: by 2002:a81:4e94:: with SMTP id c142mr7970493ywb.398.1559752308314;
 Wed, 05 Jun 2019 09:31:48 -0700 (PDT)
MIME-Version: 1.0
References: <20190605100630.13293-1-teawaterz@linux.alibaba.com>
In-Reply-To: <20190605100630.13293-1-teawaterz@linux.alibaba.com>
From: Shakeel Butt <shakeelb@google.com>
Date: Wed, 5 Jun 2019 09:31:37 -0700
Message-ID: <CALvZod7w+HaG3NKdeTsk93HjJ=sQ=6wQAYAfi9y5F34-9w6V3Q@mail.gmail.com>
Subject: Re: [PATCH V3 1/2] zpool: Add malloc_support_movable to zpool_driver
To: Hui Zhu <teawaterz@linux.alibaba.com>, Vitaly Wool <vitalywool@gmail.com>
Cc: Dan Streetman <ddstreet@ieee.org>, Minchan Kim <minchan@kernel.org>, ngupta@vflare.org, 
	sergey.senozhatsky.work@gmail.com, Seth Jennings <sjenning@redhat.com>, 
	Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.002942, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 5, 2019 at 3:06 AM Hui Zhu <teawaterz@linux.alibaba.com> wrote:
>
> As a zpool_driver, zsmalloc can allocate movable memory because it
> support migate pages.
> But zbud and z3fold cannot allocate movable memory.
>

Cc: Vitaly

It seems like z3fold does support page migration but z3fold's malloc
is rejecting __GFP_HIGHMEM. Vitaly, is there a reason to keep
rejecting __GFP_HIGHMEM after 1f862989b04a ("mm/z3fold.c: support page
migration").

thanks,
Shakeel

