Return-Path: <SRS0=t1E5=WD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0E70EC32751
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 19:17:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BC43D2229C
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 19:17:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=linux-foundation.org header.i=@linux-foundation.org header.b="QFLKrC5v"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BC43D2229C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 53A7E6B0006; Wed,  7 Aug 2019 15:17:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4C5866B0007; Wed,  7 Aug 2019 15:17:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 38C1E6B0008; Wed,  7 Aug 2019 15:17:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f69.google.com (mail-lf1-f69.google.com [209.85.167.69])
	by kanga.kvack.org (Postfix) with ESMTP id C7B956B0006
	for <linux-mm@kvack.org>; Wed,  7 Aug 2019 15:17:14 -0400 (EDT)
Received: by mail-lf1-f69.google.com with SMTP id w17so10942903lff.15
        for <linux-mm@kvack.org>; Wed, 07 Aug 2019 12:17:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=IMxqo/U0nw6DmpEA9S3YJIdfMVgNoxeRFMQ95NzIcMY=;
        b=MW2ia+KIWblrt52zIo6EcPpOl5l1SORZEx4c3FM0pcby6lkFObq+KaOAuGDeI/WUeT
         4SutIL3DgETJme8RhI6hotuDzfJeNVsO+VUJ6c0U+mCwmJsTmEuCsy3pxUqtidCv4OEr
         6RUGHt4G3DTv+VS+LpvzP4EYoHDLKVDrz/Ln5Wm7zQwUPgazeWAERIBtr+0PdoBFnpOA
         zr8FunTRikVP1VhDAtptI9ixKkCTHkZAGYHWrtQX3DLGcZslZ9UYM6+4bE3DYN4Igs1x
         t/TSmGkna+wLRyQR+tbcAIiMc9on7qlwOKwZ+sgRVAosQcMQt9GAda2JwF4yi/nt+x+s
         ZuBQ==
X-Gm-Message-State: APjAAAWZ67wslkM1gU5TVxfxwq0r8BpPXd4O8sjUvXIOYxagoGDGhidF
	LN/ccIStISGtHJXC0fWjjFmlmWDnQZ7RtDJ0sY41kounmbpawSCpBlKcMnLQOMlM+TwBcESlUfY
	ijlaOUkMHXxdPGE4+nyAPWZFhjrYFRva70gZJOSj3w4DaeauBBTVyombla05Onn7Oeg==
X-Received: by 2002:a2e:98f:: with SMTP id 137mr5459564ljj.232.1565205434113;
        Wed, 07 Aug 2019 12:17:14 -0700 (PDT)
X-Received: by 2002:a2e:98f:: with SMTP id 137mr5459542ljj.232.1565205433288;
        Wed, 07 Aug 2019 12:17:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565205433; cv=none;
        d=google.com; s=arc-20160816;
        b=TCP0Z5/zqh1i/ajHaWwKrSd4LaWDTm95OCvNrsUL0dutFukDuyQ3JZq1Prr9hoGfSd
         2riqfdv5uVgmfNjt8mM47J3e8UYp0T9Y3rKcSx97sltykugMT0HMeiFfuIWQelmc5kmR
         SABcHPhn94WjE8Si9KwEELrD/ZNLmw9/cJMYr9wi1SgLEEIISIqzx5Gp9d4d4mv1nyvY
         dStr8Z+v4aE2XQGzroxcN5eI9PWIyZJUHjAYhoYNPrhxl+rfq8mzW9EvYlw25up3DceW
         PovBlmm8q6QfaWPzx2E7VYvxm2m0UsaV96jOewL7aTpmL4rvH8xTgZclJ0EPVq+0LJCY
         eARQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=IMxqo/U0nw6DmpEA9S3YJIdfMVgNoxeRFMQ95NzIcMY=;
        b=V883cUGBu3I6TU9jZ8qc/5FKiJ9jSDhsjaWqwEp/HdITjx1P6Nn3ILtbILNz9sw1yz
         ugGBmi8UhdYT0n1wyuAbJmtDewNdcLxofVY1GhbpBHr2pWq2gyHPIfbc6bNs6ehgHh+r
         ax8OB34pLQur6V10nCKwx7c51wxB9XwPkXl+dwxbplOAx0VPb2Fa3LDJWG3ScvyU3nGu
         9OUyVC0as9NDMp4xJwKHIb/BbPb9o+ZnF157Fjgy6oCe8AxqBbBvcKeahdqk2yWDltwR
         xiMiGy/9JN/0Mu8NVtgl5wQthv2A9do27slTz9R7aBij3kMmDWBFnCgC5dvF/CE/Xexe
         jCfA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b=QFLKrC5v;
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x21sor24627407lfq.32.2019.08.07.12.17.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 07 Aug 2019 12:17:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b=QFLKrC5v;
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linux-foundation.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=IMxqo/U0nw6DmpEA9S3YJIdfMVgNoxeRFMQ95NzIcMY=;
        b=QFLKrC5vkJW5FKE/Mdgg0Cdcp3sO/GQpVGltLV5Ca6yR5XaMmMWdxOVi8385PLpByn
         E/O5WhMsHLvDBDcmUFvSEBG08jBSq6LjIkgwV1Bf+j33ocpUvmt4+vvljJI1lHX8UUqK
         0knAjZ61PyQ7e0qOT6M/ZBN+bdOB8TBJJv+4A=
