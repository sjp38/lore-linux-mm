Return-Path: <SRS0=rmuZ=QE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 612CBC282C8
	for <linux-mm@archiver.kernel.org>; Mon, 28 Jan 2019 20:06:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 098C8214DA
	for <linux-mm@archiver.kernel.org>; Mon, 28 Jan 2019 20:06:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="JWzqcoJ7"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 098C8214DA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AB92F8E0002; Mon, 28 Jan 2019 15:06:38 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A67A68E0001; Mon, 28 Jan 2019 15:06:38 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 931718E0002; Mon, 28 Jan 2019 15:06:38 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6692A8E0001
	for <linux-mm@kvack.org>; Mon, 28 Jan 2019 15:06:38 -0500 (EST)
Received: by mail-qt1-f197.google.com with SMTP id t18so22058627qtj.3
        for <linux-mm@kvack.org>; Mon, 28 Jan 2019 12:06:38 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=KOevpI4M7TBAYwZIdw3A2sHMSBaHAS6nG5olNgvrJrU=;
        b=hYcAcC1G1msN61K3UBJawgwams2zidECs08NDubxoaLtdWpgJMVEH/4uGtqevXLtLX
         UCtKgdSHTTy/16fmDYd6pYSrxSDdEeuPiTpT8wjnu0/i0S4YVL/pHz1lJoTyM5zS5l1Q
         WYsVgXm4heDhdSjTCaoOpf9JbmFdz0K12fs5SJYs9TFh3KQrX8BKfno1ftBbZxD9/LEg
         RZ94zDv1t4EtEQGfLqbV7aV4S+AQlCJyFQtOOJliby2t7KPMf8rIjqOzw3JrSeCNCqST
         ykINePyMvlcPS30fOSI9Ae29f3aaQIPemRjnmdsxO+5eq6TUdjx5HnaFWXllx9p/s6U9
         HiCA==
X-Gm-Message-State: AJcUukcGZ8QCRKsDYkUuVvjG6UyZ/MkkS5ZHuY7mfuJPm4nYErDbol8J
	Fcf+33RnARf4lXmaFBRzgOlLxEFyf/m5MWlPD5+diiTbhjDrwUaS3uWTsWGhSMZ/txrLExVZfQ1
	9WjNscGc203C+/BkpN3Qi0AfwL0oRlV8T3JR6UqzJM5AqQ4q5IeGJ97Sies3cV1RVu8Tqt1+OIP
	RmMnUxQ+DA4ZKzetsnmN0MxDQSPplAk4yRlDPuJhfDpiMQpFDec40hlrA6liYHyrFzGIk5B/uLd
	bJ7mD9NV1XseFHDAmaKZGccHRWlaM6ZiIFNj25mFUMWRsYXSZ26aAhMsyRn3QzoAPBS9RGo+2Ln
	2TQO2htvHxeU3hr38MvOPeSec1Q9JD1zLh+zb9mUSifuRzdQ3kYOrQnuNaMplARDe0nltDrseea
	S
X-Received: by 2002:ae9:dd42:: with SMTP id r63mr20236223qkf.264.1548705998135;
        Mon, 28 Jan 2019 12:06:38 -0800 (PST)
