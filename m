Return-Path: <SRS0=T9E7=U7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D2A34C06513
	for <linux-mm@archiver.kernel.org>; Tue,  2 Jul 2019 11:52:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 72B7C2173E
	for <linux-mm@archiver.kernel.org>; Tue,  2 Jul 2019 11:52:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="TwplpaWz"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 72B7C2173E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C12336B0003; Tue,  2 Jul 2019 07:52:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B9BC18E0003; Tue,  2 Jul 2019 07:52:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A64AE8E0001; Tue,  2 Jul 2019 07:52:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7AFF66B0003
	for <linux-mm@kvack.org>; Tue,  2 Jul 2019 07:52:12 -0400 (EDT)
Received: by mail-ot1-f70.google.com with SMTP id 20so6975676otv.1
        for <linux-mm@kvack.org>; Tue, 02 Jul 2019 04:52:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=fUAgbAMqKNku6wAR/i42DQOgnry+BJIVEUNtTrD/bls=;
        b=csGUQG5FbKgtL/cgc9zVLarfTZOvT7VF/Dl1Rqnl/omt7yvh5QB2O1tBuxMv2ibGmO
         IcvVU2WJp00uaJiyla5driO7NL2orVVxXhNlpo5WtCxt8PUa2hS/J+S/3kop7tuq2NbX
         d3VYgWoMLRSN8eAHL22MlVq6K7xHCljOHSmkHAh8xdiebg3erg5/5qB6Zyz/X0oMODwG
         Jffre3lhKUU5wE6RWJaYwiBrUCjtu7B/rLYvbbm24xPPDy/qYW7623NBkZbpGZ2wFr+A
         L+A+Pm8bjrokkmdFUR+jwjTjyoTHX/dQNdBUPRmmv0tkZENLScjEJpUDAIlc+pIGUlAQ
         iD5w==
X-Gm-Message-State: APjAAAVp1ABJyjNDc2T3IArYyPNeeEb4ShkRNN7Mr+B7qTh6ZQALCfQW
	TW7RmZLrVU1svtB1tGQrK2epzqunw7O3NMb8LrKi45Ye23ZzYkRK1geAlQ5ODRvYJ2OC+pKMchQ
	kap9x+/RDrscwlxTnhfxrHXJGHi8ZT9y+zgEiVW6Yw0r4gVFLhAZiGeYAtJGxw8UXIw==
X-Received: by 2002:a9d:73cb:: with SMTP id m11mr22529104otk.276.1562068332061;
        Tue, 02 Jul 2019 04:52:12 -0700 (PDT)
