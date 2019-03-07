Return-Path: <SRS0=NBIx=RK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 188A3C10F03
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 18:30:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B1131208E4
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 18:30:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ZBG6fE2u"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B1131208E4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3C1BE8E0003; Thu,  7 Mar 2019 13:30:17 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 349BA8E0002; Thu,  7 Mar 2019 13:30:17 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1C46F8E0003; Thu,  7 Mar 2019 13:30:17 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id E4BF38E0002
	for <linux-mm@kvack.org>; Thu,  7 Mar 2019 13:30:16 -0500 (EST)
Received: by mail-io1-f69.google.com with SMTP id v3so13666776iol.3
        for <linux-mm@kvack.org>; Thu, 07 Mar 2019 10:30:16 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=8iNVpkGvBcGgnJT//aNEQWPP19vn7t46ynK2FCTF4Ag=;
        b=lHnkOZdCTMJzBryhGYiKIueZKFXUfMS9Q8NELVXcNcK6j07xiILpc6TMay9fDCQiEi
         RDgWxEo7MoxoD2eiI6kYW00LZOZYVBDW2+YP+YhVYfHwKDluq3xjM6m9vu1Nkq6l6eN+
         N6EYeMwDda7/Ru5ZFKRz5x9cFnuA39mnGgzPAEh7iN45Mh0jy0hKX6R2ZBI1uEBkV56b
         HkvW1e0YJceaopcExs4TsmLLNUn+3toZes+ER9+kZ75wr8mg20lH4SUwp9cNqUJWgQ97
         UiPkqdm7fmwKUOhdZNlqyM01FbhghqBfSfaqXbmMP80QWGtozUzhLF5WdF1oOD0bVmJb
         cwUA==
X-Gm-Message-State: APjAAAW/KtHMKZe8oYZxGqfpHd1+OrVfd1uzXgVzH+01TCZ5gWqQgC0r
	cb1nvtljfb1TzSJjEkTozOF30McgslJ1y6foFYWYNM+OAkxv9fyovzhYNYkthMwtwXnPz823ZT3
	3LjfRf1+NURRAx0qLL4coRhiKBezQ24XFHY6KnWDkMyWNlKZnlZuQLY/8YIpApdCJfJ8F7hFO+i
	hMZd6LgItDcZafVxMgemmel+n8m3rV1b8LI7UXh5mRzVaHydQ8XOJpJnSFUCzZCNOGra2VBwWDE
	A91dRXtCx/5jauviLfY+Xkk3cWzWdpuV1jmpoy6bKXjnS7w0vbLyTqbKZJXIV3pVFuM29GmpfxE
	cHojJuMRHbrqsj+oFLdpACrYWUSyxGROhROUYB0uT39pul1B7TJIAI4SR/t5UxlGLAwT+iOkecB
	z
X-Received: by 2002:a24:5206:: with SMTP id d6mr6052708itb.91.1551983416646;
        Thu, 07 Mar 2019 10:30:16 -0800 (PST)
X-Received: by 2002:a24:5206:: with SMTP id d6mr6052649itb.91.1551983415490;
        Thu, 07 Mar 2019 10:30:15 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551983415; cv=none;
        d=google.com; s=arc-20160816;
        b=IzfiSg3QRyofoU99sex8jQDgEBdJgb5iEFAK16IKPywff06I/krhG4SlqfCdYeI0Ou
         mrUeSCCp71So36s7vtF671rb2bEGOcDskMPCPB2IH1euPu7w96twrW8dH948hcqD8SKI
         0rHJfytdqfCi6Abxqz8cEXEEHhbCYgF4fLNO5XPsgG24LjEjdFEnI+ml3v2FHOq7VZNu
         rwGVLw/cun7NgdskKw6au0ikhwRF5yTTalNj1WZ4K6i7gpParUaMTgk+ElOfDR7v1S+P
         TjPAB1RZUA/+xIsohopH5c5751Y72AktyE4szqSTdtROZZSdnVrUt+UmvW6n1Tjn3PU7
         JrBg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=8iNVpkGvBcGgnJT//aNEQWPP19vn7t46ynK2FCTF4Ag=;
        b=PQwOie75RkB5UR5LQrfF25nLTUpmPRPH9e+dQgDQQUY2qPeocQHGV+kdEPnTj4V1Sn
         tQPOMO07jBogyAiGoSkY++43N4QyeOJAx8FPU/1KiGpzQxLHewenFT2DwjOwfiTU0Jqc
         MwKgezl/NRhKssw7LcyE2jUGjQi0HRf6gES4pWTs0H+goyF5eh68LBKbMxakq5Tz1fwx
         TZE0YR3dnk7hvJle1qjtJ2jLvbR4nmKIC+6mg/MIO5Dhsni8NDJyUOd8be1kThHS9/Ec
         e12gDVeA9nVnwazxFJxhyj//4aeAZL6bCz0x+eNHmZGDbo/axMOYDKtWD/9GiwzcWqpr
         TyMA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ZBG6fE2u;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h16sor10647142itb.18.2019.03.07.10.30.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 07 Mar 2019 10:30:15 -0800 (PST)
