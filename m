Return-Path: <SRS0=QF98=XN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3DB76C4CEC9
	for <linux-mm@archiver.kernel.org>; Wed, 18 Sep 2019 11:48:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D31FE21907
	for <linux-mm@archiver.kernel.org>; Wed, 18 Sep 2019 11:48:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=ieee.org header.i=@ieee.org header.b="W6+8ReYi"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D31FE21907
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=ieee.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3EBCD6B0296; Wed, 18 Sep 2019 07:48:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 39B676B0298; Wed, 18 Sep 2019 07:48:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2B0136B0299; Wed, 18 Sep 2019 07:48:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0249.hostedemail.com [216.40.44.249])
	by kanga.kvack.org (Postfix) with ESMTP id 047946B0296
	for <linux-mm@kvack.org>; Wed, 18 Sep 2019 07:48:13 -0400 (EDT)
Received: from smtpin30.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 96072812F
	for <linux-mm@kvack.org>; Wed, 18 Sep 2019 11:48:13 +0000 (UTC)
X-FDA: 75947868066.30.wren23_2aa89e03d6641
X-HE-Tag: wren23_2aa89e03d6641
X-Filterd-Recvd-Size: 5224
Received: from mail-io1-f66.google.com (mail-io1-f66.google.com [209.85.166.66])
	by imf45.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 18 Sep 2019 11:48:13 +0000 (UTC)
Received: by mail-io1-f66.google.com with SMTP id n197so15345251iod.9
        for <linux-mm@kvack.org>; Wed, 18 Sep 2019 04:48:13 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ieee.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=ofTkjvEUSpXrIs73m3lky1N1Didfq1+b+91cMsW/1Rg=;
        b=W6+8ReYiHHVeVlnbV+ueh6udXHFSCEib8D8eNPDlyCH6VFXoehOcoJRBKqKNvR4FEM
         9g8Yy6hdIuR0aAWNZlOKYx7kixD+24v0SCc4385+eO76oCXYWiCs2JC13YTOVoFPb+2U
         gWfU78r/G4aJO0p15MkApXrNA4dRMyazMU6Hs=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=ofTkjvEUSpXrIs73m3lky1N1Didfq1+b+91cMsW/1Rg=;
        b=a44mh6A36GV5mDciSk68N72V0r7i4XbaI06yYu6utqirCIm1tQWvq36DMF7Jf8TR2E
         0fTV1ZkWLlsXW2SzL+MTuIa7ke0PWW+JU/gIxc062WaVNAiC+eqxfPN+KpEh+xag4rCb
         hmRDNTU9pYMJM/ZgJn2D1HMgBz/G/IiaVjG7iCdd5wIV56U+9W94418MnisIK5mS1rbY
         LpIsu4ADNwW0QpplgK4i1PULb6qx6PIYbK2Zd/vOEVmNzKFIira9dZEjua0Q/B99uNe7
         qTjz1OGbfqOGIJGSYtz4y1XEMzfgV6NiIwzyRI02xnTuw7edNCx53aS/dtO+jYROnMb/
         bkzg==
X-Gm-Message-State: APjAAAWCkfgrN+TXoxG9M2QCADzZnABsClwVvS2E77Diium+39HBNKfT
	T+NwkBHopxoZRtbfkGoCwe1Rm6CvbufsNuArh4o=
X-Google-Smtp-Source: APXvYqyw0kfhKySzuyEVmqkEH5tD5giZFYYFb8X7Ox56+XVKPgy+ZTNU1io4zY5oiSdqUq3HrOYM3DiCRNEvay8WMq0=
X-Received: by 2002:a5d:91c8:: with SMTP id k8mr1484342ior.232.1568807292316;
 Wed, 18 Sep 2019 04:48:12 -0700 (PDT)
MIME-Version: 1.0
References: <20190916004640.b453167d3556c4093af4cf7d@gmail.com>
In-Reply-To: <20190916004640.b453167d3556c4093af4cf7d@gmail.com>
From: Dan Streetman <ddstreet@ieee.org>
Date: Wed, 18 Sep 2019 07:47:36 -0400
Message-ID: <CALZtONDROMJoyxgRSG2+xNVs2B0q+vQQOGG09fH0QCSzgRi5CA@mail.gmail.com>
Subject: Re: [PATCH/RFC] zswap: do not map same object twice
To: Vitaly Wool <vitalywool@gmail.com>
Cc: Linux-MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, 
	linux-kernel <linux-kernel@vger.kernel.org>, Seth Jennings <sjenning@redhat.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Sep 15, 2019 at 5:46 PM Vitaly Wool <vitalywool@gmail.com> wrote:
>
> zswap_writeback_entry() maps a handle to read swpentry first, and
> then in the most common case it would map the same handle again.
> This is ok when zbud is the backend since its mapping callback is
> plain and simple, but it slows things down for z3fold.
>
> Since there's hardly a point in unmapping a handle _that_ fast as
> zswap_writeback_entry() does when it reads swpentry, the
> suggestion is to keep the handle mapped till the end.

LGTM

>
> Signed-off-by: Vitaly Wool <vitalywool@gmail.com>

Reviewed-by: Dan Streetman <ddstreet@ieee.org>

> ---
>  mm/zswap.c | 7 +++----
>  1 file changed, 3 insertions(+), 4 deletions(-)
>
> diff --git a/mm/zswap.c b/mm/zswap.c
> index 0e22744a76cb..b35464bc7315 100644
> --- a/mm/zswap.c
> +++ b/mm/zswap.c
> @@ -856,7 +856,6 @@ static int zswap_writeback_entry(struct zpool *pool, unsigned long handle)
>         /* extract swpentry from data */
>         zhdr = zpool_map_handle(pool, handle, ZPOOL_MM_RO);
>         swpentry = zhdr->swpentry; /* here */
> -       zpool_unmap_handle(pool, handle);
>         tree = zswap_trees[swp_type(swpentry)];
>         offset = swp_offset(swpentry);
>
> @@ -866,6 +865,7 @@ static int zswap_writeback_entry(struct zpool *pool, unsigned long handle)
>         if (!entry) {
>                 /* entry was invalidated */
>                 spin_unlock(&tree->lock);
> +               zpool_unmap_handle(pool, handle);
>                 return 0;
>         }
>         spin_unlock(&tree->lock);
> @@ -886,15 +886,13 @@ static int zswap_writeback_entry(struct zpool *pool, unsigned long handle)
>         case ZSWAP_SWAPCACHE_NEW: /* page is locked */
>                 /* decompress */
>                 dlen = PAGE_SIZE;
> -               src = (u8 *)zpool_map_handle(entry->pool->zpool, entry->handle,
> -                               ZPOOL_MM_RO) + sizeof(struct zswap_header);
> +               src = (u8 *)zhdr + sizeof(struct zswap_header);
>                 dst = kmap_atomic(page);
>                 tfm = *get_cpu_ptr(entry->pool->tfm);
>                 ret = crypto_comp_decompress(tfm, src, entry->length,
>                                              dst, &dlen);
>                 put_cpu_ptr(entry->pool->tfm);
>                 kunmap_atomic(dst);
> -               zpool_unmap_handle(entry->pool->zpool, entry->handle);
>                 BUG_ON(ret);
>                 BUG_ON(dlen != PAGE_SIZE);
>
> @@ -940,6 +938,7 @@ static int zswap_writeback_entry(struct zpool *pool, unsigned long handle)
>         spin_unlock(&tree->lock);
>
>  end:
> +       zpool_unmap_handle(pool, handle);
>         return ret;
>  }
>
> --
> 2.17.1

