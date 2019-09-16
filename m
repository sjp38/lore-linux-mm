Return-Path: <SRS0=CHX8=XL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 043A5C4CECD
	for <linux-mm@archiver.kernel.org>; Mon, 16 Sep 2019 14:52:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BCA2C20650
	for <linux-mm@archiver.kernel.org>; Mon, 16 Sep 2019 14:52:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="LxDbhb+s"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BCA2C20650
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 652A96B0008; Mon, 16 Sep 2019 10:52:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 601EB6B000A; Mon, 16 Sep 2019 10:52:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4F07C6B000C; Mon, 16 Sep 2019 10:52:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0044.hostedemail.com [216.40.44.44])
	by kanga.kvack.org (Postfix) with ESMTP id 2CC876B0008
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 10:52:28 -0400 (EDT)
Received: from smtpin09.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id DC3F5180AD803
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 14:52:27 +0000 (UTC)
X-FDA: 75941074734.09.suit57_4fadfb9509c55
X-HE-Tag: suit57_4fadfb9509c55
X-Filterd-Recvd-Size: 4178
Received: from mail-oi1-f196.google.com (mail-oi1-f196.google.com [209.85.167.196])
	by imf48.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 14:52:27 +0000 (UTC)
Received: by mail-oi1-f196.google.com with SMTP id 12so12600oiq.1
        for <linux-mm@kvack.org>; Mon, 16 Sep 2019 07:52:27 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=Rz4fstL5PcNeH2URZIP6JUFkj0ovCM3jsOukQ2mghT8=;
        b=LxDbhb+sepV6hNiFf95ePSFVMHfW7m75L/eVS418Gb9PcMncY1GPn8YZ9A1SzBayDC
         ns+kJqdBBZP/YTxzVax4rw2aqHPjoxe20u934Qu7y4rp6M2Jd2zcL/hvwYoBORFVGfg+
         i5pEwuAes4nlW6z/JhIH/rJHelMu98T3P0ueBWpcBFF5EgRV8mmKKML6Faw9na4/qoSw
         6mgOC3io0FXPm6aPRXxGlZkEwa3ocY2GtPvHzO7SfAJ6YC1cbNY1PHPh0MsxuRhRI70k
         zkYwjhech/VTX25+jUeOE8rg64XS4l2i6h9zEJUDlQ3VKM5l71QqqYtexpJ3xADP3mMT
         g7xA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=Rz4fstL5PcNeH2URZIP6JUFkj0ovCM3jsOukQ2mghT8=;
        b=Qj5iHzD2EUhKrchE17kHpswoMfskoNHdrKQUiMqLb1uMrniOi9k1O4KeumEOc15UKL
         Ey/Tv6pCAUf4C16vmrplqmGKO4VdEXUroyBIe6yOvwSpgNIGMs0OSFwoqI1W6O3fDBeu
         C4S5J1mm75ItcyTfXMbjbZLgtZ99VbtoquL+7zT37/cGSAwfb7lMmFM9YrJBTkzcgcEX
         OLXBHoWX3kVkcNDTG+MEEfKyhKaKhPz00x2iG3Ut03gYZiLIpWvjplNeiHCnwwvmZ67f
         SFCX0CddSlxdn2CEN+H2EFafTJC5nO8377LAsa76/jwMO8WwT5qIDhOfwVop7L3lNSx5
         cISQ==
X-Gm-Message-State: APjAAAVNdtR4YRamQUZkBU2jjrHQca/NOhJdIfkVvd7Ojq/E2teBmwDr
	q40BWDWGuyA70h5x4eocd9+hMPSKE0JHmSPKYbU=
X-Google-Smtp-Source: APXvYqyVlzwEHQON5YK1RLDCgnErzpw4BALj+ECauWMeVLCvCJGCiUnF8aqP1wO8Dz6jqNGYbS/pIDujVHjsyJXjIJo=
X-Received: by 2002:aca:c38b:: with SMTP id t133mr138124oif.22.1568645546529;
 Mon, 16 Sep 2019 07:52:26 -0700 (PDT)
MIME-Version: 1.0
References: <20190915170809.10702-1-lpf.vector@gmail.com> <20190915170809.10702-2-lpf.vector@gmail.com>
 <alpine.DEB.2.21.1909151410250.211705@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.21.1909151410250.211705@chino.kir.corp.google.com>
From: Pengfei Li <lpf.vector@gmail.com>
Date: Mon, 16 Sep 2019 22:52:15 +0800
Message-ID: <CAD7_sbHHNObV4Gw24FP_KUtB9d4qSBpy9jwjWhWKxNGGLVNMgQ@mail.gmail.com>
Subject: Re: [RESEND v4 1/7] mm, slab: Make kmalloc_info[] contain all types
 of names
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, 
	Christopher Lameter <cl@linux.com>, penberg@kernel.org, iamjoonsoo.kim@lge.com, 
	linux-mm@kvack.org, linux-kernel@vger.kernel.org, 
	Roman Gushchin <guro@fb.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000042, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Sep 16, 2019 at 5:38 AM David Rientjes <rientjes@google.com> wrote:
>
> On Mon, 16 Sep 2019, Pengfei Li wrote:
>
> > There are three types of kmalloc, KMALLOC_NORMAL, KMALLOC_RECLAIM
> > and KMALLOC_DMA.
> >
> > The name of KMALLOC_NORMAL is contained in kmalloc_info[].name,
> > but the names of KMALLOC_RECLAIM and KMALLOC_DMA are dynamically
> > generated by kmalloc_cache_name().
> >
> > This patch predefines the names of all types of kmalloc to save
> > the time spent dynamically generating names.
> >
> > Besides, remove the kmalloc_cache_name() that is no longer used.
> >
> > Signed-off-by: Pengfei Li <lpf.vector@gmail.com>
> > Acked-by: Vlastimil Babka <vbabka@suse.cz>
> > Acked-by: Roman Gushchin <guro@fb.com>
>
> Acked-by: David Rientjes <rientjes@google.com>
>

Thanks.

> It's unfortunate the existing names are kmalloc-, dma-kmalloc-, and
> kmalloc-rcl- since they aren't following any standard naming convention.
>
> Also not sure I understand the SET_KMALLOC_SIZE naming since this isn't
> just setting a size.  Maybe better off as INIT_KMALLOC_INFO?

Yes, this name is really better. I will rename SET_KMALLOC_SIZE to
INIT_KMALLOC_INFO in v5.

>
> Nothing major though, so:
>
> Acked-by: David Rientjes <rientjes@google.com>