X-Google-Smtp-Source: APXvYqxEq82zRJ/lF4SgZmv1YrF2US2ipB3kzqBCDA6cKIZMTOelkr18jJYjheEpXlf3JrIfw34tPQ==
X-Received: by 2002:a19:6041:: with SMTP id p1mr6831724lfk.6.1565205432266;
        Wed, 07 Aug 2019 12:17:12 -0700 (PDT)
Received: from mail-lj1-f179.google.com (mail-lj1-f179.google.com. [209.85.208.179])
        by smtp.gmail.com with ESMTPSA id h19sm2977969lfc.93.2019.08.07.12.17.09
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Aug 2019 12:17:09 -0700 (PDT)
Received: by mail-lj1-f179.google.com with SMTP id v18so86470604ljh.6
        for <linux-mm@kvack.org>; Wed, 07 Aug 2019 12:17:09 -0700 (PDT)
X-Received: by 2002:a2e:9b83:: with SMTP id z3mr5553524lji.84.1565205428980;
 Wed, 07 Aug 2019 12:17:08 -0700 (PDT)
MIME-Version: 1.0
References: <CAPM=9tzJQ+26n_Df1eBPG1A=tXf4xNuVEjbG3aZj-aqYQ9nnAg@mail.gmail.com>
 <CAPM=9twvwhm318btWy_WkQxOcpRCzjpok52R8zPQxQrnQ8QzwQ@mail.gmail.com>
 <CAHk-=wjC3VX5hSeGRA1SCLjT+hewPbbG4vSJPFK7iy26z4QAyw@mail.gmail.com>
 <CAHk-=wiD6a189CXj-ugRzCxA9r1+siSCA0eP_eoZ_bk_bLTRMw@mail.gmail.com>
 <48890b55-afc5-ced8-5913-5a755ce6c1ab@shipmail.org> <CAHk-=whwcMLwcQZTmWgCnSn=LHpQG+EBbWevJEj5YTKMiE_-oQ@mail.gmail.com>
 <CAHk-=wghASUU7QmoibQK7XS09na7rDRrjSrWPwkGz=qLnGp_Xw@mail.gmail.com>
 <20190806073831.GA26668@infradead.org> <CAHk-=wi7L0MDG7DY39Hx6v8jUMSq3ZCE3QTnKKirba_8KAFNyw@mail.gmail.com>
 <20190806190937.GD30179@bombadil.infradead.org> <20190807064000.GC6002@infradead.org>
In-Reply-To: <20190807064000.GC6002@infradead.org>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 7 Aug 2019 12:16:52 -0700
X-Gmail-Original-Message-ID: <CAHk-=wgUO5hWJmMT7r8aCzP7DOkg9ADkv6AzZ=SrKLOoKxzD_g@mail.gmail.com>
Message-ID: <CAHk-=wgUO5hWJmMT7r8aCzP7DOkg9ADkv6AzZ=SrKLOoKxzD_g@mail.gmail.com>
Subject: Re: drm pull for v5.3-rc1
To: Christoph Hellwig <hch@infradead.org>
Cc: Matthew Wilcox <willy@infradead.org>, =?UTF-8?Q?Thomas_Hellstr=C3=B6m_=28VMware=29?= <thomas@shipmail.org>, 
	Dave Airlie <airlied@gmail.com>, Thomas Hellstrom <thellstrom@vmware.com>, 
	Daniel Vetter <daniel.vetter@ffwll.ch>, LKML <linux-kernel@vger.kernel.org>, 
	dri-devel <dri-devel@lists.freedesktop.org>, Jerome Glisse <jglisse@redhat.com>, 
	Jason Gunthorpe <jgg@mellanox.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Steven Price <steven.price@arm.com>, Linux-MM <linux-mm@kvack.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 6, 2019 at 11:40 PM Christoph Hellwig <hch@infradead.org> wrote:
>
> I'm not an all that huge fan of super magic macro loops.  But in this
> case I don't see how it could even work, as we get special callbacks
> for huge pages and holes, and people are trying to add a few more ops
> as well.

Yeah, in this case we definitely don't want to make some magic loop walker.

Loops are certainly simpler than callbacks for most cases (and often
faster because you don't have indirect calls which now are getting
quite expensive), but the walker code really does end up having tons
of different cases that you'd have to handle with magic complex
conditionals or switch statements instead.

So the "walk over range using this set of callbacks" is generally the
right interface. If there is some particular case that might be very
simple and the callback model is expensive due to indirect calls for
each page, then such a case should probably use the normal page
walking loops (that we *used* to have everywhere - the "walk_range()"
interface is the "new" model for all the random odd special cases).

                Linus