X-Received: by 2002:ae9:dd42:: with SMTP id r63mr20236182qkf.264.1548705997326;
        Mon, 28 Jan 2019 12:06:37 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548705997; cv=none;
        d=google.com; s=arc-20160816;
        b=rAqNIdLRgLgPArpu7nOcyOY+L68SEr+NI7/63efNGs1K1FiW9+utNgBhs8xUJA4TGc
         HTTY8g99Ll3czqRA5uN1m46sKLLfloPCofVf9oHDOkKHrbzCp+ScjV7meeZQ0UypyBrV
         WzB67V4ntwcaooh4tDjXrZYDRqDXU2N6kPYlcPhRvy+x/WVTlfhWAWb+DAWVinzu/2a7
         T8y+yNm5gU0HFo1zNhrautrymQlbkudi1JdYiML34B2InWxckl5v758lXI8Fquv7G1AP
         fUldZ530CQ6jt5yBr9dZfc+JlywvlA5mgDs+7HqdZvDKQzVbTShv/qgV+AYyYH+4ZSK4
         nyLw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=KOevpI4M7TBAYwZIdw3A2sHMSBaHAS6nG5olNgvrJrU=;
        b=HMuKUgjy7ZlntuMEqa/up5FfBZy3DWuZziCc32mbvWJ+ldNU9cA/jtGNEiuJf0FhzW
         9p5z+MyYWV3RTZAvFNIPUrbSi7ltWHsaRUcDZQjlXaiWEGohXiAgw7gzJebGE+MtShNw
         oq6HayaVM5vPFBxE6QJ3Rkgn3j0Y8k8C49yTcTT0QAWX4UHLB9jgW2hpOcNbbhg6sUlg
         tQI6Tyw3ZkUYZE6GsoXDjA3cNtvNdqq1UA/nkktyndFvlMgcZCi/NVj6WBoM7cvauw5E
         QGTy5smUcpOVsL/ikgFvxGdRSsU6iBSF/ypeh5O05lIFVIX0VBCt3mYNdApGlPc3b+K9
         oEMw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=JWzqcoJ7;
       spf=pass (google.com: domain of shy828301@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shy828301@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e38sor136225549qtk.19.2019.01.28.12.06.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 28 Jan 2019 12:06:37 -0800 (PST)
Received-SPF: pass (google.com: domain of shy828301@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=JWzqcoJ7;
       spf=pass (google.com: domain of shy828301@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shy828301@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=KOevpI4M7TBAYwZIdw3A2sHMSBaHAS6nG5olNgvrJrU=;
        b=JWzqcoJ7dNiiTOA+E70etwOz35fnrFBgRnmhM4iwB2jqvkRACtLKkVYmsGO7K0zCoY
         yqYK21FFkkkgzpJifry0Pi21PJYh8227IsBQ7wbxPRv3EzJRRZRZC76KrllI68zpKhBL
         I5yXT/mtx9YzguCxXsXY7XHOVACmCN8f9Ti4m4Hn/DqebWRU5evoSKZZxfeIyWENltv4
         Sx+m54nAEDAwyl3cNpXr3M7D/g3kOuSD836ic7geyV6vpemzJDVfpkjzawmgDktbxXcg
         YfkT4X1IxGBbukaZFGDHi1vi57S7LzkbN/TQY4RzSeMLxYvOmUQZXORRpJ5Hfztu4KRn
         vQ1w==
X-Google-Smtp-Source: ALg8bN7fU5qtnrXSFdOLmXgE+D7issUC2/0LNN2b/ZereP292vUTnMQQlHmx8OowjZIvngQ76guEPlSTPFdrg0se/2A=
X-Received: by 2002:ac8:c7:: with SMTP id d7mr22249791qtg.326.1548705997075;
 Mon, 28 Jan 2019 12:06:37 -0800 (PST)
MIME-Version: 1.0
References: <1548287573-15084-1-git-send-email-yang.shi@linux.alibaba.com> <aecc642c-d485-ed95-7935-19cda48800bc@nvidia.com>
In-Reply-To: <aecc642c-d485-ed95-7935-19cda48800bc@nvidia.com>
From: Yang Shi <shy828301@gmail.com>
Date: Mon, 28 Jan 2019 12:06:25 -0800
Message-ID: <CAHbLzkqTZK05g0191dKyTXGDcAuqMi9AGWPHbAEysQdgT7ayBQ@mail.gmail.com>
Subject: Re: [v2 PATCH] mm: ksm: do not block on page lock when searching
 stable tree
To: John Hubbard <jhubbard@nvidia.com>
Cc: Yang Shi <yang.shi@linux.alibaba.com>, Kirill Tkhai <ktkhai@virtuozzo.com>, hughd@google.com, 
	Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Linux MM <linux-mm@kvack.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi John,

Sorry for the late reply. It seems your email didn't reach my company
mailbox. So, I replied you with my personal email.

Thanks for your suggestion. This does make the code looks neater.
However, I'm not sure how Andrew thought about this patch. Once he is
ok to this patch in overall, I will update v3 by following your
suggestion.

Regards,
Yang


On Wed, Jan 23, 2019 at 4:24 PM John Hubbard <jhubbard@nvidia.com> wrote:
>
> On 1/23/19 3:52 PM, Yang Shi wrote:
> > ksmd need search stable tree to look for the suitable KSM page, but the
> > KSM page might be locked for a while due to i.e. KSM page rmap walk.
> > Basically it is not a big deal since commit 2c653d0ee2ae
> > ("ksm: introduce ksm_max_page_sharing per page deduplication limit"),
> > since max_page_sharing limits the number of shared KSM pages.
> >
> > But it still sounds not worth waiting for the lock, the page can be skip,
> > then try to merge it in the next scan to avoid potential stall if its
> > content is still intact.
> >
> > Introduce async mode to get_ksm_page() to not block on page lock, like
> > what try_to_merge_one_page() does.
> >
> > Return -EBUSY if trylock fails, since NULL means not find suitable KSM
> > page, which is a valid case.
> >
> > With the default max_page_sharing setting (256), there is almost no
> > observed change comparing lock vs trylock.
> >
> > However, with ksm02 of LTP, the reduced ksmd full scan time can be
> > observed, which has set max_page_sharing to 786432.  With lock version,
> > ksmd may tak 10s - 11s to run two full scans, with trylock version ksmd
> > may take 8s - 11s to run two full scans.  And, the number of
> > pages_sharing and pages_to_scan keep same.  Basically, this change has
> > no harm.
> >
> > Cc: Hugh Dickins <hughd@google.com>
> > Cc: Andrea Arcangeli <aarcange@redhat.com>
> > Reviewed-by: Kirill Tkhai <ktkhai@virtuozzo.com>
> > Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
> > ---
> > Hi folks,
> >
> > This patch was with "mm: vmscan: skip KSM page in direct reclaim if priority
> > is low" in the initial submission.  Then Hugh and Andrea pointed out commit
> > 2c653d0ee2ae ("ksm: introduce ksm_max_page_sharing per page deduplication
> > limit") is good enough for limiting the number of shared KSM page to prevent
> > from softlock when walking ksm page rmap.  This commit does solve the problem.
> > So, the series was dropped by Andrew from -mm tree.
> >
> > However, I thought the second patch (this one) still sounds useful.  So, I did
> > some test and resubmit it.  The first version was reviewed by Krill Tkhai, so
> > I keep his Reviewed-by tag since there is no change to the patch except the
> > commit log.
> >
> > So, would you please reconsider this patch?
> >
> > v2: Updated the commit log to reflect some test result and latest discussion
> >
> >  mm/ksm.c | 29 +++++++++++++++++++++++++----
> >  1 file changed, 25 insertions(+), 4 deletions(-)
> >
> > diff --git a/mm/ksm.c b/mm/ksm.c
> > index 6c48ad1..f66405c 100644
> > --- a/mm/ksm.c
> > +++ b/mm/ksm.c
> > @@ -668,7 +668,7 @@ static void remove_node_from_stable_tree(struct stable_node *stable_node)
> >  }
> >
> >  /*
> > - * get_ksm_page: checks if the page indicated by the stable node
> > + * __get_ksm_page: checks if the page indicated by the stable node
> >   * is still its ksm page, despite having held no reference to it.
> >   * In which case we can trust the content of the page, and it
> >   * returns the gotten page; but if the page has now been zapped,
> > @@ -686,7 +686,8 @@ static void remove_node_from_stable_tree(struct stable_node *stable_node)
> >   * a page to put something that might look like our key in page->mapping.
> >   * is on its way to being freed; but it is an anomaly to bear in mind.
> >   */
> > -static struct page *get_ksm_page(struct stable_node *stable_node, bool lock_it)
> > +static struct page *__get_ksm_page(struct stable_node *stable_node,
> > +                                bool lock_it, bool async)
> >  {
> >       struct page *page;
> >       void *expected_mapping;
> > @@ -729,7 +730,14 @@ static struct page *get_ksm_page(struct stable_node *stable_node, bool lock_it)
> >       }
> >
> >       if (lock_it) {
> > -             lock_page(page);
> > +             if (async) {
> > +                     if (!trylock_page(page)) {
> > +                             put_page(page);
> > +                             return ERR_PTR(-EBUSY);
> > +                     }
> > +             } else
> > +                     lock_page(page);
> > +
> >               if (READ_ONCE(page->mapping) != expected_mapping) {
> >                       unlock_page(page);
> >                       put_page(page);
> > @@ -752,6 +760,11 @@ static struct page *get_ksm_page(struct stable_node *stable_node, bool lock_it)
> >       return NULL;
> >  }
> >
> > +static struct page *get_ksm_page(struct stable_node *stable_node, bool lock_it)
> > +{
> > +     return __get_ksm_page(stable_node, lock_it, false);
> > +}
> > +
> >  /*
> >   * Removing rmap_item from stable or unstable tree.
> >   * This function will clean the information from the stable/unstable tree.
> > @@ -1673,7 +1686,11 @@ static struct page *stable_tree_search(struct page *page)
> >                        * It would be more elegant to return stable_node
> >                        * than kpage, but that involves more changes.
> >                        */
> > -                     tree_page = get_ksm_page(stable_node_dup, true);
> > +                     tree_page = __get_ksm_page(stable_node_dup, true, true);
>
> Hi Yang,
>
> The bools are stacking up: now you've got two, and the above invocation is no longer
> understandable on its own. At this point, we normally shift to flags and/or an
> enum.
>
> Also, I see little value in adding a stub function here, so how about something more
> like the following approximation (untested, and changes to callers are not shown):
>
> diff --git a/mm/ksm.c b/mm/ksm.c
> index 6c48ad13b4c9..8390b7905b44 100644
> --- a/mm/ksm.c
> +++ b/mm/ksm.c
> @@ -667,6 +667,12 @@ static void remove_node_from_stable_tree(struct stable_node *stable_node)
>         free_stable_node(stable_node);
>  }
>
> +typedef enum {
> +       GET_KSM_PAGE_NORMAL,
> +       GET_KSM_PAGE_LOCK_PAGE,
> +       GET_KSM_PAGE_TRYLOCK_PAGE
> +} get_ksm_page_t;
> +
>  /*
>   * get_ksm_page: checks if the page indicated by the stable node
>   * is still its ksm page, despite having held no reference to it.
> @@ -686,7 +692,8 @@ static void remove_node_from_stable_tree(struct stable_node *stable_node)
>   * a page to put something that might look like our key in page->mapping.
>   * is on its way to being freed; but it is an anomaly to bear in mind.
>   */
> -static struct page *get_ksm_page(struct stable_node *stable_node, bool lock_it)
> +static struct page *get_ksm_page(struct stable_node *stable_node,
> +                                get_ksm_page_t flags)
>  {
>         struct page *page;
>         void *expected_mapping;
> @@ -728,8 +735,17 @@ static struct page *get_ksm_page(struct stable_node *stable_node, bool lock_it)
>                 goto stale;
>         }
>
> -       if (lock_it) {
> +       if (flags == GET_KSM_PAGE_TRYLOCK_PAGE) {
> +               if (!trylock_page(page)) {
> +                       put_page(page);
> +                       return ERR_PTR(-EBUSY);
> +               }
> +       } else if (flags == GET_KSM_PAGE_LOCK_PAGE) {
>                 lock_page(page);
> +       }
> +
> +       if (flags == GET_KSM_PAGE_LOCK_PAGE ||
> +           flags == GET_KSM_PAGE_TRYLOCK_PAGE) {
>                 if (READ_ONCE(page->mapping) != expected_mapping) {
>                         unlock_page(page);
>                         put_page(page);
>
>
> thanks,
> --
> John Hubbard
> NVIDIA
>
> > +
> > +                     if (PTR_ERR(tree_page) == -EBUSY)
> > +                             return ERR_PTR(-EBUSY);
> > +
> >                       if (unlikely(!tree_page))
> >                               /*
> >                                * The tree may have been rebalanced,
> > @@ -2060,6 +2077,10 @@ static void cmp_and_merge_page(struct page *page, struct rmap_item *rmap_item)
> >
> >       /* We first start with searching the page inside the stable tree */
> >       kpage = stable_tree_search(page);
> > +
> > +     if (PTR_ERR(kpage) == -EBUSY)
> > +             return;
> > +
> >       if (kpage == page && rmap_item->head == stable_node) {
> >               put_page(kpage);
> >               return;
> >
>

