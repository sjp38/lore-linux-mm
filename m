Return-Path: <SRS0=luIg=QH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 349CFC282D9
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 12:32:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CDB122087F
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 12:32:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="rm0itLub"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CDB122087F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 35D608E0002; Thu, 31 Jan 2019 07:32:07 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2E0238E0001; Thu, 31 Jan 2019 07:32:07 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1856B8E0002; Thu, 31 Jan 2019 07:32:07 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f199.google.com (mail-lj1-f199.google.com [209.85.208.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9CF1B8E0001
	for <linux-mm@kvack.org>; Thu, 31 Jan 2019 07:32:06 -0500 (EST)
Received: by mail-lj1-f199.google.com with SMTP id k16-v6so537649lji.5
        for <linux-mm@kvack.org>; Thu, 31 Jan 2019 04:32:06 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=MUni9/6Z2lGMVz53wyw6zTg0RWZ4vyfLf6KBzYMBEmg=;
        b=eD5wIcq5SA0x0TJtQOY8vEkVPdlQ8stshwkkrzpqbSJDbmNG7gqb4DqkIXZmL1strX
         bPZXpg7ZeHvk3Vpzt1A3Npyu3YiD+DbIr1XesA3yk+1S/UC4OuURbaB0LOvPpzNaS+/8
         jhUoP7A/0Gt3Do9bxh+W40WUq/laBHo60c9J4r0Czih6WS55gQz+GvvaYYoizYuUndea
         BX0W8A5yEckmi3Djpk8UXU4l8hnbPlOdIigl6GVov53Spq1+co1HmEmOBGw7g0Em21jU
         VgnC6kIh2sxpjf3rKJ5so/EBWTJt4x9aJ+JwOVr3R3cvGm3F/FY73AlSuF4A4GmOcqPH
         mi8g==
X-Gm-Message-State: AJcUukfneHyGLqh8krHCwSDsQPl6xwUY7C64ZJSd5Vny/Ox7TO8tbHfV
	72wrgooQilw6NQ9eT7u/rOkK080ec7PQP/ZRQgJcQh6YROrK3BH8DDiT2Kot5eanbCWkRr0dHQj
	5M7Mp9zNZZANZOAROHqExDH3Tj1wIxGQ4RnmjpWekoMV3vStnF+1Q0sLnm9Uk+r8RNk+QNzBGkI
	b9r5HCEMxSpWpCbQVsZrdcimVuHRTlc4pOkd0kefIz2cHX+N+M1xyyF1i7XTe3+08sitG/cBYql
	ZZYe2U9YBUVIPI77ad25jLtUwDxxFMgg3HkbqeGpek0GLAXruh8UHZqx0Y6jG90Jx7abT1MwDP1
	rJlOM6y5WBh9kkfbmOPq6PF0EIHpLctz+Pd3w6AYa46dnqRPd9Yk11UZpN37SN3L3Cz560nC+wk
	E
X-Received: by 2002:a19:d242:: with SMTP id j63mr28516890lfg.26.1548937925904;
        Thu, 31 Jan 2019 04:32:05 -0800 (PST)
X-Received: by 2002:a19:d242:: with SMTP id j63mr28516837lfg.26.1548937924945;
        Thu, 31 Jan 2019 04:32:04 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548937924; cv=none;
        d=google.com; s=arc-20160816;
        b=WFL97rm+yw6HvSgRm0s3GTFMkoeTFyd/RU7MYZh+vvsGq2HgRsbqn8jZTJ4RSnMUvx
         f/l3J5kRzohVQ2aWAZJvf8AwZee2DN1ad8aDmPOBwZnOO+xIy4jk0Bp7r1UfjEzgTvgi
         riP4LyL+5yznCrtP7cmjH3k2+OjVEypoYUMDBOx57KKPKuQ4lgG97upaLYQzwQglNrrh
         7emQ3daUM6dNG+6IVX9rmQQ7Lm/E+avUcEQV1bY57y+HQuh6uHPK311wnOuu+0iiPM8p
         VQq+S9v+wQDnUF5Ngm6L5cDKQoVZbP5j8Fxy0P37BNT+t3UXcKzcPKMAslB7dBqMM/t8
         LdXw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=MUni9/6Z2lGMVz53wyw6zTg0RWZ4vyfLf6KBzYMBEmg=;
        b=cm3an51jz9+cbqjRyfChg41BvUWZVoX2vRSM7qjrdjW7eeQ/IOgcu7RFQIweQe0GBK
         wTFqzmL5WF8WXCtTLR+/379CqAOa7qL4VQCL+A7O6JvAKPBBPSHpYnwwWHVuQxUrVUbt
         487xyYalhmILEwSmWUPNVjanSwk028Iv39CMpFtr8d1Qsy1WYE2cMa2Aj9AU+p2fpR2l
         wEFX4dKWTkZXThOyUPhGf1VRXxpcI0lCcVHphmLShucmMu2/L+llpd/QeqjkWOiKb8X0
         5skwXKQDIna+ag8H/XtDSI8fsv7ttPWse4i3Hus3/tncX4weAfKHCjnyUC6bqln543AW
         IONA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=rm0itLub;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v5-v6sor3174206lje.28.2019.01.31.04.32.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 31 Jan 2019 04:32:04 -0800 (PST)
Received-SPF: pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=rm0itLub;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=MUni9/6Z2lGMVz53wyw6zTg0RWZ4vyfLf6KBzYMBEmg=;
        b=rm0itLubnrxxq4PPU48BdkkmPOHGmoawlXX7TkirV4StzYrvbOIna0ghZQS2MZ2t76
         XhmHBOPccSIjpVoDYvh6YrtIBr5eW0+bdYyC3OkQ7c8WSywe3qd9fTk75H03Iczx/vz+
         ica0fn1RP61+8A8QOUdr2YeGNhb1x8j06LH67rCa56PhTSaWcsKMzCFrGAKWvu8izLO1
         r9n/88H88jlojH/9LggBml0yrFb/uQsNo2A7e1JgfSAEKysdVB90p+WDPw0Udz+KvqR8
         XIGDjJcmERRAXarrPQcdwF9vNp/LZDRJsdhZkxzMTILaiGDq0d2CfYCAzuog8UhXWLuy
         RKDg==
X-Google-Smtp-Source: AHgI3IYqaijPCAbpcAfqB4K9ZTYxFfKIZ7xmxN6niWa1cYJjdCHW8ay1HiYLvHZ4e1NWitw9Tq+lwpQUU40Nwq+GS9I=
X-Received: by 2002:a2e:5703:: with SMTP id l3-v6mr16102340ljb.106.1548937924232;
 Thu, 31 Jan 2019 04:32:04 -0800 (PST)
MIME-Version: 1.0
References: <20190131030812.GA2174@jordon-HP-15-Notebook-PC> <1701923.z6LKAITQJA@phil>
In-Reply-To: <1701923.z6LKAITQJA@phil>
From: Souptick Joarder <jrdr.linux@gmail.com>
Date: Thu, 31 Jan 2019 18:01:52 +0530
Message-ID: <CAFqt6zbxyMB3VCzbWo1rPdfKXLVTNx+RY0=guD5CRxD37gJzsA@mail.gmail.com>
Subject: Re: [PATCHv2 1/9] mm: Introduce new vm_insert_range and
 vm_insert_range_buggy API
To: Heiko Stuebner <heiko@sntech.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <willy@infradead.org>, 
	Michal Hocko <mhocko@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, vbabka@suse.cz, 
	Rik van Riel <riel@surriel.com>, Stephen Rothwell <sfr@canb.auug.org.au>, rppt@linux.vnet.ibm.com, 
	Peter Zijlstra <peterz@infradead.org>, Russell King - ARM Linux <linux@armlinux.org.uk>, robin.murphy@arm.com, 
	iamjoonsoo.kim@lge.com, treding@nvidia.com, Kees Cook <keescook@chromium.org>, 
	Marek Szyprowski <m.szyprowski@samsung.com>, stefanr@s5r6.in-berlin.de, hjc@rock-chips.com, 
	airlied@linux.ie, oleksandr_andrushchenko@epam.com, joro@8bytes.org, 
	pawel@osciak.com, Kyungmin Park <kyungmin.park@samsung.com>, mchehab@kernel.org, 
	Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, 
	linux-kernel@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, 
	linux-arm-kernel@lists.infradead.org, linux1394-devel@lists.sourceforge.net, 
	dri-devel@lists.freedesktop.org, linux-rockchip@lists.infradead.org, 
	xen-devel@lists.xen.org, iommu@lists.linux-foundation.org, 
	linux-media@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jan 31, 2019 at 5:37 PM Heiko Stuebner <heiko@sntech.de> wrote:
>
> Am Donnerstag, 31. Januar 2019, 04:08:12 CET schrieb Souptick Joarder:
> > Previouly drivers have their own way of mapping range of
> > kernel pages/memory into user vma and this was done by
> > invoking vm_insert_page() within a loop.
> >
> > As this pattern is common across different drivers, it can
> > be generalized by creating new functions and use it across
> > the drivers.
> >
> > vm_insert_range() is the API which could be used to mapped
> > kernel memory/pages in drivers which has considered vm_pgoff
> >
> > vm_insert_range_buggy() is the API which could be used to map
> > range of kernel memory/pages in drivers which has not considered
> > vm_pgoff. vm_pgoff is passed default as 0 for those drivers.
> >
> > We _could_ then at a later "fix" these drivers which are using
> > vm_insert_range_buggy() to behave according to the normal vm_pgoff
> > offsetting simply by removing the _buggy suffix on the function
> > name and if that causes regressions, it gives us an easy way to revert.
> >
> > Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>
> > Suggested-by: Russell King <linux@armlinux.org.uk>
> > Suggested-by: Matthew Wilcox <willy@infradead.org>
>
> hmm, I'm missing a changelog here between v1 and v2.
> Nevertheless I managed to test v1 on Rockchip hardware
> and display is still working, including talking to Lima via prime.
>
> So if there aren't any big changes for v2, on Rockchip
> Tested-by: Heiko Stuebner <heiko@sntech.de>

Change log is available in [0/9].
Patch [1/9] & [4/9] have no changes between v1 -> v2.

