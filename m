Return-Path: <SRS0=6aBQ=PK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4B766C43387
	for <linux-mm@archiver.kernel.org>; Wed,  2 Jan 2019 18:54:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 02CD9218D3
	for <linux-mm@archiver.kernel.org>; Wed,  2 Jan 2019 18:54:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="uF27zpcS"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 02CD9218D3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 90F208E003C; Wed,  2 Jan 2019 13:54:31 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8BE0D8E0002; Wed,  2 Jan 2019 13:54:31 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7D4C28E003C; Wed,  2 Jan 2019 13:54:31 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f198.google.com (mail-lj1-f198.google.com [209.85.208.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0E1758E0002
	for <linux-mm@kvack.org>; Wed,  2 Jan 2019 13:54:31 -0500 (EST)
Received: by mail-lj1-f198.google.com with SMTP id t7-v6so9140125ljg.9
        for <linux-mm@kvack.org>; Wed, 02 Jan 2019 10:54:30 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=H0TThPyKzDm2TNNQAjf6clRHUIGAL0tpEQheWlPEAJg=;
        b=n+P55lLk9CUTiWXz5eDoKqOOPnY816gPjTIJMp4IF2654Vt8Tn4fP0vIB+p7MyEmbw
         pjq3L2SWRs9DBM3SjW6GTOx+N10mqGTKmTMB1iFiK6NsT9mOcCurjSJaVlq6zwS4eGKM
         xpSAsgd6vuMESWystk+1DyxHqcUUewakaHGHQpeXTvrI3oeLD3TpMg+lNiYcIdzYSYjZ
         +b2arN0lJuVN7zEQng+UEO6kAzHLcZ98TvQm3BduXIF07Wis2ksWi9/qXV3HhpuiiMYX
         dA4MD8jOg97Nek/rKLVept7djJAXxklqJgfJCckjgyJvD3vKh4CWnlKUNqrWbENa1GZ3
         wSGA==
X-Gm-Message-State: AJcUukdP58dcsTjo7hRruf1swqLHROEGSUuOU9hNawwmHz5k++UbDGVu
	MMvZyfbkGwS8aZDEDTjE6edobyT0VDWkxe2g9w28bJMBgJK+RwtnBdMpy93+AMk6E6zWeRuq+xn
	rmFWco7Js1zjfUtQkun33c1cXjoBsI326374TIDSQNP1g88sZU73BA8YDQEHLtjuNQ7rl2A8hhU
	Jo8M5AG15uvb+y1d5tEs7wMUYPdyY4wm82hVnFDbXgFFZYVJ/FZ0kHJhcTiI1O/GqGGpC/d+EqQ
	HQoLXvK0w638ARKcDKBBB8c/K6rFt2+7eq+OpqqBHQUyVeMl1EUV47K8UKEb84WVo7H+Y8wZPzY
	uN7JtL8qIowaEAhe+1VTcSl0aGlihCx/Qs7aEuC9RAUQh/1p54Hzbt6PBw5sQ2r/xKOYTRy+mUb
	n
X-Received: by 2002:a2e:2e1a:: with SMTP id u26-v6mr4281214lju.8.1546455270279;
        Wed, 02 Jan 2019 10:54:30 -0800 (PST)
X-Received: by 2002:a2e:2e1a:: with SMTP id u26-v6mr4281191lju.8.1546455269199;
        Wed, 02 Jan 2019 10:54:29 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1546455269; cv=none;
        d=google.com; s=arc-20160816;
        b=GhfdIcGsYytdQlafQGitt98wHAxSdzjSM4eRvZmrzwphNlQk5OH387w1QXrazFOwLA
         sVpMLyhdY7R6V4c1W/d9Q1AvgjgIoQx6J7Gvp2FJRIgwP0DhIWXfvR5SV77ryGsFZulN
         GJmXU/amtvnIePX4Wupf7J/5MKTZqDiun8ZE98Mm4VvlGtbV8vw7iM1ii/42rVZ0pi+5
         ccIB4CUuYkUkA2fl91WwnwKiLa+9bsbKQOknckXHQf6xMrT4gmtfg7g4D6HjOFHo+h++
         H65GdjwiU5/QF+CQOSbYdhitCuTL1gLqlrQagKjbJYLhkNJdNsh+Ws1BmB2qv5xqPl1g
         agYg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=H0TThPyKzDm2TNNQAjf6clRHUIGAL0tpEQheWlPEAJg=;
        b=Xj5b+X4cx1oPFz2OJhuxIITR/wHPPpEi5XFyhhsJu2zC6NtiIibik6GTAoNgp8pIPk
         thcuS/nZh7tGme7adlx5ILnA/8S0OJ6D2YbLte1EuHyii0jSYSotVJTtPmAcD/EM6+fP
         RAh2oUYZM7xjofXiw69LNVjgDqCEz61IAzr7ZakhATrnWvjQgXHykuK0yVkzVe/pUOPa
         4CoNwKAY+8xJsDhebBrAvw/kWQgXCCpOthWw+t2Tx3u858gcwKgo5cQqndLN/f8Hb3c9
         /GjLTRCUIlGHzkVfvhUSuPX8vb0/qjHRlhDNU2BA0i9g4iMYuLOE3ow+PWRjWJynIisu
         I8zw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=uF27zpcS;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n5sor13149193lfl.69.2019.01.02.10.54.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 02 Jan 2019 10:54:29 -0800 (PST)
Received-SPF: pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=uF27zpcS;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=H0TThPyKzDm2TNNQAjf6clRHUIGAL0tpEQheWlPEAJg=;
        b=uF27zpcSxW4FK/pFshlTh+C0RI25exWJVydsIqaXcpteuwt9BR0V0JVVLsT0xWR6ZX
         g34IEDWcvEGjCactyz1Sv97ErjtVwfKP5NVOHe1wgRd8FqHH5lWvcM6o2GaN+zmc4Yuo
         VemKcc5QSvuWVU3fsD1pEpZOz4mNVt8odaCkVAHB3faHi6SVgWu8OuCw+W7GreXTi8Dr
         bHiEXiTUucccDC43vIi2SP73VElNrxqF0uiXFginYmDFutOucjJM4mw66cZK+TLeMASc
         WSbl6pgK8XKwkAGm95XvFRNAqStJAJUtfO5kkM6N2nqceOkyZunuveZIY6jZ2SjSdF4J
         zlww==
X-Google-Smtp-Source: AFSGD/Wev/hvRV8NLc2yKT9L/LNczKxpRPqerhlYFArA1blFSqrdHd55CBN/ruQrSF+dO6aRrX0+SWiZLv9vYKAYDmo=
X-Received: by 2002:a19:c70a:: with SMTP id x10mr21717597lff.88.1546455268476;
 Wed, 02 Jan 2019 10:54:28 -0800 (PST)
MIME-Version: 1.0
References: <20181224132751.GA22184@jordon-HP-15-Notebook-PC>
In-Reply-To: <20181224132751.GA22184@jordon-HP-15-Notebook-PC>
From: Souptick Joarder <jrdr.linux@gmail.com>
Date: Thu, 3 Jan 2019 00:28:19 +0530
Message-ID:
 <CAFqt6za2_BOZaynNV2iVkLCjadzyR_bOJog=R6j43dDCDwgFzw@mail.gmail.com>
Subject: Re: [PATCH v5 8/9] xen/gntdev.c: Convert to use vm_insert_range
To: Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <willy@infradead.org>, 
	Michal Hocko <mhocko@suse.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, 
	Juergen Gross <jgross@suse.com>, Russell King - ARM Linux <linux@armlinux.org.uk>, robin.murphy@arm.com
Cc: xen-devel@lists.xenproject.org, linux-kernel@vger.kernel.org, 
	Linux-MM <linux-mm@kvack.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190102185819.NA702bx5mOgRL0RjCLE3PgKESyy9oBx3boISGMim0mc@z>

On Mon, Dec 24, 2018 at 6:53 PM Souptick Joarder <jrdr.linux@gmail.com> wrote:
>
> Convert to use vm_insert_range() to map range of kernel
> memory to user vma.
>
> Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>
> Reviewed-by: Matthew Wilcox <willy@infradead.org>
> Reviewed-by: Boris Ostrovsky <boris.ostrovsky@oracle.com>
> ---
>  drivers/xen/gntdev.c | 11 ++++-------
>  1 file changed, 4 insertions(+), 7 deletions(-)
>
> diff --git a/drivers/xen/gntdev.c b/drivers/xen/gntdev.c
> index b0b02a5..430d4cb 100644
> --- a/drivers/xen/gntdev.c
> +++ b/drivers/xen/gntdev.c
> @@ -1084,7 +1084,7 @@ static int gntdev_mmap(struct file *flip, struct vm_area_struct *vma)
>         int index = vma->vm_pgoff;
>         int count = vma_pages(vma);
>         struct gntdev_grant_map *map;
> -       int i, err = -EINVAL;
> +       int err = -EINVAL;
>
>         if ((vma->vm_flags & VM_WRITE) && !(vma->vm_flags & VM_SHARED))
>                 return -EINVAL;
> @@ -1145,12 +1145,9 @@ static int gntdev_mmap(struct file *flip, struct vm_area_struct *vma)
>                 goto out_put_map;
>
>         if (!use_ptemod) {
> -               for (i = 0; i < count; i++) {
> -                       err = vm_insert_page(vma, vma->vm_start + i*PAGE_SIZE,
> -                               map->pages[i]);
> -                       if (err)
> -                               goto out_put_map;
> -               }

Looking into the original code, the loop should run from i =0 to *i <
map->count*.
There is no error check for *count > map->count* and we might end up
overrun the map->pages[i] boundary.

While converting this code with suggested vm_insert_range(), this can be fixed.


> +               err = vm_insert_range(vma, vma->vm_start, map->pages, count);
> +               if (err)
> +                       goto out_put_map;
>         } else {
>  #ifdef CONFIG_X86
>                 /*
> --
> 1.9.1
>

