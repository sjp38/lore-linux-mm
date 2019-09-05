Return-Path: <SRS0=ftCo=XA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 01E32C3A5A5
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 13:51:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 671C42070C
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 13:51:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="g+eUEH8K"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 671C42070C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 042246B000A; Thu,  5 Sep 2019 09:51:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F0E446B0266; Thu,  5 Sep 2019 09:51:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DFB956B026A; Thu,  5 Sep 2019 09:51:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0018.hostedemail.com [216.40.44.18])
	by kanga.kvack.org (Postfix) with ESMTP id B9B4D6B000A
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 09:51:26 -0400 (EDT)
Received: from smtpin27.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 677BD180AD801
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 13:51:26 +0000 (UTC)
X-FDA: 75901004172.27.ice44_46baea152d650
X-HE-Tag: ice44_46baea152d650
X-Filterd-Recvd-Size: 4650
Received: from mail-oi1-f193.google.com (mail-oi1-f193.google.com [209.85.167.193])
	by imf37.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 13:51:25 +0000 (UTC)
Received: by mail-oi1-f193.google.com with SMTP id x7so1837734oie.13
        for <linux-mm@kvack.org>; Thu, 05 Sep 2019 06:51:25 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=+MsBWp8H3Xsdsta9B4+xQJSg6DayANUO7A/PQ7k+1B8=;
        b=g+eUEH8KK/ZuogbCziIvbxFHTFdEu/3p51nvNXJl5SnYiqtlJEiK2f2furmO5spfJ0
         amnFRbVduwCMWbv0veUNrs3SDibOliL9Op976n+nfcc1LAXTlvYIE2zrNRFPuAUV75HY
         exdGGVlo5JyO2Kj/pWzkwTmlIyXIpz3XV9+5o2wdySnEcwWaWPnR4pkCDEgIGda3M8UA
         HlXb5GjziX3TaWvc/uOaQyHsJsEuPAiDybwI/StC3wPuWx+XyqZf569lvomLwWzyGptx
         KsoOMtQ6xh4EUMvGy8HHXr4OnLP2KDdMmv1Yin/f85STVk6yU+pp7+OkRpu0xhfWYUGm
         FbAQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=+MsBWp8H3Xsdsta9B4+xQJSg6DayANUO7A/PQ7k+1B8=;
        b=a1v74U9IBKp4I4aJtW1DjuwS4L4yhTSDgM+It7/tF52DL7+n8lKHeC4beg3lly07JT
         JuWKvczDEER6744JxRaWh0BaWwknWd9Eb2Aos92laF988D9b5FiKBz9hcdMzZMvUE3/j
         PG+FHt0wEIYTvz/lfuadtDEQP43n1/yMT+Qbg6zpysKgs9k5pvVSH6tLsWx+TXaRZ6pk
         SRjdaBwbCZihButXK8hxoQtKzLIrd+IwSW491qN8iRjgOczDUZmDU4k4dBxSqAL0ctVw
         tiM1NcXF4Y1MD/I6TbhMzsUyxLPqFjWLtQzkGW7/ZkX9H6kgcovbQHjNQRYOXLLpIZcb
         Z0GQ==
X-Gm-Message-State: APjAAAW71M6OIc/BcSSNnwFqiy5FYNWuosutTUpxA1V5pImjvh6rhTG7
	bq1TFT7wsCqSxB/SKY1clT2qG1MR7lWEiVIqi+4=
X-Google-Smtp-Source: APXvYqyALkEGTwKGlJUd2MWXX4ESYbIOx2MLkr3KfHXqdxypPOA3LDhxgeTh0ec0OiaP6zAfCgpSvZDWiSF18jxDMCs=
X-Received: by 2002:aca:d683:: with SMTP id n125mr2672295oig.21.1567691485294;
 Thu, 05 Sep 2019 06:51:25 -0700 (PDT)
MIME-Version: 1.0
References: <20190903160430.1368-1-lpf.vector@gmail.com> <8641aeba-ab8c-f5a1-a6ad-cf8c0f86baa7@suse.cz>
In-Reply-To: <8641aeba-ab8c-f5a1-a6ad-cf8c0f86baa7@suse.cz>
From: Pengfei Li <lpf.vector@gmail.com>
Date: Thu, 5 Sep 2019 21:51:14 +0800
Message-ID: <CAD7_sbH+1ZeHVcDWwVkWmNjCzDU4TUAN1zXWCmj1bftyU5o6TA@mail.gmail.com>
Subject: Re: [PATCH 0/5] mm, slab: Make kmalloc_info[] contain all types of names
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christopher Lameter <cl@linux.com>, penberg@kernel.org, 
	rientjes@google.com, iamjoonsoo.kim@lge.com, linux-mm@kvack.org, 
	linux-kernel@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Sep 5, 2019 at 8:25 PM Vlastimil Babka <vbabka@suse.cz> wrote:
>
> On 9/3/19 6:04 PM, Pengfei Li wrote:
> > There are three types of kmalloc, KMALLOC_NORMAL, KMALLOC_RECLAIM
> > and KMALLOC_DMA.
> >
> > The name of KMALLOC_NORMAL is contained in kmalloc_info[].name,
> > but the names of KMALLOC_RECLAIM and KMALLOC_DMA are dynamically
> > generated by kmalloc_cache_name().
> >
> > Patch1 predefines the names of all types of kmalloc to save
> > the time spent dynamically generating names.
> >
> > The other 4 patches did some cleanup work.
> >
> > These changes make sense, and the time spent by new_kmalloc_cache()
> > has been reduced by approximately 36.3%.
> >
> >                          Time spent by
> >                          new_kmalloc_cache()
> > 5.3-rc7                       66264
> > 5.3-rc7+patch                 42188
>
> Note that the caches are created only once upon boot, so I doubt that

Thank you for your comments.
Yes, kmalloc-xxx are only created at boot time.

> these time savings (is it in CPU cycles?) will be noticeable at all.

Yes, it is CPU cycles.

> But diffstat looks ok, and it avoids using kmalloc() (via kasprintf()) to
> allocate names for kmalloc(), so in that sense I think it's worthwhile
> to consider. Thanks.
>

Thanks.

> > Pengfei Li (5):
> >   mm, slab: Make kmalloc_info[] contain all types of names
> >   mm, slab_common: Remove unused kmalloc_cache_name()
> >   mm, slab: Remove unused kmalloc_size()
> >   mm, slab_common: Make 'type' is enum kmalloc_cache_type
> >   mm, slab_common: Make initializing KMALLOC_DMA start from 1
> >
> >  include/linux/slab.h |  20 ---------
> >  mm/slab.c            |   7 +--
> >  mm/slab.h            |   2 +-
> >  mm/slab_common.c     | 101 +++++++++++++++++++++++--------------------
> >  4 files changed, 59 insertions(+), 71 deletions(-)
> >
>