Received-SPF: pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ZBG6fE2u;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=8iNVpkGvBcGgnJT//aNEQWPP19vn7t46ynK2FCTF4Ag=;
        b=ZBG6fE2uisRHMzpQfioE1Ymfbn0In3z0rYIeQLVrJtHaG0oybzEzwTNVYF372EDbj9
         YRANmt/fKftLoK4O3RRYTlVNd8t9qm8GPbdzlcrDpBJiD2UCUcZqn56KUjXYlFPEoUlG
         s0z8ziwVCw9YaGKt2KRUqGAoyOAhbOpFdMba8Mt1dBQ/6qMjw8l4ldRET5jd4GSzjOfI
         foVSxlSibAXsBI7l8OBZkmStxMDCDJeGePyR6iszH0aBfI4bT6NoNsbdI7bz9wBFqLmc
         jxr9hC4/ip/ZSJw9390pZoVp2PzVFDYYNSqLPVJXBX2pBzjFGjbqoQ286RKqmbPjeZQJ
         2e5g==
X-Google-Smtp-Source: APXvYqyLOL7A/6+gVkZoE63WKG2RUDJQrmIoU+5CAeMcf5f72A3xvjCv9t/trC3If5bhgt0GELHNoR4rH0hoRFOENWI=
X-Received: by 2002:a24:b643:: with SMTP id d3mr6345218itj.146.1551983414944;
 Thu, 07 Mar 2019 10:30:14 -0800 (PST)
MIME-Version: 1.0
References: <20190306155048.12868-1-nitesh@redhat.com> <20190306155048.12868-3-nitesh@redhat.com>
In-Reply-To: <20190306155048.12868-3-nitesh@redhat.com>
From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Thu, 7 Mar 2019 10:30:03 -0800
Message-ID: <CAKgT0UdDohCXZY3q9qhQsHw-2vKp_CAgvf2dd2e6U6KLsAkVng@mail.gmail.com>
Subject: Re: [RFC][Patch v9 2/6] KVM: Enables the kernel to isolate guest free pages
To: Nitesh Narayan Lal <nitesh@redhat.com>
Cc: kvm list <kvm@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, 
	linux-mm <linux-mm@kvack.org>, Paolo Bonzini <pbonzini@redhat.com>, lcapitulino@redhat.com, 
	pagupta@redhat.com, wei.w.wang@intel.com, 
	Yang Zhang <yang.zhang.wz@gmail.com>, Rik van Riel <riel@surriel.com>, 
	David Hildenbrand <david@redhat.com>, "Michael S. Tsirkin" <mst@redhat.com>, dodgen@google.com, 
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, dhildenb@redhat.com, 
	Andrea Arcangeli <aarcange@redhat.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 6, 2019 at 7:51 AM Nitesh Narayan Lal <nitesh@redhat.com> wrote:
>
> This patch enables the kernel to scan the per cpu array
> which carries head pages from the buddy free list of order
> FREE_PAGE_HINTING_MIN_ORDER (MAX_ORDER - 1) by
> guest_free_page_hinting().
> guest_free_page_hinting() scans the entire per cpu array by
> acquiring a zone lock corresponding to the pages which are
> being scanned. If the page is still free and present in the
> buddy it tries to isolate the page and adds it to a
> dynamically allocated array.
>
> Once this scanning process is complete and if there are any
> isolated pages added to the dynamically allocated array
> guest_free_page_report() is invoked. However, before this the
> per-cpu array index is reset so that it can continue capturing
> the pages from buddy free list.
>
> In this patch guest_free_page_report() simply releases the pages back
> to the buddy by using __free_one_page()
>
> Signed-off-by: Nitesh Narayan Lal <nitesh@redhat.com>

I'm pretty sure this code is not thread safe and has a few various issues.

