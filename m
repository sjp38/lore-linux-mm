Return-Path: <SRS0=f00L=TH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 203F5C04AAB
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 17:25:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C95C0206A3
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 17:25:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="UZLkwKDW"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C95C0206A3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3D1A76B0005; Tue,  7 May 2019 13:25:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 35AAB6B0006; Tue,  7 May 2019 13:25:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2492D6B0007; Tue,  7 May 2019 13:25:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f199.google.com (mail-it1-f199.google.com [209.85.166.199])
	by kanga.kvack.org (Postfix) with ESMTP id 05F656B0005
	for <linux-mm@kvack.org>; Tue,  7 May 2019 13:25:53 -0400 (EDT)
Received: by mail-it1-f199.google.com with SMTP id f196so14957916itf.1
        for <linux-mm@kvack.org>; Tue, 07 May 2019 10:25:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=WNM91LsYQ4Jk8pRE5BfQ7giBI1LrDmHfewasLQMdhYY=;
        b=lf4BINuejp7qP78KSOXpl9jlMvl55iLJVIbYI1zUe7fmVdzRtuEdXOy/0ClNeaYjDj
         AD2EyauJBdCe+yv+XlDB5dctUTm6Tak3PkQ2cjdkYDV6Aj/zYVLauBKLQe/j/R41925B
         lpUNbouVPYcUNY18xs2q6G4FeJWnNrElk+RF6GVkPrDPh2Hm4Zt662DaLKTukSt4neY1
         QAafqjB/XYGgPTYKH3Y3w+qfJz2bFF6+BOx9k2Tett6hXp2ghcyVLRcDoQBM1htUUOW+
         RfAI4Ttwpis+9idH7gGmtT6ka/MXmGCwKJyWl+EGUDZbVaIO6IXCGt2gIafY2HV5+Oc2
         mjjA==
X-Gm-Message-State: APjAAAWC2JoO/F/4M0HUk4nzo752KCbByhwYsIcv6ir1Lr3vnEvR559r
	SK9DrqNpFg53PODsoKbYGVCEJwQX/4jga/H3VPkhRz4pHk0BXLa+sOkrejg1ZCmpKLspBj0A8qP
	iOwDuz69qTObN3vqz0ITdhjeHFWZ2HV5dlCAsNRfafIKtCc+LtjjgNEwKLziiYUrpoQ==
X-Received: by 2002:a24:610b:: with SMTP id s11mr21077549itc.156.1557249952717;
        Tue, 07 May 2019 10:25:52 -0700 (PDT)
X-Received: by 2002:a24:610b:: with SMTP id s11mr21077509itc.156.1557249951924;
        Tue, 07 May 2019 10:25:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557249951; cv=none;
        d=google.com; s=arc-20160816;
        b=tKo4q3d5Fa/RJxqSxraHgEGgpibdOEkGzu7lUb2HrsfULOEAticTWjvIQtTfFD/OSJ
         4GsiSdUkYwY6QKuFb6VGYGehC0C5GjStl7hEiGAJ7C2SRAvrxQuFEcjYqeCdO/17uh/X
         IuGNRgFK6AKNNix/iGvVoNc+hX+RzRQ/hUEFliTqRLsGdj3aiuj8k4N7ggqJij0+fOP1
         7r7y9aZcO9yhFtPcL6+zcgwv21j7rGGMR6AoX4HZGmtAVf0+wCbRYl2ZBEfSGBSYmfzn
         h8je1pmdK/QwLVHGldcvaRkTfdvrU1jMVDbI4PBE9T0F1PQLpvx4qsIC6XbI+N00X1ej
         ASqQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=WNM91LsYQ4Jk8pRE5BfQ7giBI1LrDmHfewasLQMdhYY=;
        b=IHHEntMh5afHUINuT3SHe7/KhniWEm1OStGBXG4JKsTrawrXzlmnhvxZT0AkxL7Ltv
         izknvX5X/87gYvblP61Jg06KJ5svPPU3thAv3947XhprP87M00JbDaSdJagi2sTrgqX2
         pA+bieQKrC43LrxGRwDnETgaTWwmYtXaKXCUkkvQk7fSs3riR0vUFVLCI6wXP4VrFcy7
         dD3D+It1sNO5KIG69Khb1MfsCwpeZw7bEc5MJSzILwf5lO0s9ta4xp2DCv57NEfov/6h
         KtQc1vf/FBrh7zqrIEnm+tRbaQyemrQoKqoU/m+mGtqO3MJf2opBHCGO5M01tptWil8A
         9s5Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=UZLkwKDW;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q12sor7463548ioh.19.2019.05.07.10.25.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 07 May 2019 10:25:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=UZLkwKDW;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=WNM91LsYQ4Jk8pRE5BfQ7giBI1LrDmHfewasLQMdhYY=;
        b=UZLkwKDWZ/r8H5KY8fg/33/rzkBhC8rortcsHyxbj/uQouwgh3b3DDS9g6ykPyPpra
         aDFzXyc8EsTaiUrLSUywp2Yuj8/azQ3kmxsbvf9f9iz42l/apPGiv/stQXD171MNZbYn
         aRXTbtthM9+AmPyJkKyuAPS+nYUn2CxFBzMWFfHOlfh5rZShAl0z41ZRJvNYhzQ0JQ7E
         0PCQV+Un+PumHBZJ97r58/YpwZoXwUAMeMes+m0CWSTL0lPWYuLDXvxyxMScNSDkh9fh
         hr44kb4EK8811jwNm9b66Xz40Gv0a/IVVN4xSeKvHy7gCqQVZG9izL1k/slGn4/i7p4h
         frFQ==
