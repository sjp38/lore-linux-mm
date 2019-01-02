Return-Path: <SRS0=6aBQ=PK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 22649C43387
	for <linux-mm@archiver.kernel.org>; Wed,  2 Jan 2019 10:53:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CC3FC2171F
	for <linux-mm@archiver.kernel.org>; Wed,  2 Jan 2019 10:53:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Qt5z6qJG"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CC3FC2171F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 60D918E001C; Wed,  2 Jan 2019 05:53:30 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5BAD68E0002; Wed,  2 Jan 2019 05:53:30 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4D2B28E001C; Wed,  2 Jan 2019 05:53:30 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f200.google.com (mail-lj1-f200.google.com [209.85.208.200])
	by kanga.kvack.org (Postfix) with ESMTP id D37528E0002
	for <linux-mm@kvack.org>; Wed,  2 Jan 2019 05:53:29 -0500 (EST)
Received: by mail-lj1-f200.google.com with SMTP id g12-v6so8893116lji.3
        for <linux-mm@kvack.org>; Wed, 02 Jan 2019 02:53:29 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=SezKeaYuk6nk7occBjh6L8uqtXsHTPs6Hbj337dY8hk=;
        b=qDaPBIns5kOOX94RlnCYcRfqa4h0vx7SigbZY3JEACyCm8cPd0muS/3aVp78tL+hv4
         BY6H6o46Fhql9OIRrLAHSvj1fBLVf6Z2ZQqfCrfnlt38s1X1QkTWw2RQKV/L8DbD1PSM
         w7D5pkCnBda6cCjuiy0+sBYy355/YJoAkEBBIHTs6zPMmJC+uOFCqypTY8fTqR5C0GuT
         2i09p6seaAE0KA9X1YlsW2nx/VJvs028T0/S//FM79fooWPuXMwAC7Ux+OwdH3GWaQvy
         YlR8rFmNbyN2X9M9u+Af7bT6C1mzVsbfQJ7pzg0+TqFVqSbRIK0in4Jr66Dado6eAjqR
         /xpw==
X-Gm-Message-State: AJcUukd05Wy//fenW1Yxa0tq2b+2pB9r9DXlDHbUWWfAh+wUHRJssuRD
	BZJGnhFoaXV+eAuw2HVcP0FXi7oNgtiTlDcfrXMFpji02es+88DPiq8vT5zIXNgz2ODvdjhu/Iv
	4r3UPuyGC335RF/d0BNqqBQ9nI7bu/DUEYNY8n+byDVr5jVClEru/obFjXOI5/SR9QZsTof4Wcz
	EeQV0rJUFXBAYgwZtCCPR3xWlFlRN3VZfZgxOf+k6JKNhW6Iu5pFxsjp/0d4aOioqzy7Rtbar8f
	w4gmpAjvXf0/EaDe5vF+a533he/Vj+dHWOc/fp20JxqDRhJ71yrDteyj7BsKcWj9r4QdP1BZkvy
	7b+AoaMmu2pBpFcHtvT4EAtQwix8CRdYXx5ogfjwwZJDSlNaZav0r61xV4F2j92rtMYMRvYGI62
	z
X-Received: by 2002:a2e:8786:: with SMTP id n6-v6mr14692890lji.100.1546426408941;
        Wed, 02 Jan 2019 02:53:28 -0800 (PST)
