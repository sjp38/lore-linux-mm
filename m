Return-Path: <SRS0=aN9C=WJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1A4B6C32750
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 08:03:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D1E9920679
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 08:03:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="AYFA0Q48"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D1E9920679
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 711836B0005; Tue, 13 Aug 2019 04:03:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6C2726B0006; Tue, 13 Aug 2019 04:03:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5B2256B0007; Tue, 13 Aug 2019 04:03:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0140.hostedemail.com [216.40.44.140])
	by kanga.kvack.org (Postfix) with ESMTP id 3B6366B0005
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 04:03:07 -0400 (EDT)
Received: from smtpin01.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id D69578248AA2
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 08:03:06 +0000 (UTC)
X-FDA: 75816663972.01.hat15_383f278e7770d
X-HE-Tag: hat15_383f278e7770d
X-Filterd-Recvd-Size: 4429
Received: from mail-ot1-f66.google.com (mail-ot1-f66.google.com [209.85.210.66])
	by imf38.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 08:03:06 +0000 (UTC)
Received: by mail-ot1-f66.google.com with SMTP id e12so24924366otp.10
        for <linux-mm@kvack.org>; Tue, 13 Aug 2019 01:03:06 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=xpTjmXViSqIki2Cb2qHpkfQ62APVJj7AGYZMRIsoCJ8=;
        b=AYFA0Q48dX8onM7zG1H8BuQOm2zh/w79ApEK6ezu93//mTeriuACrbmOrAUH4FTlRE
         grdX+HbfBfjYQM3DPrOGRw5HZpIEFcrBB4mLP0Jn2ue/W+RdzBXlYtDl8eajDOiUjZzl
         S2BStp2whwPW/DdQ4FqQUVOn+d5agQUeEAKJdzy9A53jzAmj72y2/7DlBvubA+K6cLUV
         W30iWaGSFvtDIrjrU7ZmVTy19Evq518Xe1klm+es+rjpGJYW2VXkgFkqPCQOBJFJlWAY
         +IgfLW8ged01WvOmEibmynVe5lN8t6yD1am79qSRamNXI0x6/2qQBD0WzzuN/iPgWlhf
         QPSA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=xpTjmXViSqIki2Cb2qHpkfQ62APVJj7AGYZMRIsoCJ8=;
        b=JxdcnQT+nfbhqcfMnKD4UBcdBC9BTgsWZN2rGtWc8dcVuqFkJ4cfJzPt5gtQebe2g6
         LbRKFVqp46s5bqs76GLFWvxaJPHZa3gtsv483IDSQZaRsUToB4xYo/HxRwCAsX2JPuu7
         qiz5/ZBLUNvx/4kDMxEp8YmUZfZlfMUxpZPeM3EbciqtdrEnIlgJlYfXRnaplDlG+aA4
         DbnZYFU1UBubBYeeRYQJx9LViqyNuke4/svPsWYny+oFpz91S1LhMX8R6Mz4vKOQ0uzc
         R8ysWwVRpRCQIElipgnDC7F0kuBrrRKjipjGB+2XLxx6JZqCtO0tiKfrEmUMebxRyGWJ
         2loQ==
X-Gm-Message-State: APjAAAWMqgy3awwqvq8+CQpB17JPM8zKsf7gktkRFcs0YIq+WCqW4gME
	uLH+9Im622Rqe2DzvKAQrgUb0yn7moofaJcD1ZI=
X-Google-Smtp-Source: APXvYqzzSJbUR/V1lvk2p/n+pBFYlV3r4RaXqZ8riQxviItgG2T6vtN6lVbqJgCVjr/mfYonAVDHl6acFGgXOfajAzU=
X-Received: by 2002:aca:fcc4:: with SMTP id a187mr619358oii.126.1565683385526;
 Tue, 13 Aug 2019 01:03:05 -0700 (PDT)
MIME-Version: 1.0
References: <20190812113429.2488-1-ivan.khoronzhuk@linaro.org> <20190812124326.32146-1-ivan.khoronzhuk@linaro.org>
In-Reply-To: <20190812124326.32146-1-ivan.khoronzhuk@linaro.org>
From: Magnus Karlsson <magnus.karlsson@gmail.com>
Date: Tue, 13 Aug 2019 10:02:54 +0200
Message-ID: <CAJ8uoz0bBhdQSocQz8Y9tvrGCsCE9TDf3m1u6=sL4Eo5tZ17YQ@mail.gmail.com>
Subject: Re: [PATCH v2 bpf-next] mm: mmap: increase sockets maximum memory
 size pgoff for 32bits
To: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
Cc: =?UTF-8?B?QmrDtnJuIFTDtnBlbA==?= <bjorn.topel@intel.com>, 
	linux-mm@kvack.org, Xdp <xdp-newbies@vger.kernel.org>, 
	Network Development <netdev@vger.kernel.org>, bpf <bpf@vger.kernel.org>, 
	linux-kernel@vger.kernel.org, akpm@linux-foundation.org, 
	Alexei Starovoitov <ast@kernel.org>, "Karlsson, Magnus" <magnus.karlsson@intel.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Aug 12, 2019 at 2:45 PM Ivan Khoronzhuk
<ivan.khoronzhuk@linaro.org> wrote:
>
> The AF_XDP sockets umem mapping interface uses XDP_UMEM_PGOFF_FILL_RING
> and XDP_UMEM_PGOFF_COMPLETION_RING offsets. The offsets seems like are
> established already and are part of configuration interface.
>
> But for 32-bit systems, while AF_XDP socket configuration, the values
> are to large to pass maximum allowed file size verification.
> The offsets can be tuned ofc, but instead of changing existent
> interface - extend max allowed file size for sockets.

Can you use mmap2() instead that takes a larger offset (2^44) even on
32-bit systems?

/Magnus

> Signed-off-by: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
> ---
>
> Based on bpf-next/master
>
> v2..v1:
>         removed not necessarily #ifdev as ULL and UL for 64 has same size
>
>  mm/mmap.c | 3 +++
>  1 file changed, 3 insertions(+)
>
> diff --git a/mm/mmap.c b/mm/mmap.c
> index 7e8c3e8ae75f..578f52812361 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -1358,6 +1358,9 @@ static inline u64 file_mmap_size_max(struct file *file, struct inode *inode)
>         if (S_ISBLK(inode->i_mode))
>                 return MAX_LFS_FILESIZE;
>
> +       if (S_ISSOCK(inode->i_mode))
> +               return MAX_LFS_FILESIZE;
> +
>         /* Special "we do even unsigned file positions" case */
>         if (file->f_mode & FMODE_UNSIGNED_OFFSET)
>                 return 0;
> --
> 2.17.1
>

