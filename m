Return-Path: <SRS0=1eqM=US=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.7 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 842CCC31E5D
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 17:06:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3F06F217F4
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 17:06:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="X1G1dO6s"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3F06F217F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C70756B0003; Wed, 19 Jun 2019 13:06:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C213D8E0005; Wed, 19 Jun 2019 13:06:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AC1348E0001; Wed, 19 Jun 2019 13:06:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id 83F346B0003
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 13:06:55 -0400 (EDT)
Received: by mail-ot1-f69.google.com with SMTP id x18so8174311otp.9
        for <linux-mm@kvack.org>; Wed, 19 Jun 2019 10:06:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=0p/XIwpXKqn06m+RPTTcvCNox7E/RmmojiCAJ5y+urI=;
        b=T2bsFslLoGn8NUIrxZbMWrwFKPZfQGjRNee84Ac8n7u7VfoDBkuYAm+t9sHomeSFXJ
         CtFoms2fibE6+KnISSw7Lap77RpqxDNLKE6kaoECnNoEVQieALlK+UsgmMkmrsKFJoPW
         x7EYEb62Z54L96KpfjLHCpoo5yj2JV2+eSoj6HhY4CbFwwauBuKUaUHuycX1fQMLdbdi
         vfwZ5Wrv5XrkhGv4QqGBcv19U9rcy+hUElVLtKDm7jp93cK/+UBqeOO6stedhAWW2e94
         u+SN8TMbKT7rIZ9mHUU7kUbxRJe5vnxIL0+UtKGLLnNvwOvdERRpuy2V4+6D2MKyvRl4
         CTzA==
X-Gm-Message-State: APjAAAUzHhXE8oMO1/+6I++bEb+4FKrAKBu1mlIVM2QwysehMYdtCRRl
	vECVs9sefnyd1wCy1qYxVA1/70c+20/tlZBHT6DvpAgI2NXTkfpcLrbkifaYIUjb2iifiXkzqYO
	rV0GB4nNYmwbZu5Cem3xOO/51KaKjEAI2rTsUDOfGKZl6nUwRoV05uDsnhcKZhoeYfw==
X-Received: by 2002:a05:6830:1697:: with SMTP id k23mr677028otr.16.1560964015245;
        Wed, 19 Jun 2019 10:06:55 -0700 (PDT)
X-Received: by 2002:a05:6830:1697:: with SMTP id k23mr676979otr.16.1560964014523;
        Wed, 19 Jun 2019 10:06:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560964014; cv=none;
        d=google.com; s=arc-20160816;
        b=KF0TjuelZKwtpA4r8rK1Mh79zL7VDGdd+a1GpiCgrGHkyX+Tzx8T0l8ki0jxlM/Xf6
         DdNdNeK9J0h39Vs2s360IwrfHXSa8r/qLhYuyINGopeGZV9HOK0MJgngYVh27NRAtC8j
         eIbmWAtYQcNMWb5ESLlZwnGtcoxnXMLqAYFEuMsAV9GsjJmx/tH2Kpgdv1gdT5TMGS1t
         OoXRrtiX32YGJv2GoxvoZUzHK98Cp/kFx18M3G5+nkvVD1xu2NyRmaW/xTzUV1tMepNF
         ikxtPViDZd+lIB55OrICMaC7DUZNZ2997+DVhSdJ8rClPdY6jHtRZ6t87m2i6e96KdFt
         xhoQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=0p/XIwpXKqn06m+RPTTcvCNox7E/RmmojiCAJ5y+urI=;
        b=uGl9FL900wRC1OzO5imxHs1OMJbUczjgJMsi3gzDx1fpS1655XtlbtglOe6gmuHTWa
         MTUU+Gjbo0aGnl/KwX9oH5DabtZ77ixUACcsapPWfYg2UDlbUiVKNaYw9XfyI0DB5Ldo
         VT87/Dkl1/jZKbfFizs/e22dA+s9tjS/uVNO0IGqVwEVCYHgviTpxl7+XYQdtvcMff/N
         UwYZLUBU2kSJorBXlA7CwLuO2IAmCfweUn42Z+f5DdDRXqNTB/NCyU6S0WZn64J5Ky+/
         m0DSFBBv7L+AYepglHAZotUXuybNFrV4XRkLUERdSey+1M7fOU2IuvuExgihHBsev5WJ
         9bag==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=X1G1dO6s;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j207sor6869448oib.139.2019.06.19.10.06.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 19 Jun 2019 10:06:54 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=X1G1dO6s;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=0p/XIwpXKqn06m+RPTTcvCNox7E/RmmojiCAJ5y+urI=;
        b=X1G1dO6s3hbPvvZxcZOiIHvHuDoK3U48uQPPR5MSfaahW+qB1h5ikRxyrv0TQ20ja0
         HICDctS0WB3ZfGIRg+H0iIVCOFaWPrqH49VvmlQYs54j8X67guXIqTf09+c1rckymzbV
         CCA0ucFlLTdXNabe+3SVVYtFDnUivT7Subor5zWzFNMMilwCMtKka4LlKaWkWMhvonJS
         tbQ0whFMH1pwYpXuToAxQMqnJ70T9W7U+F9PYM7voXqcBD6Atro+SbJN3pT9PRBmjh0M
         wTtxFqXTPr6YUGMkMtavqPHD+DBwSSuZ8kCju0CBrKYoI1Cd1zI68zp/6pDA/7ySsNxR
         +jJA==
