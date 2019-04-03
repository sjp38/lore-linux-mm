Return-Path: <SRS0=DmM3=SF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 02BA3C4360F
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 18:09:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7DB182082C
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 18:09:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="z8K+qZbK"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7DB182082C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EFE616B0269; Wed,  3 Apr 2019 14:09:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EADCD6B026A; Wed,  3 Apr 2019 14:09:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D75766B026B; Wed,  3 Apr 2019 14:09:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	by kanga.kvack.org (Postfix) with ESMTP id AA8926B0269
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 14:09:06 -0400 (EDT)
Received: by mail-oi1-f197.google.com with SMTP id d63so6954505oig.0
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 11:09:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=WLfeTHYa0RD16P6+TGw1835NRm1Z2mjwVm5mp+9PwC4=;
        b=nok7yjAru3f6hGJ8b+E0bzebiMYLJK062KfhaPlf5GopLjwoovC0wDP3PiHoI8FkK2
         Q5x1H4RSQVb66r42HvanOxjgB4WsePvPw7SU8w1YCjMqFDhMyzPl+02lWf32/3yfj8Be
         3k2a2nrp9lm4TI0BCwmkBWf5Aoybn8nGjOMeJBjFI4AIDGQJ1kSU306EWfP7Trek1bXi
         puJ8ig8AsMc2ysThZzptxddwcyxVPx4425avq+EJgZxhUDdtP/b3THYzr+UfskY9UGA/
         o6RbVriMi0U9h9CHr/7D5Gi5rK2TJ+mXcx/1fhydgKOM0lBcjz135QIrCgRvclcyufUV
         JF4w==
X-Gm-Message-State: APjAAAVhYwdVq2iQwv0emmVimICAPGn0Cti3vyghtetXhjI6WVAj65Iz
	2tTpwFi7FL1S+rTw+m29a8Cra+Zhw8S+jwVSGiJiGpAMehErFEiibGlEq1aHaKm4bSfqAyPlQHA
	/Q+R+AVNANWtA3AyBQvDLA9FdxYYkgs6sMbVy6B50c/EgKSqJ0x9TramB/TswcniHAA==
X-Received: by 2002:a9d:7cd2:: with SMTP id r18mr777476otn.87.1554314946363;
        Wed, 03 Apr 2019 11:09:06 -0700 (PDT)
X-Received: by 2002:a9d:7cd2:: with SMTP id r18mr777430otn.87.1554314945647;
        Wed, 03 Apr 2019 11:09:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554314945; cv=none;
        d=google.com; s=arc-20160816;
        b=gTyqO/Ax3lcJUTWIPRrjCYVvfaBpbu6dUs3ZJuNr1wYiy0+egaw+eyvqvhhxdCk9F2
         Z96zyS3ONmrWmpS6Z78jqoMoXv5i+hqmP4WA0jAxqLSBUZ3I7UM/cGsEz5CDSSlx5fYK
         XAtp0owZp5IjC/IIeS5ai1Nza6F/qvA0vAQloMh4EcXLmYw8FSDM3S6CefPUGd/ffD1Q
         Y3S/J9j0x8aIfDZ1+xEpynqUiGiNMIppRSNEdILUPZSv1RXPQXKSadNxBleR7EQt5vYi
         v7GxNWZ3oMuvW6OZWt8CZXMol6Whc+hFBdY51Lenuq4LMNy+XXS00ifqTF4Wm7Ma+bbR
         R3Cg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=WLfeTHYa0RD16P6+TGw1835NRm1Z2mjwVm5mp+9PwC4=;
        b=vrMTDB6s06wqJajR6OvaOSgIyxuwSdxC/9VS9qQPuGeljQCvMq0NPQHll20mt5l72+
         PoP++OKGOQ1mWJb5LEop/NqahxEoW/t6rM5SnosB1fH+3nqz6fegkBz4rq9t1RQAa36D
         X1q6f4ceIlIuo9mNzYrQb7Rl58RFcy0uD+Px1UBL/DOcYoDnujDH1OZyFGdUBNjRzbmc
         Efuf9pIQB5DZ/DL27OtKPHXvqJnEberfB6lSs4/uxtgs9aCKEEpGYbDCF7vkky590cZl
         /fsvN3NBs0l1qJvg8sOvMIf/HnQa/Ph0zW37ZWFtvjSDINEg802DYVnjPzJ97I2KgPik
         ittA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=z8K+qZbK;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d13sor8744449oih.174.2019.04.03.11.09.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 03 Apr 2019 11:09:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=z8K+qZbK;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=WLfeTHYa0RD16P6+TGw1835NRm1Z2mjwVm5mp+9PwC4=;
        b=z8K+qZbKKB0CPbds0ctgzT6yvbDSyne4jzF+g9MQDqHCPB5OPh0qk2XXWxoiT8uT9G
         zzAZBBgiwvP3s3WO+yER7TdXgooNtVJn+bJrYtKWk0AUmM4gMN9g2NYXSa+GjS+RD4qh
         8xENTTZm8SgBjQ9esMCmbOP5N89LgbdkK2DEsHPY7bvoNzu4jgR80ZG3HLSzPxh0WrY5
         S0JNoxdJG64cPYngeWk+znmXW9+iCzcbLOjAVOekrPZVxNPgEekx0LW/gdB8hbrAEi1G
         xsvjGauCjnbGtT2gFDUKoUQw5H1XawOs5hYrgAV4dxTSwt6qZz7tP5wZXt4VslUi4kvi
         mGuA==
