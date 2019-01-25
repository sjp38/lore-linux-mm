Return-Path: <SRS0=o7Ai=QB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D45FBC282C0
	for <linux-mm@archiver.kernel.org>; Fri, 25 Jan 2019 21:03:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6BF78218A6
	for <linux-mm@archiver.kernel.org>; Fri, 25 Jan 2019 21:03:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="JRDDhEn8"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6BF78218A6
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B00AB8E00EF; Fri, 25 Jan 2019 16:03:09 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AB2538E00EE; Fri, 25 Jan 2019 16:03:09 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9C90E8E00EF; Fri, 25 Jan 2019 16:03:09 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com [209.85.128.69])
	by kanga.kvack.org (Postfix) with ESMTP id 44FC18E00EE
	for <linux-mm@kvack.org>; Fri, 25 Jan 2019 16:03:09 -0500 (EST)
Received: by mail-wm1-f69.google.com with SMTP id 18so2633189wmw.6
        for <linux-mm@kvack.org>; Fri, 25 Jan 2019 13:03:09 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=GlFA8LtVMqJOfnjC7UmYvTFlMlqdaOETYFtC07gL8c8=;
        b=KU+F18XyoyUXOrQg1qelJrExDLh8pMRzL+mEfJegZJyQCeZxVwVB6ig3XWuvGeuRWe
         etc0TdNl4cUuKC2yV1pkOr4POnZjB6JujSZr2QKXsC7TpJjXFbiGcyxz3WTgkPVflhFo
         e8oB4k1fZ428uVtyToSvlL+qCodLDwZKd7XSKdtYclqOs7ruw+ktk2aP5YdWJR3F+O6g
         BMPPSqOFaMt3mUtcoAi2b4uO7m8bfgJJtGE8PBhlSPeHQlclmHkbvsDxvFkCoimBTZ2Z
         pm+Nm0hBzsjh9yrtXw5JhcE+SLRkjpNa1kU7WgwaBnz1Vzr0IKG2VdRLErU48mT5X4NH
         Mf3Q==
X-Gm-Message-State: AJcUukcW/E/eH2b1N3NGGFKFFp7EDWuyLBK/aeZ05m70+fdkjBCyj9Zx
	QJmMRc3EwlZISCei+5Mw2G0AqbY2xDj/DfPQR0GDOlLvBqT15oxiMhaFKEJUfonjCF+Gw/6Jj9l
	a4S3U8nGgTqu4w5XDt4KNk7/Sl/JLr668Lpm07zk8bZNF3/mJEGQhkGdkiBCuynREfzRpxr+m5X
	HLz9vwPQ8qSjX60BcePV430ZaMtDP7m8irqRwQwVGdzvLVRCQDS3UU7rcSCgEUS3M0z+3v8vcng
	sxaASOhsOiLfciA8JtQk729wZ3KKo3IEZbPN5pxf/XuHo6IxFp04Gmo/vWqp8sk4fslnWK3ynYn
	GZcQUmYKWsXg6QKfLF/1+mjxd3r5+qWxXEChryXZprIFItp1sCwHypHGelSebsVP+Yi/H3wbPXU
	r
X-Received: by 2002:a1c:bc82:: with SMTP id m124mr8038102wmf.77.1548450188724;
        Fri, 25 Jan 2019 13:03:08 -0800 (PST)
