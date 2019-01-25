Return-Path: <SRS0=o7Ai=QB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2A22DC282C0
	for <linux-mm@archiver.kernel.org>; Fri, 25 Jan 2019 06:25:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DC17C2133D
	for <linux-mm@archiver.kernel.org>; Fri, 25 Jan 2019 06:25:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="YupNbHs7"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DC17C2133D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6DF918E00C1; Fri, 25 Jan 2019 01:25:17 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 664AA8E00BD; Fri, 25 Jan 2019 01:25:17 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 506A68E00C1; Fri, 25 Jan 2019 01:25:17 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f71.google.com (mail-lf1-f71.google.com [209.85.167.71])
	by kanga.kvack.org (Postfix) with ESMTP id D32228E00BD
	for <linux-mm@kvack.org>; Fri, 25 Jan 2019 01:25:16 -0500 (EST)
Received: by mail-lf1-f71.google.com with SMTP id h11so636298lfc.9
        for <linux-mm@kvack.org>; Thu, 24 Jan 2019 22:25:16 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=aWkGNsj9H+PPXdmDM8jphreLemaKpKVhG6fjRtFnO8Q=;
        b=TatI8lGO/c3J+/cnd+3YCJ785VElCRFPmom49vvSg4RpX+lUhdXCO8BFI9lg7AY1Ub
         /U5/pZNj3INYELynQm311WmSz9qCawE8E72uDxPQoCVrrwue9Q/vr75dvqeleP6bYDRo
         sW4zZ7XW406X/7tJPdGhGLLNymtgXAlDjXwDxKxT4syW01v9eipMdWVOTy5iO1hCIYYH
         ryKX76xA4u37s8/MBsjbXZsl5zpiN24QoqCiIVpwNYWDsDHQPf5AZ2ytEm8JwE5P82ew
         1+JjFztaP1YlpejjmpwZOPzwyYbwJVJyfKWRQBndH6vedueJ52M4fydoCtTXx62pcXK3
         DbvQ==
X-Gm-Message-State: AJcUukd3vexT5rxdefyf93oXKyS4OrXsq5dv/Sr7+dULlE27D+/tx456
	DW3R4yTXS6N0y27ITzhb/ayYf7Jcl0MgiS8z4DYOwqAkuAMBdjPsGMQYGGElI2TCIQ1UzBiFsz+
	QdrE35h5cw49SO5FPXuUwBHvleDoCGOivJGnTxDVqp5JfY0fvdHG1twm1z79BEWVY3xX63Jq8BD
	KIMVmi7VUO93jEH0D4GBEQCGmmburPsPdlosmcjIDod/HLB8ZwtMwTvp6q6wjYEDELmjO0JQi3J
	9huWHF68vHf4Eb1Sk2/uC3abZ/GNG8tUoUyUhFRvC/piJrg8SZ1FZqqSCDzZyqRECwRE2K/4Pkr
	RvJvHksdmFtUKMZDyOCPP9RJkPEGuBSFHSVP9NRTY5Yx41ALEhatXTWEb3E858z8ZKgHI7JFm5S
	5
X-Received: by 2002:a2e:81a:: with SMTP id 26-v6mr7732530lji.14.1548397516175;
        Thu, 24 Jan 2019 22:25:16 -0800 (PST)
X-Received: by 2002:a2e:81a:: with SMTP id 26-v6mr7732498lji.14.1548397515357;
        Thu, 24 Jan 2019 22:25:15 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548397515; cv=none;
        d=google.com; s=arc-20160816;
        b=QGji0HnciDBqKWVxOzqHnED/qDyfOzlFtGTBLpteqUM60oicjsPCOIhgXVkc6vBUFA
         +t4OOo7RmO9EvbCM9xVkrdniESJnHyFda9gudsnDGfvb4XGTtkTVPkUU3pyZbnjmR1ni
         yJhdEtG3+RViBPou6TpZx7nv/uTn/IgSnN8j+jIs1JcE8qD8SiKqPdemuQ7ZRqZ2n2kF
         553HqnQv2C23ohBTAZxRdveVM0+5fztWS5bDzne0MN9QTGZsfX6/fm8DkxHZQ39ypS0e
         guTu1t3V/sI7nUOTRQKvmqSpR1/Y9ZFXG06htDZLkKDEAerSz0uZSL3OhReU6WzXmY3Q
         /GZg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=aWkGNsj9H+PPXdmDM8jphreLemaKpKVhG6fjRtFnO8Q=;
        b=LhaQtUyJQvykvlsMJwdnhduGceX4htA0WSDyhELBFPsPt2hrYrN7PcQhnfPJ1It+YT
         DKueh1QjFP+tQa8dM58uSrta+AfhCcOQH8oEkmsQe2mDMp738tX2eauRnI2hwOFIdR49
         Fq8GWqRfCVRrUUmxFxA/QoKs96sy3lTNdV9GclBoruHztSDa3RJMHtgCN2NRuDVbhEsE
         XZF4NbdsVzVvH/xancVZHydfMY6eXLpbuKu03JmKFdexNS33lzog04ThbDyjZxppfcG8
         6ZNGsZJLQJFyDOmjya9DR82T983xkP7hw3Wl6Aix7QqkIFo5zDXUz8C2REC6diR6d2Zz
         +LLw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=YupNbHs7;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e21sor2512558lfj.17.2019.01.24.22.25.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 24 Jan 2019 22:25:15 -0800 (PST)
