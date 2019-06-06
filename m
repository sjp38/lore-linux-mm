Return-Path: <SRS0=utKX=UF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0F552C28CC6
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 00:24:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CABF920717
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 00:24:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="VhicxqzH"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CABF920717
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5ABE06B026B; Wed,  5 Jun 2019 20:24:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 55C706B026C; Wed,  5 Jun 2019 20:24:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 473D16B026E; Wed,  5 Jun 2019 20:24:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f199.google.com (mail-lj1-f199.google.com [209.85.208.199])
	by kanga.kvack.org (Postfix) with ESMTP id D882E6B026B
	for <linux-mm@kvack.org>; Wed,  5 Jun 2019 20:24:36 -0400 (EDT)
Received: by mail-lj1-f199.google.com with SMTP id c25so119075ljb.3
        for <linux-mm@kvack.org>; Wed, 05 Jun 2019 17:24:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=N1TbV63VvRheR5OgJaz2rfajmrYQQlbC4P7mXaYbfMg=;
        b=Kb3y4vDh8z7KLNKOt6PmQIS009yD0eQ/BWklPfFhlHIz6cpCNpHhW1GDjXioLBhIOB
         RbYxOWKjHjT5fpE2UoAcBKEzTGq2ahfnkdAkAamHpEND/vhWig+uSlmAHNYRndG+AZXp
         8ST3MqbSw467VyLVRkEnD8wkHVNVB4NYbK234msZ9Rjkh3k2kzWrP6+mLYxZnvIbi8+P
         H6w8RRxIPWUvTWkmIQaZ9Ax7+eeeunt19wYUVnJQiIyLBO3KxXsIWxqX66uEMppq7aX3
         Z7EkeNcGAVJmoBpTf/cEUs57EngoWGENqRho2tF/p2096vcfbQH3QAUprRp5snha58B1
         kngg==
X-Gm-Message-State: APjAAAWYMFEvXQfIJkbjsb73SWFdp51dWNc4xncPcbdQ8lpAQgIGvyjn
	kPINmObsq6IIyDT/W5DcP7oYK8ArNH1YzI365Yow3maYHjLvlPHD7hA4Wow60u0eCvRKWMWrczN
	+UA+w6HhBvEV7IyFYXdfV7S3FG9JVAoot7m/gewUfwY1ObrVTPnSnj+jmiPWB9XRpyA==
X-Received: by 2002:a19:5515:: with SMTP id n21mr15217140lfe.26.1559780675910;
        Wed, 05 Jun 2019 17:24:35 -0700 (PDT)