X-Received: by 2002:a2e:8786:: with SMTP id n6-v6mr14692856lji.100.1546426407926;
        Wed, 02 Jan 2019 02:53:27 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1546426407; cv=none;
        d=google.com; s=arc-20160816;
        b=p9lQAPjeAMjQPstIFDtiMwuCkB5TCrikWXa9SUztqCeO1ry9mhRR7q7xNrGVRwMJ8j
         rC0U7LSArlRvn2ZUK2IrMMlvnnMV4TnozvOny8vt95bhXRmDIFh3bJG2/ZK4krQPDwTO
         7dt3LezcHItKG4O+NvLKBe5H7U9Z4BDPPyTOogj1vUo439/Wwr1ATo994QCYxvhzaevH
         kT3aYV5tWfHUVhZM0SfotwNxkPAWBf9I1I+E7dPHWkNPRngwZZZUIPOaLaGpG+8lwU2Z
         EhhkPaYTYrNB68FqEs9yfDrPSyYptK8clH5DM+7eut4cW8FP/fAaBFJL0Mn2TXi9L58Z
         GcBw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=SezKeaYuk6nk7occBjh6L8uqtXsHTPs6Hbj337dY8hk=;
        b=GEKxpy0lISQ3IsbyVJtt6SQHJ874paFZijyb+F3DYkbVbqh8Lx3y0+/qBghiGZyxjP
         PypwBjJgCrXcT6RZ1nCeM8m5yyCiVVy/nNAggzpmcDxzG81HCLvo5GDLw0PLCYxUILCP
         EifaZk/03P9rlnHMNDWY3M0f2dEe5xw/pPuPvvIaqmyrN6TIW7dGMA9o/plZYdRnhRTs
         K1CWmVPX55m4cisdnRRbNQ/nBlT5zXQ9CUBcNMiRbU3jtidguKrmQ2uyoMr5rgZB4DWW
         k187fVhe7Cb24167NZwI/s8ylvNytPT1AenyG6NbXpn6OjJHaPOhFELm/963l3pYMnX0
         JqcA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Qt5z6qJG;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y24-v6sor29614892ljy.1.2019.01.02.02.53.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 02 Jan 2019 02:53:27 -0800 (PST)
Received-SPF: pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Qt5z6qJG;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=SezKeaYuk6nk7occBjh6L8uqtXsHTPs6Hbj337dY8hk=;
        b=Qt5z6qJGB9o9aGKd2wu1bhsmzEmdcDzaLxP82MQjif7xhWIw1UWk0ZnlJTMC9xvoN6
         mBIXkib4q11Ofmjr++AElHoRXjW2lvlTw+Gd+RbJFOrrcVyQTOnaIAOGVTj8Ec/D6WEV
         Xt4ni8bIGny1nGnbEp6gYIBs+xrkOy3fG1ykkyHzdsrAS69uhcl/1+hadweqRUG4sIEy
         lbPd/8Y4pAHNkKA+zkIbSw3sMt+jw5nMsQ7dTVDtFyciFa43x93Y8BjuWlygWrOOSHaV
         RTwlWIJXdj05/Jdg/5Z/6y+x7+1pI11xPhnhbSZ3+08BMNSK0e29ewTR43WCAHis0qmm
         meIg==
X-Google-Smtp-Source: AFSGD/UwYlr3G2cGWuGxEPCHMUa9rHoeFQ8/rz6abHSV1vjPvvVhGgT7iCng27XKmqtsRwEco9RU++5BMOiXMuziz3c=
X-Received: by 2002:a2e:630a:: with SMTP id x10-v6mr23330309ljb.11.1546426407321;
 Wed, 02 Jan 2019 02:53:27 -0800 (PST)
MIME-Version: 1.0
References: <20181224132658.GA22166@jordon-HP-15-Notebook-PC>
In-Reply-To: <20181224132658.GA22166@jordon-HP-15-Notebook-PC>
From: Souptick Joarder <jrdr.linux@gmail.com>
Date: Wed, 2 Jan 2019 16:23:15 +0530
Message-ID:
 <CAFqt6zZU6c3MyVQpCegntu1ZxtFri=HMwZJ3xg+tCxRARo3zMA@mail.gmail.com>
Subject: Re: [PATCH v5 7/9] videobuf2/videobuf2-dma-sg.c: Convert to use vm_insert_range
To: Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <willy@infradead.org>, 
	Michal Hocko <mhocko@suse.com>, pawel@osciak.com, 
	Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, mchehab@kernel.org, 
	Russell King - ARM Linux <linux@armlinux.org.uk>, robin.murphy@arm.com
