Return-Path: <SRS0=o7Ai=QB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 33A80C282C0
	for <linux-mm@archiver.kernel.org>; Fri, 25 Jan 2019 04:56:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E53CB21872
	for <linux-mm@archiver.kernel.org>; Fri, 25 Jan 2019 04:56:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="dly1TwWz"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E53CB21872
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 76CEF8E00BA; Thu, 24 Jan 2019 23:56:03 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 71D488E00B5; Thu, 24 Jan 2019 23:56:03 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 633278E00BA; Thu, 24 Jan 2019 23:56:03 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f198.google.com (mail-lj1-f198.google.com [209.85.208.198])
	by kanga.kvack.org (Postfix) with ESMTP id ED7138E00B5
	for <linux-mm@kvack.org>; Thu, 24 Jan 2019 23:56:02 -0500 (EST)
Received: by mail-lj1-f198.google.com with SMTP id l12-v6so2292747ljb.11
        for <linux-mm@kvack.org>; Thu, 24 Jan 2019 20:56:02 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=C/JMwhxLuu6m6SIs9Oh+wPosmqrDzte6hFP2JULDCc4=;
        b=uWKVLetLeBxV1GD3Zprn4uHq0ac78revs/PHJmsjeAYYn6E25hHGy9QDlQRfvbGP7X
         sdWYHofzW+5vgKJfDB3pIxV4A2cLBCHtLoeZvo+Gy1ig7PqMzNE4xl2bSVEEn2LUtLuB
         4EqiJyopE9wir6J9xnf78tmm2xQeYmSh2chykdcsqw1ekLe+M1IKCa4JV4+h0l0R07qo
         6x+ci5FH2AddHvv+sKM4FhwaM8AxHN+ldJcofBlMdE4tQOYh6HsK2gnYB6bfQihtJwY6
         RCBJy8qqw3u2NACOysXD8/KpVo+95N/GwsOVauJY0nUSCM3F3bB+2HDCUd7A3DxvRqJw
         K1RQ==
X-Gm-Message-State: AJcUukeMU4pXGE8kdGoAC6cbx57aGoF2zQhZC/0km84M/Lwl/CRodNJp
	q4hfKjr+ncbZR6e5kS5QG0GmoKQZyvLwnaQtsmR+oDuvFfGOc4+5SMa6WCNT/MuoN5vy9t49qu1
	0e9bKTFPWi5bVw2DsB5R1AkUwCm1Nm1un4itMUmGdSccNrXCQcjTI/L+hTzxbamuNp/S0XeKlpu
	H1YVLGNvlBJT7LdbeAXT0HDZntAgQbcP4L+8aNMySbjVoOqW8UFFAKCIQEo+jjD7x36Z68uQ7+q
	jQZj2xOXVOs0MOwnqwnNRPbOiU0/y2Cu2HMYY44M+FwH95pocGVnfgSQW2RnLhXAodakNIyAE4i
	cMcNvSJTH2BT+CnPs8t5YNyQqwuMiWxx1R5bCJQLypNPpxDJWOKPfnFjS389/JWZJQCzvaSj4Q4
	s
X-Received: by 2002:a2e:4299:: with SMTP id h25-v6mr7817731ljf.5.1548392162178;
        Thu, 24 Jan 2019 20:56:02 -0800 (PST)