> ---
>  include/linux/page_hinting.h |   5 ++
>  mm/page_alloc.c              |   2 +-
>  virt/kvm/page_hinting.c      | 154 +++++++++++++++++++++++++++++++++++
>  3 files changed, 160 insertions(+), 1 deletion(-)
>
> diff --git a/include/linux/page_hinting.h b/include/linux/page_hinting.h
> index 90254c582789..d554a2581826 100644
> --- a/include/linux/page_hinting.h
> +++ b/include/linux/page_hinting.h
> @@ -13,3 +13,8 @@
>
>  void guest_free_page_enqueue(struct page *page, int order);
>  void guest_free_page_try_hinting(void);
> +extern int __isolate_free_page(struct page *page, unsigned int order);
> +extern void __free_one_page(struct page *page, unsigned long pfn,
> +                           struct zone *zone, unsigned int order,
> +                           int migratetype);
> +void release_buddy_pages(void *obj_to_free, int entries);
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 684d047f33ee..d38b7eea207b 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -814,7 +814,7 @@ static inline int page_is_buddy(struct page *page, struct page *buddy,
>   * -- nyc
>   */
>
> -static inline void __free_one_page(struct page *page,
> +inline void __free_one_page(struct page *page,
>                 unsigned long pfn,
>                 struct zone *zone, unsigned int order,
>                 int migratetype)
> diff --git a/virt/kvm/page_hinting.c b/virt/kvm/page_hinting.c
> index 48b4b5e796b0..9885b372b5a9 100644
> --- a/virt/kvm/page_hinting.c
> +++ b/virt/kvm/page_hinting.c
> @@ -1,5 +1,9 @@
>  #include <linux/mm.h>
>  #include <linux/page_hinting.h>
> +#include <linux/page_ref.h>
> +#include <linux/kvm_host.h>
> +#include <linux/kernel.h>
> +#include <linux/sort.h>
>
>  /*
>   * struct guest_free_pages- holds array of guest freed PFN's along with an
> @@ -16,6 +20,54 @@ struct guest_free_pages {
>
>  DEFINE_PER_CPU(struct guest_free_pages, free_pages_obj);
>
> +/*
> + * struct guest_isolated_pages- holds the buddy isolated pages which are
> + * supposed to be freed by the host.
> + * @pfn: page frame number for the isolated page.
> + * @order: order of the isolated page.
> + */
> +struct guest_isolated_pages {
> +       unsigned long pfn;
> +       unsigned int order;
> +};
> +
> +void release_buddy_pages(void *obj_to_free, int entries)
> +{
> +       int i = 0;
> +       int mt = 0;
> +       struct guest_isolated_pages *isolated_pages_obj = obj_to_free;
> +
> +       while (i < entries) {
> +               struct page *page = pfn_to_page(isolated_pages_obj[i].pfn);
> +
> +               mt = get_pageblock_migratetype(page);
> +               __free_one_page(page, page_to_pfn(page), page_zone(page),
> +                               isolated_pages_obj[i].order, mt);
> +               i++;
> +       }
> +       kfree(isolated_pages_obj);
> +}

You shouldn't be accessing __free_one_page without holding the zone
lock for the page. You might consider confining yourself to one zone
worth of hints at a time. Then you can acquire the lock once, and then
return the memory you have freed.

This is one of the reasons why I am thinking maybe a bit in the page
and then spinning on that bit in arch_alloc_page might be a nice way
to get around this. Then you only have to take the zone lock when you
are finding the pages you want to hint on and setting the bit
indicating they are mid hint. Otherwise you have to take the zone lock
to pull pages out, and to put them back in and the likelihood of a
lock collision is much higher.

> +
> +void guest_free_page_report(struct guest_isolated_pages *isolated_pages_obj,
> +                           int entries)
> +{
> +       release_buddy_pages(isolated_pages_obj, entries);
> +}
> +
> +static int sort_zonenum(const void *a1, const void *b1)
> +{
> +       const unsigned long *a = a1;
> +       const unsigned long *b = b1;
> +
> +       if (page_zonenum(pfn_to_page(a[0])) > page_zonenum(pfn_to_page(b[0])))
> +               return 1;
> +
> +       if (page_zonenum(pfn_to_page(a[0])) < page_zonenum(pfn_to_page(b[0])))
> +               return -1;
> +
> +       return 0;
> +}
> +
>  struct page *get_buddy_page(struct page *page)
>  {
>         unsigned long pfn = page_to_pfn(page);
> @@ -33,9 +85,111 @@ struct page *get_buddy_page(struct page *page)
>  static void guest_free_page_hinting(void)
>  {
>         struct guest_free_pages *hinting_obj = &get_cpu_var(free_pages_obj);
> +       struct guest_isolated_pages *isolated_pages_obj;
> +       int idx = 0, ret = 0;
> +       struct zone *zone_cur, *zone_prev;
> +       unsigned long flags = 0;
> +       int hyp_idx = 0;
> +       int free_pages_idx = hinting_obj->free_pages_idx;
> +
> +       isolated_pages_obj = kmalloc(MAX_FGPT_ENTRIES *
> +                       sizeof(struct guest_isolated_pages), GFP_KERNEL);
> +       if (!isolated_pages_obj) {
> +               hinting_obj->free_pages_idx = 0;
> +               put_cpu_var(hinting_obj);
> +               return;
> +               /* return some logical error here*/
> +       }
> +
> +       sort(hinting_obj->free_page_arr, free_pages_idx,
> +            sizeof(unsigned long), sort_zonenum, NULL);
> +
> +       while (idx < free_pages_idx) {
> +               unsigned long pfn = hinting_obj->free_page_arr[idx];
> +               unsigned long pfn_end = hinting_obj->free_page_arr[idx] +
> +                       (1 << FREE_PAGE_HINTING_MIN_ORDER) - 1;
> +
> +               zone_cur = page_zone(pfn_to_page(pfn));
> +               if (idx == 0) {
> +                       zone_prev = zone_cur;
> +                       spin_lock_irqsave(&zone_cur->lock, flags);
> +               } else if (zone_prev != zone_cur) {
> +                       spin_unlock_irqrestore(&zone_prev->lock, flags);
> +                       spin_lock_irqsave(&zone_cur->lock, flags);
> +                       zone_prev = zone_cur;
> +               }
> +
> +               while (pfn <= pfn_end) {
> +                       struct page *page = pfn_to_page(pfn);
> +                       struct page *buddy_page = NULL;
> +
> +                       if (PageCompound(page)) {
> +                               struct page *head_page = compound_head(page);
> +                               unsigned long head_pfn = page_to_pfn(head_page);
> +                               unsigned int alloc_pages =
> +                                       1 << compound_order(head_page);
> +
> +                               pfn = head_pfn + alloc_pages;
> +                               continue;
> +                       }
> +

I don't think the buddy allocator has compound pages.

> +                       if (page_ref_count(page)) {
> +                               pfn++;
> +                               continue;
> +                       }
> +

A ref count of 0 doesn't mean the page isn't in use. It could be in
use by something such as SLUB for instance.

> +                       if (PageBuddy(page) && page_private(page) >=
> +                           FREE_PAGE_HINTING_MIN_ORDER) {
> +                               int buddy_order = page_private(page);
> +
> +                               ret = __isolate_free_page(page, buddy_order);
> +                               if (ret) {
> +                                       isolated_pages_obj[hyp_idx].pfn = pfn;
> +                                       isolated_pages_obj[hyp_idx].order =
> +                                                               buddy_order;
> +                                       hyp_idx += 1;
> +                               }
> +                               pfn = pfn + (1 << buddy_order);
> +                               continue;
> +                       }
> +

So this is where things start to get ugly. Basically because we were
acquiring the hints when they were freed we end up needing to check
either this page, and the PFN for all of the higher order pages this
page could be a part of. Since we are currently limiting ourselves to
MAX_ORDER - 1 it shouldn't be too expensive. I don't recall if your
get_buddy_page already had that limitation coded in but we should
probably look at doing that there. Then we can just skip the PageBuddy
check up here and have it automatically start walking all pages your
original page could be a part of looking for the highest page order
that might still be free.

> +                       buddy_page = get_buddy_page(page);
> +                       if (buddy_page && page_private(buddy_page) >=
> +                           FREE_PAGE_HINTING_MIN_ORDER) {
> +                               int buddy_order = page_private(buddy_page);
> +
> +                               ret = __isolate_free_page(buddy_page,
> +                                                         buddy_order);
> +                               if (ret) {
> +                                       unsigned long buddy_pfn =
> +                                               page_to_pfn(buddy_page);
> +
> +                                       isolated_pages_obj[hyp_idx].pfn =
> +                                                               buddy_pfn;
> +                                       isolated_pages_obj[hyp_idx].order =
> +                                                               buddy_order;
> +                                       hyp_idx += 1;
> +                               }
> +                               pfn = page_to_pfn(buddy_page) +
> +                                       (1 << buddy_order);
> +                               continue;
> +                       }

This is essentially just a duplicate of the code above. As I mentioned
before it would probably make sense to just combine this block with
that one.

> +                       pfn++;
> +               }
> +               hinting_obj->free_page_arr[idx] = 0;
> +               idx++;
> +               if (idx == free_pages_idx)
> +                       spin_unlock_irqrestore(&zone_cur->lock, flags);
> +       }
>
>         hinting_obj->free_pages_idx = 0;
>         put_cpu_var(hinting_obj);
> +
> +       if (hyp_idx > 0)
> +               guest_free_page_report(isolated_pages_obj, hyp_idx);
> +       else
> +               kfree(isolated_pages_obj);
> +               /* return some logical error here*/
>  }
>
>  int if_exist(struct page *page)
> --
> 2.17.2
>