X-Google-Smtp-Source: APXvYqzPQ7hGf38RJ89R10lUDX088z06TMvhN9nJMBhLW66oBHW/MYhv7ngyJ6+CXJ7guXzYDqNBTWN5jhwDowX/HFE=
X-Received: by 2002:aca:ec82:: with SMTP id k124mr3358584oih.73.1560964014171;
 Wed, 19 Jun 2019 10:06:54 -0700 (PDT)
MIME-Version: 1.0
References: <156092349300.979959.17603710711957735135.stgit@dwillia2-desk3.amr.corp.intel.com>
 <156092356065.979959.6681003754765958296.stgit@dwillia2-desk3.amr.corp.intel.com>
 <877e9hk06d.fsf@linux.ibm.com>
In-Reply-To: <877e9hk06d.fsf@linux.ibm.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 19 Jun 2019 10:06:43 -0700
Message-ID: <CAPcyv4gZfLoG2tOGFWK56rr1vadF71+ny951brtunbPUNW-W1w@mail.gmail.com>
Subject: Re: [PATCH v10 12/13] libnvdimm/pfn: Fix fsdax-mode namespace
 info-block zero-fields
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, stable <stable@vger.kernel.org>, 
	linux-nvdimm <linux-nvdimm@lists.01.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 19, 2019 at 9:30 AM Aneesh Kumar K.V
<aneesh.kumar@linux.ibm.com> wrote:
>
> Dan Williams <dan.j.williams@intel.com> writes:
>
> > At namespace creation time there is the potential for the "expected to
> > be zero" fields of a 'pfn' info-block to be filled with indeterminate
> > data. While the kernel buffer is zeroed on allocation it is immediately
> > overwritten by nd_pfn_validate() filling it with the current contents of
> > the on-media info-block location. For fields like, 'flags' and the
> > 'padding' it potentially means that future implementations can not rely
> > on those fields being zero.
> >
> > In preparation to stop using the 'start_pad' and 'end_trunc' fields for
> > section alignment, arrange for fields that are not explicitly
> > initialized to be guaranteed zero. Bump the minor version to indicate it
> > is safe to assume the 'padding' and 'flags' are zero. Otherwise, this
> > corruption is expected to benign since all other critical fields are
> > explicitly initialized.
> >
> > Note The cc: stable is about spreading this new policy to as many
> > kernels as possible not fixing an issue in those kernels. It is not
> > until the change titled "libnvdimm/pfn: Stop padding pmem namespaces to
> > section alignment" where this improper initialization becomes a problem.
> > So if someone decides to backport "libnvdimm/pfn: Stop padding pmem
> > namespaces to section alignment" (which is not tagged for stable), make
> > sure this pre-requisite is flagged.
>
> Don't we need a change like below in this patch?
>
> modified   drivers/nvdimm/pfn_devs.c
> @@ -452,10 +452,11 @@ int nd_pfn_validate(struct nd_pfn *nd_pfn, const char *sig)
>         if (memcmp(pfn_sb->parent_uuid, parent_uuid, 16) != 0)
>                 return -ENODEV;
>
> -       if (__le16_to_cpu(pfn_sb->version_minor) < 1) {
> -               pfn_sb->start_pad = 0;
> -               pfn_sb->end_trunc = 0;
> -       }
> +       if ((__le16_to_cpu(pfn_sb->version_minor) < 1) ||
> +           (__le16_to_cpu(pfn_sb->version_minor) >= 3)) {
> +                       pfn_sb->start_pad = 0;
> +                       pfn_sb->end_trunc = 0;
> +               }

No, this kills off start_pad and end_trunc permanently.

> IIUC we want to force the start_pad and end_truc to zero if the pfn_sb
> minor version number >= 3. So once we have this patch backported and
> older kernel finds a pfn_sb with minor version 3, it will ignore the
> start_pad read from the nvdimm and overwrite that with zero here.
> This patch doesn't enforce that right? After the next patch we can have
> values other than 0 in pfn_sb->start_pad?

The reason for the version bump is for the kernel to safely assume
that uninitialized fields default to zero, but it's otherwise a nop
when the implementation is explicitly initializing every field by
default.