Received-SPF: pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=YupNbHs7;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=aWkGNsj9H+PPXdmDM8jphreLemaKpKVhG6fjRtFnO8Q=;
        b=YupNbHs7iQOuXsIbeTOXEVnZWfkYovxF20NQ9awvZDPy3o8iS3gw202JHD+bqIdggi
         UC14YfN4ZrjI7wuEC4DsSOrSczpv/7Y3Wf4HmgUgvtwNLvJKceDaTs8OI5dH73FH9cQD
         LY6TE4NtmLMKmcOTYdiuV4C8EDCAetO1QZCN9xqdK/xdCRgoQ6YoFfk4NseNKYsX3tLi
         Qc0/b7DsS7n+1jljKTJNoyZYK+mwbbZMW5CEsPWDVwNh7AN1d5Ycmr9yKEvU94TgPNyk
         JdQSXkO376pFgoEgPwv5M9iT0TLyDJytBSp3tnVR7+XNKX8CyRS3SRRnWZJuLkvJ1pKJ
         fUgw==
X-Google-Smtp-Source: ALg8bN4TGwzzV9+rDqN6jqokcuS2worneigqBlgltDsQYW2kgwnVOXojAkAzi6U2DdppgszxXxvosU25VS4BiX6F4FQ=
X-Received: by 2002:a19:7dc2:: with SMTP id y185mr7847121lfc.27.1548397514916;
 Thu, 24 Jan 2019 22:25:14 -0800 (PST)
MIME-Version: 1.0
References: <20190111150834.GA2744@jordon-HP-15-Notebook-PC>
In-Reply-To: <20190111150834.GA2744@jordon-HP-15-Notebook-PC>
From: Souptick Joarder <jrdr.linux@gmail.com>
Date: Fri, 25 Jan 2019 11:55:03 +0530
Message-ID:
 <CAFqt6zYLDrC7CtLawWUAQPyB_M+5H8BikDR6LOm+v0qaq1GvZw@mail.gmail.com>
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
Message-ID: <20190125062503.RJqR7df0uIYF07_X613IkkznAd1CK5efLDsOGQz0Yw8@z>

On Fri, Jan 11, 2019 at 8:34 PM Souptick Joarder <jrdr.linux@gmail.com> wrote:
>
> Convert to use vm_insert_range_buggy to map range of kernel memory
> to user vma.
>
> This driver has ignored vm_pgoff and mapped the entire pages. We
> could later "fix" these drivers to behave according to the normal
> vm_pgoff offsetting simply by removing the _buggy suffix on the
> function name and if that causes regressions, it gives us an easy
> way to revert.
>
> Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>

Any comment on this patch ?

> ---
>  drivers/firewire/core-iso.c | 15 ++-------------
>  1 file changed, 2 insertions(+), 13 deletions(-)
>
> diff --git a/drivers/firewire/core-iso.c b/drivers/firewire/core-iso.c
> index 35e784c..99a6582 100644
> --- a/drivers/firewire/core-iso.c
> +++ b/drivers/firewire/core-iso.c
> @@ -107,19 +107,8 @@ int fw_iso_buffer_init(struct fw_iso_buffer *buffer, struct fw_card *card,
>  int fw_iso_buffer_map_vma(struct fw_iso_buffer *buffer,
>                           struct vm_area_struct *vma)
>  {
> -       unsigned long uaddr;
> -       int i, err;
> -
> -       uaddr = vma->vm_start;
> -       for (i = 0; i < buffer->page_count; i++) {
> -               err = vm_insert_page(vma, uaddr, buffer->pages[i]);
> -               if (err)
> -                       return err;
> -
> -               uaddr += PAGE_SIZE;
> -       }
> -
> -       return 0;
> +       return vm_insert_range_buggy(vma, buffer->pages,
> +                                       buffer->page_count);
>  }
>
>  void fw_iso_buffer_destroy(struct fw_iso_buffer *buffer,
> --
> 1.9.1
>

