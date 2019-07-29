Return-Path: <SRS0=FoEm=V2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3351CC433FF
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 08:06:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DFCFC20693
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 08:06:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="LB/VimNW"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DFCFC20693
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 72CD88E0003; Mon, 29 Jul 2019 04:06:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6DCD68E0002; Mon, 29 Jul 2019 04:06:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5CD758E0003; Mon, 29 Jul 2019 04:06:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f197.google.com (mail-lj1-f197.google.com [209.85.208.197])
	by kanga.kvack.org (Postfix) with ESMTP id EF4318E0002
	for <linux-mm@kvack.org>; Mon, 29 Jul 2019 04:06:13 -0400 (EDT)
Received: by mail-lj1-f197.google.com with SMTP id e16so13103241lja.23
        for <linux-mm@kvack.org>; Mon, 29 Jul 2019 01:06:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=q+5I/p/Nycgrz3gMKuzpkFKzO+GKwckGcbd0BiK6zG0=;
        b=sfflCX/Hdzt+EzlnD4fRfVOcva+9ElN/rpxhBzM9Ar2PfAS7PP7PEM95fpplVaiJz+
         TGa1WnobRCxrfK8CdWnUuYlx/MZjezVXscyWHrTZL1UyqRm2e8EHrXficoMmha0h+eSw
         aGSYDNhsgIeL0h1ox9NdHMwvaIWCifgejn+Je78nT6yqSuiZEpLwWsAdkM5p22mTcBLV
         E3GuW02D98qVwub61GjPtsN8nXzbH35INq33Q3vhKocC/J/qYrFi0UfdHMCPyf8oTH5e
         Iu2cZ+6GL0ahd8yTYzwxUDVEN5PFl485bKbdXruaqr6LqHV1bhfMpMOs4BGZQog1UYmz
         oP+Q==
X-Gm-Message-State: APjAAAV/+6C9v19ibCdb+mbYmuXBccubLYaCF5cdtoKTOUnRhO2mtI6d
	duetPC3Pvnf8QlVaa9SrGebiIv3WLwPzuIeCOGYDWQVL9pANDQJNminxL4UJM0ol3yFsggQ8g1B
	kMN1ArNiV3IGW0YHoWvrEarZi59Vg854KH1Q28jHG8I0dsPUCl2XAs/3Z6C3HhtNhmQ==
X-Received: by 2002:a2e:b0c4:: with SMTP id g4mr39771802ljl.155.1564387573137;
        Mon, 29 Jul 2019 01:06:13 -0700 (PDT)
X-Received: by 2002:a2e:b0c4:: with SMTP id g4mr39771751ljl.155.1564387572126;
        Mon, 29 Jul 2019 01:06:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564387572; cv=none;
        d=google.com; s=arc-20160816;
        b=y1rcJ4ZymZ6L9LH9OXoa+qMIsqiea3hmHXouu73MT+LVHaSXTrT0uXgtAduK8iwR6l
         TVbj85M+ahung+F0+BxbPXBoG3LDrIGp8hONd8BiW82y6fL3O3pCA8pZHRzzwd5feWio
         Dk30JxIDYleFLjFlPqazA3Bq91nN/EpqUTeQnMGvqYvX4Bcq7d3VmbuaTFDAJJKSjC8U
         nfsxp/Y2VuhhOmb38mcMVyHhMKN8GsL1v8n7cayTQjOhEUbLtZth8uYhLcFdxlrRX1y5
         Sa7SLd8L63ISxm9Vv4I38hf4H148GHNBtAvPDQdRU1D4rMMLOqB09ivThxJETx0Cp0vX
         1Leg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=q+5I/p/Nycgrz3gMKuzpkFKzO+GKwckGcbd0BiK6zG0=;
        b=V1w9lC/tDnXDbGEwNVECp70nRweXSoX3YxODQA8dH64CoDGKRE2ri3DyFe2ulVto7Z
         fqVS3H6oixexUYTqO5wA0ZG+oKDw6SEtFfLMbFQPU/KK1M7JoFaYVk9RUm7sb7qispK8
         DB5+HuSEje6amTFaBitPQef6lDMeXqnewzREzgxaUUpcP64V9LbGe/8cgfcXmukKd/4C
         sXaUNMHEmoCSkSZdVSGr8f0b2aGFOXy0ybjEipZY5Lf7xAFBPuBP/gUr0qjBRfk8fDD7
         L9lW9SrXl0DONPncrpVOVlvLhYpRuFD7/SVciTdTEkUHLk+v1L1WvdjYfP1t6XJlGFaS
         OByQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="LB/VimNW";
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z5sor32426122ljc.29.2019.07.29.01.06.11
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 29 Jul 2019 01:06:12 -0700 (PDT)
Received-SPF: pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="LB/VimNW";
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=q+5I/p/Nycgrz3gMKuzpkFKzO+GKwckGcbd0BiK6zG0=;
        b=LB/VimNWk6JAU5/0EApO5jynRztUXjN0TlosFKaq/kodUwFVw0PewLEs0V68CR581J
         4JlwzGL1H/RgmulXJE0tUnfGIbnAg+sboDZsIgfwmu5zl5BuBomBD0GnsmCfvsD96P7c
         81a3Itk5111vnbz+3jlZUj6HwRjk603ngMwMhwxGZtZyazLVFIh7gk8zwdo6uMokLrwo
         BxlrHYeLTM7lyQGhdhkpGxhnpuX6jxPYtIgh6+bxdTukqfk38gWfWBmqLnsQhkJfiAW1
         gHJBp5gXUR/8JTLCOXBmIl6aYSDoYBFQWfAph63tY1YwjFkjyQjdiesYPJO7SBVp2XXA
         p9xQ==
