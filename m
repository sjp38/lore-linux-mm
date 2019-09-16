Return-Path: <SRS0=CHX8=XL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B09E5C4CECE
	for <linux-mm@archiver.kernel.org>; Mon, 16 Sep 2019 17:22:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 483F221881
	for <linux-mm@archiver.kernel.org>; Mon, 16 Sep 2019 17:22:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="itokVSgl"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 483F221881
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A276D6B0003; Mon, 16 Sep 2019 13:22:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9DAE06B0006; Mon, 16 Sep 2019 13:22:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8D22A6B0007; Mon, 16 Sep 2019 13:22:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0008.hostedemail.com [216.40.44.8])
	by kanga.kvack.org (Postfix) with ESMTP id 6BE6D6B0003
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 13:22:36 -0400 (EDT)
Received: from smtpin17.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 0E1C96D80
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 17:22:36 +0000 (UTC)
X-FDA: 75941453112.17.kiss03_50df525abc45c
X-HE-Tag: kiss03_50df525abc45c
X-Filterd-Recvd-Size: 4773
Received: from mail-qt1-f195.google.com (mail-qt1-f195.google.com [209.85.160.195])
	by imf04.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 17:22:35 +0000 (UTC)
Received: by mail-qt1-f195.google.com with SMTP id u22so699987qtq.13
        for <linux-mm@kvack.org>; Mon, 16 Sep 2019 10:22:35 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=rDB8uHDkgWN7+yrcA0FfYLtoe+OjSqFeu+VWqQjDn9I=;
        b=itokVSglbnepYieFIOvlt/0B3BXlO2wgztzBJWDXit/kUzBppinOuLRUPbgVctrnlE
         Xs+7vvbrQmv5LYTPN8Wi3loVrc108cIzN/YQvdjW58ZaCN1lxKsfH755TlliYEDnabFH
         A6WLXRApELiiGrDYIhNaJmFqjk1rRQj8JGsvkRpjxxt/+4wIR/RL6IlQ+xsmQcufDL7o
         ZDPk0v3tELCnCOKzUeZ18e+1iUzx5Em5giLoGWX8xcf5XUa0y/2VtVvSwBdNKuksYWWv
         7whgoxnQEbZaqzK6mw2wouJQuGpYXPtqo/fSx/BrIsKjoa1325vMHR+2yfKQL6/nV+WS
         FIwg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=rDB8uHDkgWN7+yrcA0FfYLtoe+OjSqFeu+VWqQjDn9I=;
        b=BtUmSTfc5sArO36d7TlsYW27sSGIHJKjTfr5muGHqrf65U19w8A+zfqGygDcl+bjfn
         jA4S7C2u570RheDFSREVkaqG1teoBQPm7ynX7uPCecw0eX11wNjF0VYGKvcqwWhFNV8E
         KCTN7EcdxQ7W998I5lTKsToiAQBxGtb0wL5IKllFisbaxB6WQRHfMggfS9qJ08ACXkcg
         L/RlHx4roVTnA0I5ubU6Y0OfDIfW/8gmSCYurDQ+zRZqasbX9U8Dt9PwUwAZaYqFMsCg
         iHJny9E++OOv2A8uH/m9xiJbPzGRVFR2SaTuVdyluJ1sGFJUBlbf5yqJztKXkkan0HHI
         1WSw==
X-Gm-Message-State: APjAAAWEpQgYSmCC3CPZ84c4Um5AeWX2f+hENsw150zIAE8tEmQX/XLx
	U5FLZ8ZXptigococ3lZ6U06wMqwYFsuGeG2W/zU=
X-Google-Smtp-Source: APXvYqyNxf9P5+HIEk2snNUL/kA+YguGWoN9sH1Euy3GdsF7mtVDOmDSkV7CR8UtRX+Q28d8U1CmoEHgealLu8qcH9g=
X-Received: by 2002:ac8:f33:: with SMTP id e48mr720765qtk.123.1568654555208;
 Mon, 16 Sep 2019 10:22:35 -0700 (PDT)
MIME-Version: 1.0
References: <20190913091849.11151-1-kirill.shutemov@linux.intel.com>
In-Reply-To: <20190913091849.11151-1-kirill.shutemov@linux.intel.com>
From: Yang Shi <shy828301@gmail.com>
Date: Mon, 16 Sep 2019 10:22:18 -0700
Message-ID: <CAHbLzkq7JT=KE9R_W6YfXmBJBeESgXZvdReS30sH8no63YQE0Q@mail.gmail.com>
Subject: Re: [PATCH] mm, thp: Do not queue fully unmapped pages for deferred split
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, 
	Linux MM <linux-mm@kvack.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, 
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Sep 13, 2019 at 2:18 AM Kirill A. Shutemov <kirill@shutemov.name> wrote:
>
> Adding fully unmapped pages into deferred split queue is not productive:
> these pages are about to be freed or they are pinned and cannot be split
> anyway.

This change looks good to me. Reviewed-by: Yang Shi <yang.shi@linux.alibaba.com>

>
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> ---
>  mm/rmap.c | 14 ++++++++++----
>  1 file changed, 10 insertions(+), 4 deletions(-)
>
> diff --git a/mm/rmap.c b/mm/rmap.c
> index 003377e24232..45388f1bf317 100644
> --- a/mm/rmap.c
> +++ b/mm/rmap.c
> @@ -1271,12 +1271,20 @@ static void page_remove_anon_compound_rmap(struct page *page)
>         if (TestClearPageDoubleMap(page)) {
>                 /*
>                  * Subpages can be mapped with PTEs too. Check how many of
> -                * themi are still mapped.
> +                * them are still mapped.
>                  */
>                 for (i = 0, nr = 0; i < HPAGE_PMD_NR; i++) {
>                         if (atomic_add_negative(-1, &page[i]._mapcount))
>                                 nr++;
>                 }
> +
> +               /*
> +                * Queue the page for deferred split if at least one small
> +                * page of the compound page is unmapped, but at least one
> +                * small page is still mapped.
> +                */
> +               if (nr && nr < HPAGE_PMD_NR)
> +                       deferred_split_huge_page(page);
>         } else {
>                 nr = HPAGE_PMD_NR;
>         }
> @@ -1284,10 +1292,8 @@ static void page_remove_anon_compound_rmap(struct page *page)
>         if (unlikely(PageMlocked(page)))
>                 clear_page_mlock(page);
>
> -       if (nr) {
> +       if (nr)
>                 __mod_node_page_state(page_pgdat(page), NR_ANON_MAPPED, -nr);
> -               deferred_split_huge_page(page);
> -       }
>  }
>
>  /**
> --
> 2.21.0
>
>

