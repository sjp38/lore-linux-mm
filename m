Return-Path: <SRS0=hkLx=PX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EF37FC43387
	for <linux-mm@archiver.kernel.org>; Tue, 15 Jan 2019 05:42:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9DB3720656
	for <linux-mm@archiver.kernel.org>; Tue, 15 Jan 2019 05:42:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="opB0LILt"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9DB3720656
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2CABA8E0003; Tue, 15 Jan 2019 00:42:11 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 250078E0002; Tue, 15 Jan 2019 00:42:11 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0F23A8E0003; Tue, 15 Jan 2019 00:42:11 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f200.google.com (mail-lj1-f200.google.com [209.85.208.200])
	by kanga.kvack.org (Postfix) with ESMTP id 933408E0002
	for <linux-mm@kvack.org>; Tue, 15 Jan 2019 00:42:10 -0500 (EST)
Received: by mail-lj1-f200.google.com with SMTP id g92-v6so403096ljg.23
        for <linux-mm@kvack.org>; Mon, 14 Jan 2019 21:42:10 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=5U4Yr+jS2JUdn/D+ygFqqoeUDxn+oxmgJpsC2yObEJM=;
        b=YVxPd0Ve6v5UduDH3z+/jXdjELKpwcTZd5vTip0Sxvd6BToghD8zCHswvujrBWip43
         PQ7wlRQNbNuCMnhCTBAk9Kj4yiEKzldDLmRnqjdnSnyBwOi7cQXWvyWUzDri58pz5A4j
         nwyrxPqtUwfWs7eoYd2cvdQIyPXTywfE3KYErNjveMS/0vqCiqknNoWThwyK/1al2X1H
         cDDY0dWhgIi0ha86lY3M8DHmV1i1Nq513p0uMRRbHAL5gznJzKQK92fzfvGEUWxsxxmn
         dwKxq2eJ5q02RXaxjfV+/I7ksvDQq0Skf/taMSPSN/6bgVhmmW2r4tMrpQfHr98vxY7w
         rZJQ==
X-Gm-Message-State: AJcUukejrCffz2/CVT9U+4gcXaO9j0QEnTvu7C5coHtdJzZdkqRpdPcw
	KoQktHzFyYXkYtaYIjLKw6TkQQ0qLVRUTtRN5Q0SJVfm/JHDFhvNudFeTIcT28CixdMJHCZuqIM
	zJiQZL/ojejpVMsUfmav8enVvLuwjlRbLt7XcFjAl/8U100tYobp3NXRwS/qPj52U8TpbuYGkDc
	miOz49si8uJZQZy7ZVt710m2o3g3NUrZpuFuDCBhl9rk7hJ8qrffMZn4R9hQfuL+SM9fTHkNmmT
	2VDDO9+R5u7mOWPRdqf3W1wLRu6hzKqUYjTmTW1xhNjcqyFiLkWjxYizY6dFulDeiB92CjT/dPf
	aI+714sblO+nNMld3eBknQcWv1C6bTqozvAzU5w0NcLcz8lxqA5MqVJIgGMwxgnZmYb+eCv+HG8
	F
X-Received: by 2002:a2e:9c52:: with SMTP id t18-v6mr1248922ljj.149.1547530929783;
        Mon, 14 Jan 2019 21:42:09 -0800 (PST)
X-Received: by 2002:a2e:9c52:: with SMTP id t18-v6mr1248893ljj.149.1547530928886;
        Mon, 14 Jan 2019 21:42:08 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547530928; cv=none;
        d=google.com; s=arc-20160816;
        b=aeIhVOth/8xPy3s7K6X+Qp1EOgtsYmx05wfcZygBCcoizqfu22HnffmE3jgX8aYU8Z
         QVxPjXl3mWzh05dZLQ1LUAEoDHYRDJYt4HIgixk1F+u+mqDj3YKf9uYU3cdJC2zzIS7R
         V1DewC87SPEqJJWL4ycxQcIupaItr7GP+RgW7xml2Ie4jz4qQAMCDW3XyyFUrIB3OopP
         6mGw1e3eMT6cpw/qmldRIbi/W5P9mGhJ82mzSBye3Kw55PqXx6bsrDCFfPppJLHxX/5q
         XT4wSm0sWJAYPLEM0s1qbFSAg9ACykH98ioSlVu1rp3R2O+v9uVKiUZ8qApV+E1yumgF
         MXog==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=5U4Yr+jS2JUdn/D+ygFqqoeUDxn+oxmgJpsC2yObEJM=;
        b=Nq289W61C9Ef7KGcAFFsF/DEo8mDlcRePFr6EdHg39KPm84oPqb0ESOugNpMPqNJNa
         lTOED5uk36lhmpUv5BqsChf883dHSPeMT8FkrFmPqATlKP0Lnp6ircrMxdUjxGBkYTmC
         9ouK+1JW9KEloqkMFbL9IfXiAb3qrXzIAeGErr2IlG8TClqROXpaTn0bxkt4etoDuCVf
         9QUT0wFzfCy61DIMkwxA6uegAQJpH+dpxmMYxAIcjekA8OjRy5LfBtcNrmfW9pAvDANr
         SCxFSC5xgpBb/0jI/Wnv0/pvhrKc/a1fdnHO/iaP3Wg4VuFGcwEXVbpuEJhYZW3XP/PA
         DLGQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=opB0LILt;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b16sor786275lfj.71.2019.01.14.21.42.08
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 14 Jan 2019 21:42:08 -0800 (PST)
Received-SPF: pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=opB0LILt;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=5U4Yr+jS2JUdn/D+ygFqqoeUDxn+oxmgJpsC2yObEJM=;
        b=opB0LILtjOwB4hb42JKCpZE4Vs5XNkvxk0O3/UNZ3WLPXcdQA73iwKl29YrZA9d3L1
         8SYhAKEJ+NkJ4fESoaOHLpGIwJmCf+vLZfi0f+lg5Ys8NLLYSk0slaL0ai2pp8D0KE4b
         DnVqr7YBDo9B8pSz18T9jviys2CSqrndoW3SEYNTfqJgJ+HKGfq6MzrvbJS1FihcUe5G
         r+6b366ncZ2Qpy3LtTQQLDN3djzMmTLMxKzof/RcKVvta1n+mLO4hGax2pt/sq2aGIls
         5cMgxzgmJ8dyRiAY+FSgbTw1QdtV0NpuxoBp/DdNlpAdkwEAHjhtvRTWUXc3wSPdvM27
         qHpQ==