X-Received: by 2002:a1c:bc82:: with SMTP id m124mr8038057wmf.77.1548450187564;
        Fri, 25 Jan 2019 13:03:07 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548450187; cv=none;
        d=google.com; s=arc-20160816;
        b=TnXZDApGUdIYeMN2S9T8huz4kQ8CjVe1PyOp977ITXetzwtKG7Dhxq6WYKBZICYJG/
         mwc53X4Wa7KqMYdgfuPXUaWT/iGfBw5IAy8UWLp66fpQCYwzoI1GtA98sm6RLggTy9UJ
         6K4+HEDuOknG21FlEz10uTYO14v6L3XsLRAtUmr7WZRRF1Ae4DqOq8C1Ysy4dHShZ0+y
         EPo6IMoXn3zMm/MC9KTxUMyoi8yHSQAUCZklEgEnfaJrltOqwF1V2lCmmFxoYtCKDv8R
         GVGhAEUwgXoZECCZ3FxntUeDyIPrx4RQEc5T8wAcuk9KHSrs+IjSLy8CBQjUygRnLBsu
         vdpA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=GlFA8LtVMqJOfnjC7UmYvTFlMlqdaOETYFtC07gL8c8=;
        b=uwLTEctNbIk2Tl4tBzPxTuwqistcFVaBpEs2bzAzp8bMRjgZ9LGVJR8+PWUaopjAiy
         4m4PKwNARtd4pp3xyeCUybzqkq0zPwJu7thcsarAcZ1cyvKTQgPQvOt5Bo8xmsfk6HrG
         TOwLlCM5XcuH3f4j2ZYG90ynlpIECXkRJwng4HRvKsgWv3DEJHvuN+fHf8XN3nfZCZxp
         0+aIVTObftxaaZdKrNGyVy3zrtUwiAsjf8xN1QFxdx5kYA4VxAsZtTcBolDWnxlT/U+K
         rW/oyfsE04JBZoXQ58ITM0O5xaU5ss3w1+uvGV0JNB56bjEbhCdBUDhPzyYclOae8mzK
         H/EQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=JRDDhEn8;
       spf=pass (google.com: domain of bhelgaas@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=bhelgaas@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q4sor74827920wru.28.2019.01.25.13.03.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 25 Jan 2019 13:03:07 -0800 (PST)
Received-SPF: pass (google.com: domain of bhelgaas@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=JRDDhEn8;
       spf=pass (google.com: domain of bhelgaas@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=bhelgaas@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=GlFA8LtVMqJOfnjC7UmYvTFlMlqdaOETYFtC07gL8c8=;
        b=JRDDhEn8/pBLDYMXq+rCIIkS2PvE/vCc8+Vgigg/VxRv1eyxQObLuf9Ql56fZebign
         hZZqX3LZTlxh4qtYJaHRX2ZnZzRI7SNdQMloqP3An+Di6jaSMBjtcI/JkdMlqzFC7BEj
         tkjLMRL0VYIJA0AfWf3mSFlXN8mfnFRs1vQPOThm+lQyqR7/DIeHKPd2b+iEhtmP8cNq
         4SJIynT+/KmTQu69nps1hVdBtXq267EqcDrobJaMrTFCskCvhU1WRvRJrO1Hf8U8jAuH
         0OQeoiMxMDs+Md0Ca0wNaQmVQZ/n7I0rK2cPmMM6IwHp4d2nC7eHBJYVhXFM8VCGru71
         w3TA==
X-Google-Smtp-Source: ALg8bN4YSnU8ocVyHeD54PjkgUNpLaNRE+Av0um87TRh1jxbNHujScXrZ+6dCqJZAqSI4YIMKMgZIpl7xkOcH+hyQDg=
X-Received: by 2002:adf:9b11:: with SMTP id b17mr13033849wrc.168.1548450186690;
 Fri, 25 Jan 2019 13:03:06 -0800 (PST)
MIME-Version: 1.0
References: <20190124231441.37A4A305@viggo.jf.intel.com> <20190124231442.EFD29EE0@viggo.jf.intel.com>
In-Reply-To: <20190124231442.EFD29EE0@viggo.jf.intel.com>
From: Bjorn Helgaas <bhelgaas@google.com>
Date: Fri, 25 Jan 2019 15:02:55 -0600
Message-ID:
 <CAErSpo7kMjfi-1r8ZyGbheWzo+JCFkDZ1zpVhyNV7VVy8NOV7g@mail.gmail.com>
Subject: Re: [PATCH 1/5] mm/resource: return real error codes from walk failures
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Dan Williams <dan.j.williams@intel.com>, 
	Dave Jiang <dave.jiang@intel.com>, zwisler@kernel.org, vishal.l.verma@intel.com, 
	thomas.lendacky@amd.com, Andrew Morton <akpm@linux-foundation.org>, mhocko@suse.com, 
	linux-nvdimm@lists.01.org, linux-mm@kvack.org, 
	Huang Ying <ying.huang@intel.com>, Wu Fengguang <fengguang.wu@intel.com>, 
	Borislav Petkov <bp@suse.de>, baiyaowei@cmss.chinamobile.com, Takashi Iwai <tiwai@suse.de>, 
	Jerome Glisse <jglisse@redhat.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190125210255.jbLi420NiT-v90pqIqiT9QEpj5bRiJJbaukIjFmmAfs@z>

On Thu, Jan 24, 2019 at 5:21 PM Dave Hansen <dave.hansen@linux.intel.com> wrote:
>
>
> From: Dave Hansen <dave.hansen@linux.intel.com>
>
> walk_system_ram_range() can return an error code either becuase *it*
> failed, or because the 'func' that it calls returned an error.  The
> memory hotplug does the following:
>
>         ret = walk_system_ram_range(..., func);
>         if (ret)
>                 return ret;
>
> and 'ret' makes it out to userspace, eventually.  The problem is,
> walk_system_ram_range() failues that result from *it* failing (as
> opposed to 'func') return -1.  That leads to a very odd -EPERM (-1)
> return code out to userspace.
>
> Make walk_system_ram_range() return -EINVAL for internal failures to
> keep userspace less confused.
>
> This return code is compatible with all the callers that I audited.
>
> Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
> Cc: Dan Williams <dan.j.williams@intel.com>
> Cc: Dave Jiang <dave.jiang@intel.com>
> Cc: Ross Zwisler <zwisler@kernel.org>
> Cc: Vishal Verma <vishal.l.verma@intel.com>
> Cc: Tom Lendacky <thomas.lendacky@amd.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: linux-nvdimm@lists.01.org
> Cc: linux-kernel@vger.kernel.org
> Cc: linux-mm@kvack.org
> Cc: Huang Ying <ying.huang@intel.com>
> Cc: Fengguang Wu <fengguang.wu@intel.com>
> Cc: Borislav Petkov <bp@suse.de>
> Cc: Bjorn Helgaas <bhelgaas@google.com>
> Cc: Yaowei Bai <baiyaowei@cmss.chinamobile.com>
> Cc: Takashi Iwai <tiwai@suse.de>
> Cc: Jerome Glisse <jglisse@redhat.com>
> ---
>
>  b/kernel/resource.c |    4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
>
> diff -puN kernel/resource.c~memory-hotplug-walk_system_ram_range-returns-neg-1 kernel/resource.c
> --- a/kernel/resource.c~memory-hotplug-walk_system_ram_range-returns-neg-1      2019-01-24 15:13:13.950199540 -0800
> +++ b/kernel/resource.c 2019-01-24 15:13:13.954199540 -0800
> @@ -375,7 +375,7 @@ static int __walk_iomem_res_desc(resourc
>                                  int (*func)(struct resource *, void *))
>  {
>         struct resource res;
> -       int ret = -1;
> +       int ret = -EINVAL;
>
>         while (start < end &&
>                !find_next_iomem_res(start, end, flags, desc, first_lvl, &res)) {
> @@ -453,7 +453,7 @@ int walk_system_ram_range(unsigned long
>         unsigned long flags;
>         struct resource res;
>         unsigned long pfn, end_pfn;
> -       int ret = -1;
> +       int ret = -EINVAL;

Can you either make a similar change to the powerpc version of
walk_system_ram_range() in arch/powerpc/mm/mem.c or explain why it's
not needed?  It *seems* like we'd want both versions of
walk_system_ram_range() to behave similarly in this respect.

>         start = (u64) start_pfn << PAGE_SHIFT;
>         end = ((u64)(start_pfn + nr_pages) << PAGE_SHIFT) - 1;
> _