X-Google-Smtp-Source: APXvYqw+NPyrJL89GMAhzIt3t6zWXwhaYY9Oqkc/vWNxkqLzU5VEltblOOYuAi3nSrx7h8Vv8xifBDFUb2XsSSe0CzY=
X-Received: by 2002:a6b:6e0f:: with SMTP id d15mr794901ioh.116.1557249951555;
 Tue, 07 May 2019 10:25:51 -0700 (PDT)
MIME-Version: 1.0
References: <20190507053826.31622-1-sashal@kernel.org> <20190507053826.31622-71-sashal@kernel.org>
In-Reply-To: <20190507053826.31622-71-sashal@kernel.org>
From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Tue, 7 May 2019 10:25:40 -0700
Message-ID: <CAKgT0Uf89zkZDU5d5GO-i4B4igASXWqUioWCpoTsY92V4gEWjg@mail.gmail.com>
Subject: Re: [PATCH AUTOSEL 4.14 71/95] Revert "mm, memory_hotplug: initialize
 struct pages for the full memory section"
To: Sasha Levin <sashal@kernel.org>
Cc: LKML <linux-kernel@vger.kernel.org>, stable@vger.kernel.org, 
	Michal Hocko <mhocko@suse.com>, Robert Shteynfeld <robert.shteynfeld@gmail.com>, stable@kernel.org, 
	Linus Torvalds <torvalds@linux-foundation.org>, Sasha Levin <alexander.levin@microsoft.com>, 
	linux-mm <linux-mm@kvack.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, May 6, 2019 at 10:40 PM Sasha Levin <sashal@kernel.org> wrote:
>
> From: Michal Hocko <mhocko@suse.com>
>
> [ Upstream commit 4aa9fc2a435abe95a1e8d7f8c7b3d6356514b37a ]
>
> This reverts commit 2830bf6f05fb3e05bc4743274b806c821807a684.
>
> The underlying assumption that one sparse section belongs into a single
> numa node doesn't hold really. Robert Shteynfeld has reported a boot
> failure. The boot log was not captured but his memory layout is as
> follows:
>
>   Early memory node ranges
>     node   1: [mem 0x0000000000001000-0x0000000000090fff]
>     node   1: [mem 0x0000000000100000-0x00000000dbdf8fff]
>     node   1: [mem 0x0000000100000000-0x0000001423ffffff]
>     node   0: [mem 0x0000001424000000-0x0000002023ffffff]
>
> This means that node0 starts in the middle of a memory section which is
> also in node1.  memmap_init_zone tries to initialize padding of a
> section even when it is outside of the given pfn range because there are
> code paths (e.g.  memory hotplug) which assume that the full worth of
> memory section is always initialized.
>
> In this particular case, though, such a range is already intialized and
> most likely already managed by the page allocator.  Scribbling over
> those pages corrupts the internal state and likely blows up when any of
> those pages gets used.
>
> Reported-by: Robert Shteynfeld <robert.shteynfeld@gmail.com>
> Fixes: 2830bf6f05fb ("mm, memory_hotplug: initialize struct pages for the full memory section")
> Cc: stable@kernel.org
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
> Signed-off-by: Sasha Levin <alexander.levin@microsoft.com>
> ---
>  mm/page_alloc.c | 12 ------------
>  1 file changed, 12 deletions(-)

So it looks like you already had the revert of the earlier patch I
pointed out enqueued as well. So you can probably at a minimum just
drop this patch and the earlier patch that this reverts.

Thanks.

- Alex