X-Google-Smtp-Source: APXvYqz0P76ouodZLQJ+67CUBUqcRzH9RJUfbxlKZqHe7C7pDJbANNDWcvHTrBJed/XvhfMm/hXZdRRCBXnmIBaGkUs=
X-Received: by 2002:a2e:93cc:: with SMTP id p12mr57966349ljh.11.1564387571686;
 Mon, 29 Jul 2019 01:06:11 -0700 (PDT)
MIME-Version: 1.0
References: <20190215024830.GA26477@jordon-HP-15-Notebook-PC> <20190728180611.GA20589@mail-itl>
In-Reply-To: <20190728180611.GA20589@mail-itl>
From: Souptick Joarder <jrdr.linux@gmail.com>
Date: Mon, 29 Jul 2019 13:35:59 +0530
Message-ID: <CAFqt6zaMDnpB-RuapQAyYAub1t7oSdHH_pTD=f5k-s327ZvqMA@mail.gmail.com>
Subject: Re: [Xen-devel] [PATCH v4 8/9] xen/gntdev.c: Convert to use vm_map_pages()
To: =?UTF-8?Q?Marek_Marczykowski=2DG=C3=B3recki?= <marmarek@invisiblethingslab.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <willy@infradead.org>, 
	Michal Hocko <mhocko@suse.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, 
	Juergen Gross <jgross@suse.com>, Russell King - ARM Linux <linux@armlinux.org.uk>, robin.murphy@arm.com, 
	xen-devel@lists.xenproject.org, linux-kernel@vger.kernel.org, 
	Linux-MM <linux-mm@kvack.org>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Jul 28, 2019 at 11:36 PM Marek Marczykowski-G=C3=B3recki
<marmarek@invisiblethingslab.com> wrote:
>
> On Fri, Feb 15, 2019 at 08:18:31AM +0530, Souptick Joarder wrote:
> > Convert to use vm_map_pages() to map range of kernel
> > memory to user vma.
> >
> > map->count is passed to vm_map_pages() and internal API
> > verify map->count against count ( count =3D vma_pages(vma))
> > for page array boundary overrun condition.
>
> This commit breaks gntdev driver. If vma->vm_pgoff > 0, vm_map_pages
> will:
>  - use map->pages starting at vma->vm_pgoff instead of 0

The actual code ignores vma->vm_pgoff > 0 scenario and mapped
the entire map->pages[i]. Why the entire map->pages[i] needs to be mapped
if vma->vm_pgoff > 0 (in original code) ?

are you referring to set vma->vm_pgoff =3D 0 irrespective of value passed
from user space ? If yes, using vm_map_pages_zero() is an alternate
option.


>  - verify map->count against vma_pages()+vma->vm_pgoff instead of just
>    vma_pages().