X-Received: by 2002:a2e:4299:: with SMTP id h25-v6mr7817690ljf.5.1548392161044;
        Thu, 24 Jan 2019 20:56:01 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548392161; cv=none;
        d=google.com; s=arc-20160816;
        b=XxGzdKKrAg87NQ/mVPN4WdII44Qo1QeD8CT52bruSOWB5xnR4B3g/q3GNyBqNtxDKg
         g3XcYF9mgPnOr8nxvHYP/SNFgvWdaTH+lyC8+HxYYXwqjEgil+p6V92TQXaumkgG1Rkb
         WfaTJeTcl70iKkWHzCaU7j2u8bBOXIDvH00YO/LME3jQqYm50a6RkbotCpfInGo1XVNb
         3awu9bEBNT7zU+nHODUSKvfzua6PtqASs+hveuJd+MxwNz4Wah6LyY5gIEM/Uwm7uWBM
         Pb9miqHTika2Mamo8k0J9kxty+S01t8zCSZZ91cLD0jGaU09DS1ggbmw3sXVD7iQvPJL
         TkYQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=C/JMwhxLuu6m6SIs9Oh+wPosmqrDzte6hFP2JULDCc4=;
        b=hY+kuFVlazmc+0GsWrUq1DCPonxZcjm6D9yMhGUn6VXFFHJdVuKNjRmFW/eOYKV0uN
         cyEDvHWcSvOAY+gNDvOuNpzg1KL65caPVqd2PsWM5LbJlmPPDqT6FwCgn0hnSDZfIL0s
         p7c9l3wKsUmM1hbVc8rOxQbuq6+lx0M1CsVPkDBZD1qnPGQUEDefFyrzrb18DuDwzMZC
         CQmBxDc3RTg2yoDw4z5TlEZdnaMrGjA11FNedTqVMF+JkzBnyLvSqXAO+9PZc05xFY4n
         IxCIYYbc+CjZ3yQl/3dwytbCc7nwBRRovkgAYBcWtJh/Pke8/MeDCqoCK6JkLMPHA3So
         hNcA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=dly1TwWz;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 129sor2606894lfl.19.2019.01.24.20.56.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 24 Jan 2019 20:56:01 -0800 (PST)
Received-SPF: pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=dly1TwWz;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=C/JMwhxLuu6m6SIs9Oh+wPosmqrDzte6hFP2JULDCc4=;
        b=dly1TwWzlEjzTmbOOZejw9fX4Z4HPWT5IuOLxsP492/+AwlNJDJ1r1Hw844+MFqLXp
         VPYrFSKwQtg4qx/peWt31A9iL4OGiMsVv7Bi+6437vD3jzIE059BlpT4KESCt54C3R3l
         /pX0yRxYNoACe/8TSpHJf9oPgqklqHeYhnqkuQQCVaGVhaHclXUPSZ/zduaMsMzrvaIv
         MxeeQtQE4Kx6dV8Z0B8/5UN0eG3l1HLoUqimDKF+XEVEub3djBjjl6QsKc0/mJPkiolB
         si1xaQ+PVQCz+ei9YecLBva1/JN/7o2tgA3IqKKPvUnHW/Q90kYtaFfUe64r72SjYfMx
         F7Yw==
X-Google-Smtp-Source: ALg8bN5nylAnfJuxiRtrLidx8KwnXBt11+97csnqsltSxWPg39TTO6I88OX5w6LIgwlc5BaJoVIYmQTwoyDX7Am6ql4=
X-Received: by 2002:a19:645b:: with SMTP id b27mr7194430lfj.14.1548392160400;
 Thu, 24 Jan 2019 20:56:00 -0800 (PST)
MIME-Version: 1.0
References: <CGME20190111150806epcas2p4ecaac58547db019e7dc779349d495f4d@epcas2p4.samsung.com>
 <20190111151154.GA2819@jordon-HP-15-Notebook-PC> <241810e0-2288-c59b-6c21-6d853d9fe84a@samsung.com>
In-Reply-To: <241810e0-2288-c59b-6c21-6d853d9fe84a@samsung.com>
From: Souptick Joarder <jrdr.linux@gmail.com>
Date: Fri, 25 Jan 2019 10:25:48 +0530
Message-ID:
 <CAFqt6zbYHq-pS=rGx+3ncJ7rO-LvL5=iOou21oguKjrc=3qouA@mail.gmail.com>
Subject: Re: [PATCH 7/9] videobuf2/videobuf2-dma-sg.c: Convert to use vm_insert_range_buggy
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <willy@infradead.org>, 
	Michal Hocko <mhocko@suse.com>, pawel@osciak.com, 
	Kyungmin Park <kyungmin.park@samsung.com>, mchehab@kernel.org, 
	Russell King - ARM Linux <linux@armlinux.org.uk>, robin.murphy@arm.com, linux-media@vger.kernel.org, 
	linux-kernel@vger.kernel.org, Linux-MM <linux-mm@kvack.org>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190125045548.aZ_Ng9dvlp6t6rP_h_c1eq_7X8XATJxy9VE0fgQTCM0@z>