Cc: linux-media@vger.kernel.org, linux-kernel@vger.kernel.org, 
	Linux-MM <linux-mm@kvack.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190102105315.7OFxKR7TqhbrI7jgCmyUYwTUlJrCzj5dYaD5f0bqbw4@z>

On Mon, Dec 24, 2018 at 6:53 PM Souptick Joarder <jrdr.linux@gmail.com> wrote:
>
> Convert to use vm_insert_range to map range of kernel memory
> to user vma.
>
> Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>
> Reviewed-by: Matthew Wilcox <willy@infradead.org>
> Acked-by: Marek Szyprowski <m.szyprowski@samsung.com>
> Acked-by: Mauro Carvalho Chehab <mchehab+samsung@kernel.org>
> ---
>  drivers/media/common/videobuf2/videobuf2-dma-sg.c | 23 +++++++----------------
>  1 file changed, 7 insertions(+), 16 deletions(-)
>
> diff --git a/drivers/media/common/videobuf2/videobuf2-dma-sg.c b/drivers/media/common/videobuf2/videobuf2-dma-sg.c
> index 015e737..898adef 100644
> --- a/drivers/media/common/videobuf2/videobuf2-dma-sg.c
> +++ b/drivers/media/common/videobuf2/videobuf2-dma-sg.c
> @@ -328,28 +328,19 @@ static unsigned int vb2_dma_sg_num_users(void *buf_priv)
>  static int vb2_dma_sg_mmap(void *buf_priv, struct vm_area_struct *vma)
>  {
>         struct vb2_dma_sg_buf *buf = buf_priv;
> -       unsigned long uaddr = vma->vm_start;
> -       unsigned long usize = vma->vm_end - vma->vm_start;
> -       int i = 0;
> +       unsigned long page_count = vma_pages(vma);
> +       int err;
>
>         if (!buf) {
>                 printk(KERN_ERR "No memory to map\n");
>                 return -EINVAL;
>         }
>
> -       do {
> -               int ret;
> -
> -               ret = vm_insert_page(vma, uaddr, buf->pages[i++]);
> -               if (ret) {
> -                       printk(KERN_ERR "Remapping memory, error: %d\n", ret);
> -                       return ret;
> -               }
> -
> -               uaddr += PAGE_SIZE;
> -               usize -= PAGE_SIZE;
> -       } while (usize > 0);
> -
> +       err = vm_insert_range(vma, vma->vm_start, buf->pages, page_count);
> +       if (err) {
> +               printk(KERN_ERR "Remapping memory, error: %d\n", err);
> +               return err;
> +       }
>

Looking into the original code -
drivers/media/common/videobuf2/videobuf2-dma-sg.c

Inside vb2_dma_sg_alloc(),
           ...
           buf->num_pages = size >> PAGE_SHIFT;
           buf->dma_sgt = &buf->sg_table;

           buf->pages = kvmalloc_array(buf->num_pages, sizeof(struct page *),
                                                       GFP_KERNEL | __GFP_ZERO);
           ...

buf->pages has index upto  *buf->num_pages*.

now inside vb2_dma_sg_mmap(),

           unsigned long usize = vma->vm_end - vma->vm_start;
           int i = 0;
           ...
           do {
                 int ret;

                 ret = vm_insert_page(vma, uaddr, buf->pages[i++]);
                 if (ret) {
                           printk(KERN_ERR "Remapping memory, error:
%d\n", ret);
                           return ret;
                 }

                uaddr += PAGE_SIZE;
                usize -= PAGE_SIZE;
           } while (usize > 0);
           ...
is it possible for any value of  *i  > (buf->num_pages)*,
buf->pages[i] is going to overrun the page boundary ?

