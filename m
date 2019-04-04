Return-Path: <SRS0=kGB6=SG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0B838C4360F
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 20:58:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B724D206C0
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 20:58:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="WAdLf+oA"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B724D206C0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 513DF6B000D; Thu,  4 Apr 2019 16:58:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4C2D86B000E; Thu,  4 Apr 2019 16:58:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 38BC36B0266; Thu,  4 Apr 2019 16:58:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f199.google.com (mail-oi1-f199.google.com [209.85.167.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0F4B06B000D
	for <linux-mm@kvack.org>; Thu,  4 Apr 2019 16:58:24 -0400 (EDT)
Received: by mail-oi1-f199.google.com with SMTP id o132so1801470oib.5
        for <linux-mm@kvack.org>; Thu, 04 Apr 2019 13:58:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=qafkl+RucsJKe13LIlXobuTdVgqu/oF51yHT8KcUWbc=;
        b=hY+Wimr3rglmkoREMSqLWjavT3UcdJL4NozxSyzszIllkKXrIaITADtBLQLgh5dD0m
         6orOTFT7FywbzsxxBP8SctswxP5j5zaCh2zHYsoSNDgKgXmdgdZ7JbDrH5SsttRRKYqy
         O+XzeETgs+evlCDrxvN4kKrH2PHNY7AkrwC+CoDNWbqjRQoYnHg27G9r7Bpzrcz74xY8
         eoapJoUnSz/Dr6t3u7gsitdRQG6fMPZVPlOxspuVqWgCvWGATn99XvqKhd/GZcPaZhpT
         lMr3HPzTyV5FjAG4OV3pVa++1aGbc8B6SVKdCOwi8TkIi4i405OYkcmOlQ6mWM4uCrHF
         3oUg==
X-Gm-Message-State: APjAAAW7uZBWy0fxFkgMLRX0A6+Me1cYO57b2r2HaEr+Oo0vk6QZSNtC
	KtnOtilFwYMojvMFH8ftrvCBh32Q6iiqCof6JaxM1Fg1Guvx5coRxzL01rj+u9UtaOA6xL+KsdK
	MPoqaDIKTrlWoBdUGZuOEVIuprC4atoqdm6Y6FKUTn4ri/poqayOKWTBDsFv2shxESA==
X-Received: by 2002:aca:bb88:: with SMTP id l130mr4598668oif.124.1554411503716;
        Thu, 04 Apr 2019 13:58:23 -0700 (PDT)
X-Received: by 2002:aca:bb88:: with SMTP id l130mr4598641oif.124.1554411503175;
        Thu, 04 Apr 2019 13:58:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554411503; cv=none;
        d=google.com; s=arc-20160816;
        b=JjQuY//0aMeEb4uiNpqVxXh62EvubI75MB8t/xqk42jNSZbEStEwgXmjWKbx0fwUUW
         CTgqN3bQCgSuxHNziBINJE8NavE2H3cze/fGyqZgHU5ANdk32sYKw8S63gdtVwdVL7Eq
         qzzIpm9XvYGr6eSRjz5be8qHw/GqBiHwWTu+hGJ+sJ7RHm/tTI21jE7K1by1CxgJURga
         wAWJ4e3y3OJNvc2YMYN1vy6QunHheht64osojRmEQ1mOyjplayf4vZtoXjG8vmKYa9k+
         Zven2Q6BB91Nae+ZUdC44u/jPvQ+Knx9uzYe+QD5PXeRbf0VA1cN+o5sZcSWxUfCo5Qi
         +SrQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=qafkl+RucsJKe13LIlXobuTdVgqu/oF51yHT8KcUWbc=;
        b=Ia/1MLbe4325sNbo0UiEnzJNrcMFHuNmzAgKXHegPf1QkDTRAMnKRzodxSKJh/vfC/
         9szOCnYCQ+Dn20ZTe9OUrkhUGk7/IrltoGTIy7s8L0qkn9la4oMSLcv2lMaXigkKFPxr
         cT/vD/Y3vXS3qGUxL2XfKNrDcQjdKIZWi0Lv7n9McSelxjn+VaKt37agqrrXDWM7vc0B
         QBfnB+7hS/+VQzkfTEo6++y0wH+OknJSEOKgT90lp8a2WI7KZJH+Ge8qwelKoWFD1S4W
         yFN8ZiYvk8mTmFXk64Hq+rpZXdUsMP5r8YIMnthfVBsugBYWl6UqIq2x+OnDdDxCiuAF
         WV+g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=WAdLf+oA;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l4sor11874646otc.127.2019.04.04.13.58.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 04 Apr 2019 13:58:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=WAdLf+oA;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=qafkl+RucsJKe13LIlXobuTdVgqu/oF51yHT8KcUWbc=;
        b=WAdLf+oA+P/wpBu5Pjl44qrdlHaOV2iP7oRPTstlMdt40fThdirzxyUc6aqHEhmVal
         pxCiHwSA82rPNahu4jHqT742OswANbaGqdKWmNwUFJNXhbvSkHK+5f7UQkjDCAFyzUue
         3O8+8w88xLv9me1UXzUorHxybGBhIeLOyeXrbSzSj5fcm65YReoYfz3WkJApxvyBXE7x
         dvv+Ro4iMC6N8xOnmImpwyU5PSGMQ0SDkS1wJe6mu2Ov8XImba+jLAG3nB8l9aV1up0t
         B2LQkCeWlxvgdpV54gPzh6pNMo94J2rpU1GadrXUWZhgaVWMr8jK7MM1SAuiUnIqJF0a
         l57Q==
X-Google-Smtp-Source: APXvYqxRkFGg4ofNBLeQIKRis7QOSDDVNGXKbjmC9eM589A4kZD0glRjlwj1jb40vyH+x86CEjmxTX8YszdahENoq0Q=
X-Received: by 2002:a9d:7a83:: with SMTP id l3mr5518812otn.285.1554411502925;
 Thu, 04 Apr 2019 13:58:22 -0700 (PDT)
MIME-Version: 1.0
References: <155440490809.3190322.15060922240602775809.stgit@dwillia2-desk3.amr.corp.intel.com>
 <155440492414.3190322.12683374224345847860.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20190404205818.GC24499@localhost.localdomain>
In-Reply-To: <20190404205818.GC24499@localhost.localdomain>
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 4 Apr 2019 13:58:12 -0700
Message-ID: <CAPcyv4jua8GeyL7jNOZoEf9MhNXADvQX2T+h1D5FRRd9GLwNeA@mail.gmail.com>
Subject: Re: [RFC PATCH 3/5] acpi/hmat: Track target address ranges
To: Keith Busch <kbusch@kernel.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, 
	Len Brown <lenb@kernel.org>, Keith Busch <keith.busch@intel.com>, 
	Jonathan Cameron <Jonathan.Cameron@huawei.com>, Vishal L Verma <vishal.l.verma@intel.com>, 
	X86 ML <x86@kernel.org>, Linux MM <linux-mm@kvack.org>, 
	linux-nvdimm <linux-nvdimm@lists.01.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 4, 2019 at 1:56 PM Keith Busch <kbusch@kernel.org> wrote:
>
> On Thu, Apr 04, 2019 at 12:08:44PM -0700, Dan Williams wrote:
> > As of ACPI 6.3 the HMAT no longer advertises the physical memory address
> > range for its entries. Instead, the expectation is the corresponding
> > entry in the SRAT is looked up by the target proximity domain.
> >
> > Given there may be multiple distinct address ranges that share the same
> > performance profile (sparse address space), find_mem_target() is updated
> > to also consider the start address of the memory range. Target property
> > updates are also adjusted to loop over all possible 'struct target'
> > instances that may share the same proximity domain identification.
>
> Since this may allocate multiple targets with the same PXM,
> hmat_register_targets() will attempt to register the same node multiple
> times.
>
> Would it make sense if the existing struct memory_target adds a resource
> list that we can append to as we parse SRAT? That way we have one target
> per memory node, and also track the ranges.

That sounds reasonable to me.