X-Received: by 2002:a19:5515:: with SMTP id n21mr15217114lfe.26.1559780674908;
        Wed, 05 Jun 2019 17:24:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559780674; cv=none;
        d=google.com; s=arc-20160816;
        b=eXYJA5B8n46uWy7H4k6s6Ve5zd04om+o3EUHZiqx0lTtZaBym6MNPcrpJtYiA+rNvk
         cGKPAEdbLHjFdB7ZgSW8QVK2MR5hSSNFeWrf+wgmtf4k7dwJVcGTnpcDhwu6NKAri89b
         2Na3QmwBicTM0V1b9yHP47znWx5wUdg4czrggws53tr0BWrERJwY1YdnVuYjqK5JTR8O
         bPzy52bJ6ODinkXdVimDGHyb4gEscHirYwJoFfbbjqpmRK+ZkMcFTG53LYVoAScz1RVS
         L3D4Tm0G3uuwii8JL8zt6OZ/MeyR1cIDqj6tQtMik3T92Wh8g9Y0J4LTAQZUH6M/EPQ6
         XNog==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=N1TbV63VvRheR5OgJaz2rfajmrYQQlbC4P7mXaYbfMg=;
        b=Ad3Dsq1K4oM84pggg+LRMLuzxC63RSjY1fEz2Otx90RcB2WXsspbHC4mwGK+c+16EM
         8XL14ciQkt3FY+t9XyyJ4zfgXiM3W5mKg3QMdsV2Ole7OsitV5EW68ysMlS/JCt36E2p
         YP8hBM9AP0ikFxv5D9T2TCyp9pIYNf5FQGwGDn4cPPva9PwrKxdulHScjSPLljT9wYkp
         xjy3sOPQsK99exJ3ATwvrNaLxwqO9GVxXq9UJ0LEVej6BtwOyxlCFwifXe+bvEWYii1M
         W2h8A8Z9qsi9VXjW9d8SmJmUueYHvGEE6jckYFgOK/QhmG9vHV3GjSNOTePbfcX34+Lg
         9Ocg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=VhicxqzH;
       spf=pass (google.com: domain of vitalywool@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=vitalywool@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n1sor40887lfg.31.2019.06.05.17.24.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 05 Jun 2019 17:24:34 -0700 (PDT)
Received-SPF: pass (google.com: domain of vitalywool@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=VhicxqzH;
       spf=pass (google.com: domain of vitalywool@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=vitalywool@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=N1TbV63VvRheR5OgJaz2rfajmrYQQlbC4P7mXaYbfMg=;
        b=VhicxqzHgalolOYgzImxTAg2DnXaE9sizZjeFz2laU6Mhcz0uaO5DMJBRj0nNsCpVX
         CejYO6l2zddgkF7VyKKkgrKWcFgiCN3CQHo69ZqkTYgfXK+O5PpPERricJEYTVZesK88
         bW7myqV+mjCeVS1lufYXhgsjGA96xAYSoFhdegPcOIK7vEXein990h+BhIwQEnGJP/+F
         ie4Fv9bHJZLPWtVDw+pT9atpxKRxkJsBibNXoyZvkli6btodCReDjs4DALS6lervjSKV
         CX9uJsL83jO5wrfYxiIJuH6nWclhy5a4NLiSW/EykeAow2dB0LuUC70JGuYPJs288yZf
         IiWQ==
X-Google-Smtp-Source: APXvYqyAK15issZTBtgo/8FWyF3L+MOFJjpUHKt/wl5sPRIaIXeUr7b8lgPa0a4QzGVoi+lctioiYGIFHcmRejmD+zg=
X-Received: by 2002:ac2:43bb:: with SMTP id t27mr2134686lfl.187.1559780673815;
 Wed, 05 Jun 2019 17:24:33 -0700 (PDT)
MIME-Version: 1.0
References: <20190605100630.13293-1-teawaterz@linux.alibaba.com> <CALvZod7w+HaG3NKdeTsk93HjJ=sQ=6wQAYAfi9y5F34-9w6V3Q@mail.gmail.com>
In-Reply-To: <CALvZod7w+HaG3NKdeTsk93HjJ=sQ=6wQAYAfi9y5F34-9w6V3Q@mail.gmail.com>
From: Vitaly Wool <vitalywool@gmail.com>
Date: Thu, 6 Jun 2019 02:23:56 +0200
Message-ID: <CAMJBoFN67ByX7ZBu_GDv_h1oMWD6SU+_nj8fmYWo6Qzdrn9JuQ@mail.gmail.com>
Subject: Re: [PATCH V3 1/2] zpool: Add malloc_support_movable to zpool_driver
To: Shakeel Butt <shakeelb@google.com>
Cc: Hui Zhu <teawaterz@linux.alibaba.com>, Dan Streetman <ddstreet@ieee.org>, 
	Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, 
	Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Seth Jennings <sjenning@redhat.com>, 
	Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Shakeel,

On Wed, Jun 5, 2019 at 6:31 PM Shakeel Butt <shakeelb@google.com> wrote:
>
> On Wed, Jun 5, 2019 at 3:06 AM Hui Zhu <teawaterz@linux.alibaba.com> wrote:
> >
> > As a zpool_driver, zsmalloc can allocate movable memory because it
> > support migate pages.
> > But zbud and z3fold cannot allocate movable memory.
> >
>
> Cc: Vitaly

thanks for looping me in :)

> It seems like z3fold does support page migration but z3fold's malloc
> is rejecting __GFP_HIGHMEM. Vitaly, is there a reason to keep
> rejecting __GFP_HIGHMEM after 1f862989b04a ("mm/z3fold.c: support page
> migration").

No; I don't think I see a reason to keep that part. You are very
welcome to submit a patch, or otherwise I can do it when I'm done with
the patches that are already in the pipeline.

Thanks,
   Vitaly