X-Google-Smtp-Source: APXvYqzusb0p4qiWWjm2CpnwMPhzr5akGYhKWUDDAJTvVOvkzYZTem1qs/kZxvPv4FWYtmfE1KTFPIoKblD2l9anuTo=
X-Received: by 2002:aca:f581:: with SMTP id t123mr589000oih.0.1554314944750;
 Wed, 03 Apr 2019 11:09:04 -0700 (PDT)
MIME-Version: 1.0
References: <1554265806-11501-1-git-send-email-anshuman.khandual@arm.com>
In-Reply-To: <1554265806-11501-1-git-send-email-anshuman.khandual@arm.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 3 Apr 2019 11:08:53 -0700
Message-ID: <CAPcyv4gdz7L20nSMEBNLDWgUzr-GjaBhecF3i8Q4D_O=ug0qNw@mail.gmail.com>
Subject: Re: [PATCH 0/6] arm64/mm: Enable memory hot remove and ZONE_DEVICE
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-arm-kernel@lists.infradead.org, 
	Linux MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, 
	Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, 
	Michal Hocko <mhocko@suse.com>, Mel Gorman <mgorman@techsingularity.net>, james.morse@arm.com, 
	Mark Rutland <mark.rutland@arm.com>, Robin Murphy <robin.murphy@arm.com>, cpandya@codeaurora.org, 
	arunks@codeaurora.org, osalvador@suse.de, 
	Logan Gunthorpe <logang@deltatee.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, 
	David Hildenbrand <david@redhat.com>, cai@lca.pw
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 2, 2019 at 9:30 PM Anshuman Khandual
<anshuman.khandual@arm.com> wrote:
>
> This series enables memory hot remove on arm64, fixes a memblock removal
> ordering problem in generic __remove_memory(), enables sysfs memory probe
> interface on arm64. It also enables ZONE_DEVICE with struct vmem_altmap
> support.
>
> Testing:
>
> Tested hot remove on arm64 for all 4K, 16K, 64K page config options with
> all possible VA_BITS and PGTABLE_LEVELS combinations. Tested ZONE_DEVICE
> with ARM64_4K_PAGES through a dummy driver.
>
> Build tested on non arm64 platforms. I will appreciate if folks can test
> arch_remove_memory() re-ordering in __remove_memory() on other platforms.
>
> Dependency:
>
> V5 series in the thread (https://lkml.org/lkml/2019/2/14/1096) will make
> kernel linear mapping loose pgtable_page_ctor() init. When this happens
> the proposed functions free_pte|pmd|pud_table() in [PATCH 2/6] will have
> to stop calling pgtable_page_dtor().

Hi Anshuman,

I'd be interested to integrate this with the sub-section hotplug
support [1]. Otherwise the padding implementation in libnvdimm can't
be removed unless all ZONE_DEVICE capable archs also agree on the
minimum arch_add_memory() granularity. I'd prefer not to special case
which archs support which granularity, but it unfortunately
complicates what you're trying to achieve.

I think at a minimum we, mm hotplug co-travellers, need to come to a
consensus on whether sub-section support is viable for v5.2 and / or a
pre-requisite for new arch-ZONE_DEVICE implementations.

