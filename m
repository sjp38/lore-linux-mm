Return-Path: <SRS0=hkLx=PX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 46513C43444
	for <linux-mm@archiver.kernel.org>; Tue, 15 Jan 2019 04:50:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 063BC20651
	for <linux-mm@archiver.kernel.org>; Tue, 15 Jan 2019 04:50:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="mVtcuV0E"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 063BC20651
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 97F938E0003; Mon, 14 Jan 2019 23:50:11 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 906F48E0002; Mon, 14 Jan 2019 23:50:11 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7A95C8E0003; Mon, 14 Jan 2019 23:50:11 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f199.google.com (mail-lj1-f199.google.com [209.85.208.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0804D8E0002
	for <linux-mm@kvack.org>; Mon, 14 Jan 2019 23:50:11 -0500 (EST)
Received: by mail-lj1-f199.google.com with SMTP id e12-v6so375368ljb.18
        for <linux-mm@kvack.org>; Mon, 14 Jan 2019 20:50:10 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=3TXiWK8V2OmVXxJRMbWQxDG/DyuoOV26hjhztUIr7v0=;
        b=RfYStl2Y8vgi3nRrdZyatTYZ80mGv82ElYTzvqZDLNotRtQFALE/K5XmBOw+73k43z
         nyxYuqZrqnVuYcRizRI+oGUSWnujv7ISm6b7oydOldr0TQyu06hAyVG5PmrZfuxl118G
         FXcrfltt80Lbj+daa+THmsk3qMnTTyLQfhCFb1dhWmnUK9ozmouo8rDuTVtpFR6DEOXo
         zFQMb5IpjcUWxpsHngSopMDoYm0R+HC60wraXMpGPXA7VW30bMMSuReF0Q/So9LFvqh2
         8lwiH/FqLJyDEzMrvJlOeeCfjserPXU/C6Y7PQDfDCiWXHeRKU0UzpSVuwVMO03joUuv
         dC/Q==
X-Gm-Message-State: AJcUukcDQnb1I2rkbR3Qxykxl12HoznCxfAeibbK8Q7TmtwDjRHKXjzk
	mxH5sJ9CkB0nsBYJFqWb9USngr4mF/oDG1BONiSenjzxfiGb2CvsdqJLQ3v5kbhYVXaKeuE0kyU
	6j19buY23u6iHW454I4DUv1BNdy4Elv+t6AOimciJmPGKLxDznVKcDjBZyaxOdfBJYUVvK1nLDu
	cqFXJGyrc6zqxMcy+1XMgno9Ugv9ew4FODf49kRRigaMNVid43oi6SKdG6p2fiQgCv/eVhiPpJC
	gniyaY3pZcRGh52bDVVahGj3JDhKOlXokGlzBV+a9FvZZrzI+pRblk3+cdLT5CETLlCJt8uevWp
	dlVUoaiOVE+IAR8CLkWJ603WV1ZjgZDqUH+D/FUcvcVaFYHnJ2kJAjKRyAgvR7ICcbDtTXWWlNp
	x
X-Received: by 2002:a2e:5747:: with SMTP id r7-v6mr1303123ljd.141.1547527810098;
        Mon, 14 Jan 2019 20:50:10 -0800 (PST)
X-Received: by 2002:a2e:5747:: with SMTP id r7-v6mr1303079ljd.141.1547527808984;
        Mon, 14 Jan 2019 20:50:08 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547527808; cv=none;
        d=google.com; s=arc-20160816;
        b=e8OFuHhFGWsJ4sO5N4l6U6NAlltKo5R/FR35GnmsYIUEqh+4yFOesTC21aqCH6vWlr
         1kgdysNpB3c6uz6TXCDTmlKE69alO4LsIpP6sgRBs6TzQddhLd+KMRa6LkrRhhZBXO12
         jPJCtvdegKHpVYhNQu37UPINHYMzsqvKdnPLRQlxRaDpFZaXzPx80nHoNkW22IUv8o3U
         jYQS/7knBqjXvxBri6VqkLJx721jEFDn/FpUEFxL55aBGSpjhBgJwpTwJeewaacTYEXF
         s4Mh2OOUN7QWG1wPX3y9tc4Ug7MdcIP95cJgBp3wW8SeityShHUZG4aG6FkHZeSmdmM5
         WQDQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=3TXiWK8V2OmVXxJRMbWQxDG/DyuoOV26hjhztUIr7v0=;
        b=Zi8qQ12D2p3g2POtiI/pafm+LIOah+EgLN6NlfVzsGQm4Xz5RJv0EbcIAHDw43zvaQ
         IzrtF3O1gIJSpijcEareHRjyN9OvSEuNmmkLbIn99i9+HTNTboiUfKt4xOPP8ONQV4aT
         SC29+2vwkHEa8mSbn/42TOMQ+A3WyZJBSPZcTXRFEO+pGvQi4r0wOR0UwtlyZbJMKq9K
         9ohTNoQsRvVPlLOD1N8IkOxQ3VncoXtZkeehFmCfiEJ9WqNcadsCbNqt/G0SY3mpLFi1
         8lZM4Yu5OmUc0Z5W2DR31dE8qnxlgVKVMa3DtgTqWXvpHtNgFerFAPA9NxCcoUKg9cAO
         9rVQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=mVtcuV0E;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o4sor761449lfl.63.2019.01.14.20.50.08
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 14 Jan 2019 20:50:08 -0800 (PST)
Received-SPF: pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=mVtcuV0E;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=3TXiWK8V2OmVXxJRMbWQxDG/DyuoOV26hjhztUIr7v0=;
        b=mVtcuV0EWzi7waFPQ8kYoJPyXBr+5pYoBCie6M0hgYyXy7vhQ5az3gqJxtEbxr3nn2
         j9ilWv71hMMplMbZtgb43pPMZXzFr7wx5xRxPS8DNzutWYmyB9EbCwsRsuXMufbg0xyR
         /YEVGqozNiko6lxpg06VLAT4fpTuQZmDYLb+sIUstV44HcikXtqaXUTSG9GTURBiUSNA
         8BYjInM+97RsYzeR70yuKV67ybVWP0xN7Rx/tFxF+bbrHmJYj33wSR5ZPzMHcXDr0m+1
         2a6FY+nVTaxr2WZQJEJ4B4b10N7sCID+uDbgcnuZjxWcfRn319/fRSQvaJDYttnRfiRL
         kkxQ==
X-Google-Smtp-Source: ALg8bN6CfyMOSVhkOI4qCOcQDPjp0RDL1herZsjnUL9YRVIr0xZF45WD6Af2cKMyoaJD7PVQHHuyEJcBRGlu746vPaQ=
X-Received: by 2002:a19:ee08:: with SMTP id g8mr1378271lfb.72.1547527808437;
 Mon, 14 Jan 2019 20:50:08 -0800 (PST)
MIME-Version: 1.0
References: <20190111151235.GA2836@jordon-HP-15-Notebook-PC> <f6eef305-daf3-dad8-96e3-d2f93d169fd4@oracle.com>
In-Reply-To: <f6eef305-daf3-dad8-96e3-d2f93d169fd4@oracle.com>
From: Souptick Joarder <jrdr.linux@gmail.com>
Date: Tue, 15 Jan 2019 10:19:55 +0530
Message-ID:
 <CAFqt6zYFR5FHXTLsSQ2DKgZDQtuNB2jZWK6ZLUAscG9vMnSk3Q@mail.gmail.com>
Subject: Re: [PATCH 8/9] xen/gntdev.c: Convert to use vm_insert_range
To: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <willy@infradead.org>, 
	Michal Hocko <mhocko@suse.com>, Juergen Gross <jgross@suse.com>, 
	Russell King - ARM Linux <linux@armlinux.org.uk>, robin.murphy@arm.com, 
	xen-devel@lists.xenproject.org, linux-kernel@vger.kernel.org, 
	Linux-MM <linux-mm@kvack.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190115044955.0DLZ53VVoCcFu3v6xZ6rII1SqtpllnuswnlKn9bDwaU@z>

On Tue, Jan 15, 2019 at 4:58 AM Boris Ostrovsky
<boris.ostrovsky@oracle.com> wrote:
>
> On 1/11/19 10:12 AM, Souptick Joarder wrote:
> > Convert to use vm_insert_range() to map range of kernel
> > memory to user vma.
> >
> > Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>
>
> Reviewed-by: Boris Ostrovsky <boris.ostrovsky@oracle.com>
>
> (although it would be good to mention in the commit that you are also
> replacing count with vma_pages(vma), and why)

The original code was using count ( *count = vma_pages(vma)* )
which is same as this patch. Do I need capture it change log ?

>
>
> > ---
> >  drivers/xen/gntdev.c | 16 ++++++----------
> >  1 file changed, 6 insertions(+), 10 deletions(-)
> >
> > diff --git a/drivers/xen/gntdev.c b/drivers/xen/gntdev.c
> > index b0b02a5..ca4acee 100644
> > --- a/drivers/xen/gntdev.c
> > +++ b/drivers/xen/gntdev.c
> > @@ -1082,18 +1082,17 @@ static int gntdev_mmap(struct file *flip, struct vm_area_struct *vma)
> >  {
> >       struct gntdev_priv *priv = flip->private_data;
> >       int index = vma->vm_pgoff;
> > -     int count = vma_pages(vma);
> >       struct gntdev_grant_map *map;
> > -     int i, err = -EINVAL;
> > +     int err = -EINVAL;
> >
> >       if ((vma->vm_flags & VM_WRITE) && !(vma->vm_flags & VM_SHARED))
> >               return -EINVAL;
> >
> >       pr_debug("map %d+%d at %lx (pgoff %lx)\n",
> > -                     index, count, vma->vm_start, vma->vm_pgoff);
> > +                     index, vma_pages(vma), vma->vm_start, vma->vm_pgoff);
> >
> >       mutex_lock(&priv->lock);
> > -     map = gntdev_find_map_index(priv, index, count);
> > +     map = gntdev_find_map_index(priv, index, vma_pages(vma));
> >       if (!map)
> >               goto unlock_out;
> >       if (use_ptemod && map->vma)
> > @@ -1145,12 +1144,9 @@ static int gntdev_mmap(struct file *flip, struct vm_area_struct *vma)
> >               goto out_put_map;
> >
> >       if (!use_ptemod) {
> > -             for (i = 0; i < count; i++) {
> > -                     err = vm_insert_page(vma, vma->vm_start + i*PAGE_SIZE,
> > -                             map->pages[i]);
> > -                     if (err)
> > -                             goto out_put_map;
> > -             }
> > +             err = vm_insert_range(vma, map->pages, map->count);
> > +             if (err)
> > +                     goto out_put_map;
> >       } else {
> >  #ifdef CONFIG_X86
> >               /*
>