X-Google-Smtp-Source: ALg8bN5rZ5g/mEr7KbXdsOB6SSm+HbAlmtg/Yt2PUrKntnU6562AUYnfG+mCjdaLAMtyhWRlNypsFZ41BnXTWPKxLHA=
X-Received: by 2002:a19:2906:: with SMTP id p6mr1442310lfp.17.1547530928341;
 Mon, 14 Jan 2019 21:42:08 -0800 (PST)
MIME-Version: 1.0
References: <20190111151326.GA2853@jordon-HP-15-Notebook-PC> <8b0e0809-8e66-079d-1186-90b3f2df7a38@oracle.com>
In-Reply-To: <8b0e0809-8e66-079d-1186-90b3f2df7a38@oracle.com>
From: Souptick Joarder <jrdr.linux@gmail.com>
Date: Tue, 15 Jan 2019 11:11:56 +0530
Message-ID:
 <CAFqt6zbgrdhoaZXW+5vHu2kV-LmtXMGAcmrv+28i78x0z4Fweg@mail.gmail.com>
Subject: Re: [PATCH 9/9] xen/privcmd-buf.c: Convert to use vm_insert_range_buggy
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
Message-ID: <20190115054156.qt8UAGVnswnV2SRhIQYAtQa01F74bpyyIihD7XE-mtw@z>

On Tue, Jan 15, 2019 at 5:01 AM Boris Ostrovsky
<boris.ostrovsky@oracle.com> wrote:
>
> On 1/11/19 10:13 AM, Souptick Joarder wrote:
> > Convert to use vm_insert_range_buggy() to map range of kernel
> > memory to user vma.
> >
> > This driver has ignored vm_pgoff. We could later "fix" these drivers
> > to behave according to the normal vm_pgoff offsetting simply by
> > removing the _buggy suffix on the function name and if that causes
> > regressions, it gives us an easy way to revert.
> >
> > Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>
> > ---
> >  drivers/xen/privcmd-buf.c | 8 ++------
> >  1 file changed, 2 insertions(+), 6 deletions(-)
> >
> > diff --git a/drivers/xen/privcmd-buf.c b/drivers/xen/privcmd-buf.c
> > index de01a6d..a9d7e97 100644
> > --- a/drivers/xen/privcmd-buf.c
> > +++ b/drivers/xen/privcmd-buf.c
> > @@ -166,12 +166,8 @@ static int privcmd_buf_mmap(struct file *file, struct vm_area_struct *vma)
> >       if (vma_priv->n_pages != count)
> >               ret = -ENOMEM;
> >       else
> > -             for (i = 0; i < vma_priv->n_pages; i++) {
> > -                     ret = vm_insert_page(vma, vma->vm_start + i * PAGE_SIZE,
> > -                                          vma_priv->pages[i]);
> > -                     if (ret)
> > -                             break;
> > -             }
> > +             ret = vm_insert_range_buggy(vma, vma_priv->pages,
> > +                                             vma_priv->n_pages);
>
> This can use the non-buggy version. But since the original code was
> indeed buggy in this respect I can submit this as a separate patch later.
>
> So
>
> Reviewed-by: Boris Ostrovsky <boris.ostrovsky@oracle.com>

Thanks Boris.
>
>
> >
> >       if (ret)
> >               privcmd_buf_vmapriv_free(vma_priv);
>

