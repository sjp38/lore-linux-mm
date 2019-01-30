Return-Path: <SRS0=ywda=QG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E78DBC282D7
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 09:59:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6E8DB2080F
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 09:59:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="FgZnM72Z"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6E8DB2080F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B625B8E0002; Wed, 30 Jan 2019 04:59:10 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B12178E0001; Wed, 30 Jan 2019 04:59:10 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A28268E0002; Wed, 30 Jan 2019 04:59:10 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f197.google.com (mail-lj1-f197.google.com [209.85.208.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3276D8E0001
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 04:59:10 -0500 (EST)
Received: by mail-lj1-f197.google.com with SMTP id f22-v6so6619793lja.7
        for <linux-mm@kvack.org>; Wed, 30 Jan 2019 01:59:10 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=fO9lml+l22jOIyAkjdHX9mgdNk63cVEuzFUCTmyVOGY=;
        b=EoQiRNgxgRS/BDyt/P1rozuFpnImoQZIOBhGpuh2yywge0p4XDcLpQMFU9JwgDEq6H
         10jI5cNw23wkPLQVcO78VIpySkdnSiua62tan7MSvex63HUZm+Z8YbnPMdBIKAaW11/K
         2omFr8sN3wPyJDP2Ql9T7zbrPL905q6soZQ6FzGp7b6+aOMImQ27lABw38KAjqEK4Cio
         p6veaisH24M5x+N4GdSMHqT9l4B+3ag6s1q6q4OoX/Zt5NBEyVtJE9XrH8DTr14Y1v7L
         xbdDxlp/oukr5Jr6Bx1uunFac3tgBk8iEH3mW60xIIUcYTS+RWA/a9lD0+9xF/u/OmM6
         bqBQ==
X-Gm-Message-State: AJcUukdmoJZZpa+kOaXlILhtvFSvE/3iat7+wsdf3v2ZiHOMhjVDu9rl
	r6oTUGV508P2gsExG8ROW1xvu0pmNrLnILP5sXSFqaP717CHkJfogHQwXDcUfIHddyN0FXo4XAS
	LmaUEzWqTk4o0R1Afjw5tOKqfj95VeP2lquOR6LgyDM6aY6DTmclHEONozHfc00EZ/sCK476CnW
	+ONkrWuGJ/mzqgNF7mt1mp3GVHslSqbdmexIAuwKCj1tNGlB68auNDp7HT0qmrhhPPeoD0fAYEs
	77sW3sAMFMyhsLNxen32Jk5KozFpEIhW2Mbypr0uR3Cw3Olxo7df3rOOtY7EPMV6nTenq0vFORz
	FJuLYKzV5wLSV3ab4JH+Z3jzsJp5PXnz9v+9QzvuOI+HBxQDPZjI5aQnB+znfeO9EXzD3o8YPEB
	0
X-Received: by 2002:a19:a28e:: with SMTP id l136mr23102092lfe.87.1548842349326;
        Wed, 30 Jan 2019 01:59:09 -0800 (PST)
X-Received: by 2002:a19:a28e:: with SMTP id l136mr23102034lfe.87.1548842348168;
        Wed, 30 Jan 2019 01:59:08 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548842348; cv=none;
        d=google.com; s=arc-20160816;
        b=Uga5pNp1bH7YTjTWNIAAabxfzgx76k2n6MzKG6rDHjNmEoGJhcZIQ6CSLJBf9TBgOz
         Wl2AVOO6WRoqG8Wyk/yIs5sChj0t+HgBOEjiZYbQI5qUe43fQ4eZXgyv7cJW0UL2yMWR
         ooQ6jeg2C/MOjYymxXr8JevmLivWcRhlOnSNE+HmDXyEIRs/ferPYPSoxqIIPJaBYUlL
         5c+3d7XfchAK80OpEvkGcdMsgTsOlHkVwevgZvalNIbEHLxBz4rlORESRQn5tbOH+ZWc
         kUVdih1QoMLCbHDGhtFFEj0t7VpIigRMoL2JsyPDbdCyhLpwYp+ciUKnyhQkAmTNdQXA
         aUsg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=fO9lml+l22jOIyAkjdHX9mgdNk63cVEuzFUCTmyVOGY=;
        b=jtioXm6Kb13hKx6Nk/TofPzLGVsPSAB5dhddObkAzTNogDJMOOX1uE4Z4F1quDcTaX
         gQ0y5lOdiHAKNKbsrskSkJMlkbZ3K5WGP1b+zaq8qRSqtfnQRRzWd9qyl6w0+YQc0tDC
         pq+WRvKKTfgTr/L1szKyJB7NbsZA5Jo/6gnUZR2vhgR8pk0Um+541/PlDr3om58kxUvu
         mZebCejoZ/mQh8Tbi8n8qL3Y+engbWMOJfy9exqMj21dPr3+BebgfB59jFSJ98Q+p7Gh
         CbfwFxB73EwhvxI8kYZ1SgglwP4O5JWG2go8jqIp9Y/zUBPgno5sVtSjpY2nC1PKrP4I
         EJog==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=FgZnM72Z;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r10-v6sor691399lji.40.2019.01.30.01.59.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 30 Jan 2019 01:59:08 -0800 (PST)
Received-SPF: pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=FgZnM72Z;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=fO9lml+l22jOIyAkjdHX9mgdNk63cVEuzFUCTmyVOGY=;
        b=FgZnM72ZgZjEW0ORM0btMd9MaPOSZrwy4G9BeQws0rUHuJHemFIVbE0ZCoZpaoosFw
         N3PdCNT6kXYw8DLArD26ROZeZzX8+8jjnLe36XfsiwPdVYaU43zXcTbDoeiwCN+mqekZ
         zsoH+T/bie3kWtmE8bXeQ2qFizuDognaAGSBbIlF5jIr4yvCiyJNi5O0iEa6OXD864pj
         BpkiZ0YjlrSKJQbkgDtZBfRpE+Ti0E2FKogNXGRbdJ+XauSFmM8wamMDzXg6IiWxAQg2
         S+Sq6rxtBEO6tnO7W5lo0N1bX0uEQxNNNyjyTB1Ey2rgMaID4CY2GUA+/xaXoy8YJvrH
         vAxg==
X-Google-Smtp-Source: ALg8bN7/li39XaGpJQ6EMr2lSSqiHUCbw+mdn4YxxMLFOWbC7mmMJ4AR7eu7vhwFRP/Adj9lqWbSZT1zXyytNWz3m6c=
X-Received: by 2002:a2e:5854:: with SMTP id x20-v6mr23772381ljd.31.1548842347483;
 Wed, 30 Jan 2019 01:59:07 -0800 (PST)
MIME-Version: 1.0
References: <20190111150834.GA2744@jordon-HP-15-Notebook-PC> <CAFqt6zYLDrC7CtLawWUAQPyB_M+5H8BikDR6LOm+v0qaq1GvZw@mail.gmail.com>
In-Reply-To: <CAFqt6zYLDrC7CtLawWUAQPyB_M+5H8BikDR6LOm+v0qaq1GvZw@mail.gmail.com>
From: Souptick Joarder <jrdr.linux@gmail.com>
Date: Wed, 30 Jan 2019 15:28:55 +0530
Message-ID: <CAFqt6zY4YgsCUPFqR2yYegjqtHJ_aeE1Ao6p=fE92s2__3XTsA@mail.gmail.com>
Subject: Re: [PATCH 3/9] drivers/firewire/core-iso.c: Convert to use vm_insert_range_buggy
To: Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <willy@infradead.org>, 
	Michal Hocko <mhocko@suse.com>, stefanr@s5r6.in-berlin.de, 
	Russell King - ARM Linux <linux@armlinux.org.uk>, robin.murphy@arm.com
Cc: linux-kernel@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, 
	linux-arm-kernel@lists.infradead.org, linux1394-devel@lists.sourceforge.net
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jan 25, 2019 at 11:55 AM Souptick Joarder <jrdr.linux@gmail.com> wrote:
>
> On Fri, Jan 11, 2019 at 8:34 PM Souptick Joarder <jrdr.linux@gmail.com> wrote:
> >
> > Convert to use vm_insert_range_buggy to map range of kernel memory
> > to user vma.
> >
> > This driver has ignored vm_pgoff and mapped the entire pages. We
> > could later "fix" these drivers to behave according to the normal
> > vm_pgoff offsetting simply by removing the _buggy suffix on the
> > function name and if that causes regressions, it gives us an easy
> > way to revert.
> >
> > Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>
>
> Any comment on this patch ?

Any comment on this patch ?

>
> > ---
> >  drivers/firewire/core-iso.c | 15 ++-------------
> >  1 file changed, 2 insertions(+), 13 deletions(-)
> >
> > diff --git a/drivers/firewire/core-iso.c b/drivers/firewire/core-iso.c
> > index 35e784c..99a6582 100644
> > --- a/drivers/firewire/core-iso.c
> > +++ b/drivers/firewire/core-iso.c
> > @@ -107,19 +107,8 @@ int fw_iso_buffer_init(struct fw_iso_buffer *buffer, struct fw_card *card,
> >  int fw_iso_buffer_map_vma(struct fw_iso_buffer *buffer,
> >                           struct vm_area_struct *vma)
> >  {
> > -       unsigned long uaddr;
> > -       int i, err;
> > -
> > -       uaddr = vma->vm_start;
> > -       for (i = 0; i < buffer->page_count; i++) {
> > -               err = vm_insert_page(vma, uaddr, buffer->pages[i]);
> > -               if (err)
> > -                       return err;
> > -
> > -               uaddr += PAGE_SIZE;
> > -       }
> > -
> > -       return 0;
> > +       return vm_insert_range_buggy(vma, buffer->pages,
> > +                                       buffer->page_count);
> >  }
> >
> >  void fw_iso_buffer_destroy(struct fw_iso_buffer *buffer,
> > --
> > 1.9.1
> >