Hi Marek,

On Tue, Jan 22, 2019 at 8:37 PM Marek Szyprowski
<m.szyprowski@samsung.com> wrote:
>
> Hi Souptick,
>
> On 2019-01-11 16:11, Souptick Joarder wrote:
> > Convert to use vm_insert_range_buggy to map range of kernel memory
> > to user vma.
> >
> > This driver has ignored vm_pgoff. We could later "fix" these drivers
> > to behave according to the normal vm_pgoff offsetting simply by
> > removing the _buggy suffix on the function name and if that causes
> > regressions, it gives us an easy way to revert.
>
> Just a generic note about videobuf2: videobuf2-dma-sg is ignoring vm_pgof=
f by design. vm_pgoff is used as a 'cookie' to select a buffer to mmap and =
videobuf2-core already checks that. If userspace provides an offset, which =
doesn't match any of the registered 'cookies' (reported to userspace via se=
parate v4l2 ioctl), an error is returned.

Ok, it means once the buf is selected, videobuf2-dma-sg should always
mapped buf->pages[i]
from index 0 ( irrespective of vm_pgoff value). So although we are
replacing the code with
vm_insert_range_buggy(), *_buggy* suffix will mislead others and
should not be used.
And if we replace this code with  vm_insert_range(), this will
introduce bug for *non zero*
value of vm_pgoff.

Please correct me if my understanding is wrong.

So what your opinion about this patch ? Shall I drop this patch from
current series ?
or,
There is any better way to handle this scenario ?


>
> > There is an existing bug inside gem_mmap_obj(), where user passed
> > length is not checked against buf->num_pages. For any value of
> > length > buf->num_pages it will end up overrun buf->pages[i],
> > which could lead to a potential bug.

It is not gem_mmap_obj(), it should be vb2_dma_sg_mmap().
Sorry about it.

What about this issue ? Does it looks like a valid issue ?


> >
> > This has been addressed by passing buf->num_pages as input to
> > vm_insert_range_buggy() and inside this API error condition is
> > checked which will avoid overrun the page boundary.
> >
> > Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>
> > ---
> >  drivers/media/common/videobuf2/videobuf2-dma-sg.c | 22 ++++++---------=
-------
> >  1 file changed, 6 insertions(+), 16 deletions(-)
> >
> > diff --git a/drivers/media/common/videobuf2/videobuf2-dma-sg.c b/driver=
s/media/common/videobuf2/videobuf2-dma-sg.c
> > index 015e737..ef046b4 100644
> > --- a/drivers/media/common/videobuf2/videobuf2-dma-sg.c
> > +++ b/drivers/media/common/videobuf2/videobuf2-dma-sg.c
> > @@ -328,28 +328,18 @@ static unsigned int vb2_dma_sg_num_users(void *bu=
f_priv)
> >  static int vb2_dma_sg_mmap(void *buf_priv, struct vm_area_struct *vma)
> >  {
> >       struct vb2_dma_sg_buf *buf =3D buf_priv;
> > -     unsigned long uaddr =3D vma->vm_start;
> > -     unsigned long usize =3D vma->vm_end - vma->vm_start;
> > -     int i =3D 0;
> > +     int err;
> >
> >       if (!buf) {
> >               printk(KERN_ERR "No memory to map\n");
> >               return -EINVAL;
> >       }
> >
> > -     do {
> > -             int ret;
> > -
> > -             ret =3D vm_insert_page(vma, uaddr, buf->pages[i++]);
> > -             if (ret) {
> > -                     printk(KERN_ERR "Remapping memory, error: %d\n", =
ret);
> > -                     return ret;
> > -             }
> > -
> > -             uaddr +=3D PAGE_SIZE;
> > -             usize -=3D PAGE_SIZE;
> > -     } while (usize > 0);
> > -
> > +     err =3D vm_insert_range_buggy(vma, buf->pages, buf->num_pages);
> > +     if (err) {
> > +             printk(KERN_ERR "Remapping memory, error: %d\n", err);
> > +             return err;
> > +     }
> >
> >       /*
> >        * Use common vm_area operations to track buffer refcount.
>
> Best regards
> --
> Marek Szyprowski, PhD
> Samsung R&D Institute Poland
>