X-Received: by 2002:a9d:73cb:: with SMTP id m11mr22529074otk.276.1562068331384;
        Tue, 02 Jul 2019 04:52:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562068331; cv=none;
        d=google.com; s=arc-20160816;
        b=Q+tYfPGXgsmc/mJ2BS/1KksOmGSPT39UTkYrd07+8WmVzowy0U7m5tifPRUWC6YAlu
         Tb+EG1sugsmDi6/R6vRTt6z6NLG3/eajdslJPFAakP4tXXRGUBLLoLThDkyB3BwMdZ96
         gWOiK4ubO10BM+MwVgMMzwMlwJksOePiqUVUFKLc9KCKrugftNSf2ilPQO3qYDReb/Zw
         OmxX5QHni+CvP8ZX5iuiGSkvDxEJvr1x5Gx5x/gWHqoyfZXeZ63MjGfDBpBerg2W701i
         BPhcpov78lnS8D2rW1RMqcrbRMsO5v5UzondV1T+cxuVVnBwyHH4Or4JZijy26aWnKDe
         6IsQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=fUAgbAMqKNku6wAR/i42DQOgnry+BJIVEUNtTrD/bls=;
        b=AL5LLPxYIBaeG6oEbjJWlWDdHnlSgeMRgkgrqACtZZomUaR9RUahlcqJOqOYCmcjL0
         XVyq0ZjGCaewpW9lAaviyxqVYruk2Uj7RH7NIu+bGb3NP4dzCT5BtShsGka7oulDYBN/
         +4wHzJcTeO2xkWbVVfUwHh/XW1l0gZmxGfyUfMBqo4eYdnP2XH2vxxo7J2EHFVt4sLjM
         eMmIjtuRyBcBboT4fG1vV64ts2TxK1EOLegyPMx1/9wETwOXpZvwTocuqJ3KTVxHCjf6
         Vy3pt2yMWMm4m5TiKb2nZ2yfEZVR1lKC5pIcETQZfypqUuLSBcV5PIuKvpeDXa65z6G4
         eoMg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=TwplpaWz;
       spf=pass (google.com: domain of lpf.vector@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=lpf.vector@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 40sor7035552otj.175.2019.07.02.04.52.11
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 02 Jul 2019 04:52:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of lpf.vector@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=TwplpaWz;
       spf=pass (google.com: domain of lpf.vector@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=lpf.vector@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=fUAgbAMqKNku6wAR/i42DQOgnry+BJIVEUNtTrD/bls=;
        b=TwplpaWzSJwwXJl/kevHVibUDcoZoN47NijeFdvawHyiqOjNpW3kyU8/UWXglV+VqL
         hiRnZ+dndcrYdDnKvMQhQNwlOkVtROB+ER9CLEXaOLg6NxsRmwHCN7L/urW2rmnx6lgG
         2x764ztR3E/QoskDHkEK01aQrf1eJ+7Dz4FJLFUdJXSp+a6/gTDT6xbV5jmWyW3QNYh5
         eW3/JV/e0PwYcfCRMDGR7Kxu6PJ8NuhdDZ08fzKCTqjIO73e0GJWY7RqCwBWKVf4OhgW
         rbGUkWqIvgoF+jjDUjtA1fy2kcPQ+JJAZ3K7SdyLMRikwFlGiV/v3GF4zy1VrWN4yZcm
         HY3A==
X-Google-Smtp-Source: APXvYqyVo5SJxrDdlm0tkmwJLz8dVGc7228Y1I8ugG05SWKDquXCGm4PbTVv7Y6kqpcpNDqZRAG74O8rxuDWKX/z0o0=
X-Received: by 2002:a05:6830:2098:: with SMTP id y24mr1506012otq.173.1562068331167;
 Tue, 02 Jul 2019 04:52:11 -0700 (PDT)
MIME-Version: 1.0
References: <20190630075650.8516-1-lpf.vector@gmail.com> <20190701092037.GL6376@dhcp22.suse.cz>
In-Reply-To: <20190701092037.GL6376@dhcp22.suse.cz>
From: oddtux <lpf.vector@gmail.com>
Date: Tue, 2 Jul 2019 19:51:59 +0800
Message-ID: <CAD7_sbHzn4PTOvEYw7FVUapQ9xVH4VU8X3WUarrAs1rcvnQFEQ@mail.gmail.com>
Subject: Re: [PATCH 0/5] mm/vmalloc.c: improve readability and rewrite vmap_area
To: Michal Hocko <mhocko@kernel.org>
Cc: akpm@linux-foundation.org, peterz@infradead.org, urezki@gmail.com, 
	rpenyaev@suse.de, guro@fb.com, aryabinin@virtuozzo.com, rppt@linux.ibm.com, 
	mingo@kernel.org, rick.p.edgecombe@intel.com, linux-mm@kvack.org, 
	linux-kernel@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Michal Hocko <mhocko@kernel.org> =E4=BA=8E2019=E5=B9=B47=E6=9C=881=E6=97=A5=
=E5=91=A8=E4=B8=80 =E4=B8=8B=E5=8D=885:20=E5=86=99=E9=81=93=EF=BC=9A
>
> On Sun 30-06-19 15:56:45, Pengfei Li wrote:
> > Hi,
> >
> > This series of patches is to reduce the size of struct vmap_area.
> >
> > Since the members of struct vmap_area are not being used at the same ti=
me,
> > it is possible to reduce its size by placing several members that are n=
ot
> > used at the same time in a union.
> >
> > The first 4 patches did some preparatory work for this and improved
> > readability.
> >
> > The fifth patch is the main patch, it did the work of rewriting vmap_ar=
ea.
> >
> > More details can be obtained from the commit message.
>
> None of the commit messages talk about the motivation. Why do we want to
> add quite some code to achieve this? How much do we save? This all
> should be a part of the cover letter.
>

Hi Michal,

Thank you for your comments.

Sorry for the commit without any test data.
I will add motivation and necessary test data in the next version.

Best regards,

Pengfei

> > Thanks,
> >
> > Pengfei
> >
> > Pengfei Li (5):
> >   mm/vmalloc.c: Introduce a wrapper function of insert_vmap_area()
> >   mm/vmalloc.c: Introduce a wrapper function of
> >     insert_vmap_area_augment()
> >   mm/vmalloc.c: Rename function __find_vmap_area() for readability
> >   mm/vmalloc.c: Modify function merge_or_add_vmap_area() for readabilit=
y
> >   mm/vmalloc.c: Rewrite struct vmap_area to reduce its size
> >
> >  include/linux/vmalloc.h |  28 +++++---
> >  mm/vmalloc.c            | 144 +++++++++++++++++++++++++++-------------
> >  2 files changed, 117 insertions(+), 55 deletions(-)
> >
> > --
> > 2.21.0
>
> --
> Michal Hocko
> SUSE Labs