In original code ->

diff --git a/drivers/xen/gntdev.c b/drivers/xen/gntdev.c
index 559d4b7f807d..469dfbd6cf90 100644
--- a/drivers/xen/gntdev.c
+++ b/drivers/xen/gntdev.c
@@ -1084,7 +1084,7 @@ static int gntdev_mmap(struct file *flip, struct
vm_area_struct *vma)
int index =3D vma->vm_pgoff;
int count =3D vma_pages(vma);

Count is user passed value.

struct gntdev_grant_map *map;
- int i, err =3D -EINVAL;
+ int err =3D -EINVAL;
if ((vma->vm_flags & VM_WRITE) && !(vma->vm_flags & VM_SHARED))
return -EINVAL;
@@ -1145,12 +1145,9 @@ static int gntdev_mmap(struct file *flip,
struct vm_area_struct *vma)
goto out_put_map;
if (!use_ptemod) {
- for (i =3D 0; i < count; i++) {
- err =3D vm_insert_page(vma, vma->vm_start + i*PAGE_SIZE,
- map->pages[i]);

and when count > i , we end up with trying to map memory outside
boundary of map->pages[i], which was not correct.

- if (err)
- goto out_put_map;
- }
+ err =3D vm_map_pages(vma, map->pages, map->count);
+ if (err)
+ goto out_put_map;

With this commit, inside __vm_map_pages(), we have addressed this scenario.

+static int __vm_map_pages(struct vm_area_struct *vma, struct page **pages,
+ unsigned long num, unsigned long offset)
+{
+ unsigned long count =3D vma_pages(vma);
+ unsigned long uaddr =3D vma->vm_start;
+ int ret, i;
+
+ /* Fail if the user requested offset is beyond the end of the object */
+ if (offset > num)
+ return -ENXIO;
+
+ /* Fail if the user requested size exceeds available object size */
+ if (count > num - offset)
+ return -ENXIO;

By checking count > num -offset. (considering vma->vm_pgoff !=3D 0 as well)=
.
So we will never cross the boundary of map->pages[i].


>
> In practice, this breaks using a single gntdev FD for mapping multiple
> grants.

How ?

>
> It looks like vm_map_pages() is not a good fit for this code and IMO it
> should be reverted.

Did you hit any issue around this code in real time ?


>
> > Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>
> > Reviewed-by: Boris Ostrovsky <boris.ostrovsky@oracle.com>
> > ---
> >  drivers/xen/gntdev.c | 11 ++++-------
> >  1 file changed, 4 insertions(+), 7 deletions(-)
> >
> > diff --git a/drivers/xen/gntdev.c b/drivers/xen/gntdev.c
> > index 5efc5ee..5d64262 100644
> > --- a/drivers/xen/gntdev.c
> > +++ b/drivers/xen/gntdev.c
> > @@ -1084,7 +1084,7 @@ static int gntdev_mmap(struct file *flip, struct =
vm_area_struct *vma)
> >       int index =3D vma->vm_pgoff;
> >       int count =3D vma_pages(vma);
> >       struct gntdev_grant_map *map;
> > -     int i, err =3D -EINVAL;
> > +     int err =3D -EINVAL;
> >
> >       if ((vma->vm_flags & VM_WRITE) && !(vma->vm_flags & VM_SHARED))
> >               return -EINVAL;
> > @@ -1145,12 +1145,9 @@ static int gntdev_mmap(struct file *flip, struct=
 vm_area_struct *vma)
> >               goto out_put_map;
> >
> >       if (!use_ptemod) {
> > -             for (i =3D 0; i < count; i++) {
> > -                     err =3D vm_insert_page(vma, vma->vm_start + i*PAG=
E_SIZE,
> > -                             map->pages[i]);
> > -                     if (err)
> > -                             goto out_put_map;
> > -             }
> > +             err =3D vm_map_pages(vma, map->pages, map->count);
> > +             if (err)
> > +                     goto out_put_map;
> >       } else {
> >  #ifdef CONFIG_X86
> >               /*
>
> --
> Best Regards,
> Marek Marczykowski-G=C3=B3recki
> Invisible Things Lab
> A: Because it messes up the order in which people normally read text.
> Q: Why is top-posting such a bad thing?

