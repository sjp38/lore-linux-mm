Return-Path: <SRS0=OmxZ=TI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B2C9AC04A6B
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 12:50:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5E74620989
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 12:50:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5E74620989
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EBE946B0007; Wed,  8 May 2019 08:50:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E6EE16B0008; Wed,  8 May 2019 08:50:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D36DA6B000A; Wed,  8 May 2019 08:50:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 85B416B0007
	for <linux-mm@kvack.org>; Wed,  8 May 2019 08:50:36 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id c1so15815718edi.20
        for <linux-mm@kvack.org>; Wed, 08 May 2019 05:50:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=WwK673gLV/3ycptBHv5Do6aXOIvtBxyQ9rIEWQPniXA=;
        b=I1L8lemMToBGsZzGWsOtKmU0f3OMv75lYB2Xk/CEtEBUI4uH02AufzPMUfqDA7R8qb
         E+zy+Q/5yZ1/GoCScxRTU5BEENhxKA2jciMcxL/cWQIxbzjk7sFcEL+dJKqVTCSeAAdy
         QVkCS/jgdtyoSEffX809qygAbxBEKu8es+2bwMDBVPcYrcQyxK5s0dRA2TJNrWEmU5zR
         6x+j1yQwyWBYn63+Qig+4L4dzvqpkQsYcHGcccHApTTJEH/BCs/0GhgtOqKCcB8XmmlX
         8bEoTfZiid7Hjl3bq/W/dJAr6aTsrnRo+B7u7jq8qHXsfXEpfl9kJGT5KBLglEZAlP/p
         wElA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of robin.murphy@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=robin.murphy@arm.com
X-Gm-Message-State: APjAAAXmYZYEopjepO3xKGku0MWd1b6icnWIeGi8i+9E9IkgZ1wPaMbY
	Sg4XaBNjvynHULaCRtzuv6yculgmNUIlZfYC9bzLWeQtairkN9i+hE6tIYb5OvHCQK9eOW/Z3Sg
	271fsU3IuyIoVJecQDGUKdj2tpQ4SItry2Bby/XrXlQJatyFCbnPz3xJUvyKQvoTabQ==
X-Received: by 2002:a17:906:6a1a:: with SMTP id o26mr29449137ejr.170.1557319836052;
        Wed, 08 May 2019 05:50:36 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwonhIFiH+G4w6kyrJ4MqqIc3S2wyn/Rz22Uh8yi0EwxI3YiTNb02oVsLn12qL/oC603d5z
X-Received: by 2002:a17:906:6a1a:: with SMTP id o26mr29449065ejr.170.1557319834983;
        Wed, 08 May 2019 05:50:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557319834; cv=none;
        d=google.com; s=arc-20160816;
        b=gm8hNesL8hapol54npbaJBb9AM1BUfsAr9jWNGqY968NzZPlkuQgb7OcAd9zeTVGt2
         +H1xfwnAwkEaX7Cu22rdnjBHhqscsxxh+XJ9a2LqBPOfBfEVfvTtWIDJ66Xundlieqk4
         V7n4QwoT0SUy58dw/U8Uq2kB9nYpNtI1mlRWo1adHc6p3XBMeKERHDOxHSnIXYdzWUeA
         WK5/LQ9jJvB3DH7Or2zIgiF8Xu6ssi2waionlgMNYCA9dLvjPFsfWhgY3k6OWQFDTjyd
         PCiypuK/vWEMnxeJuhcX9aBT4fn9TstkXIbc+CwjAZ8h5NLRdixQy4YDilQFFV2mRGlK
         zcmA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=WwK673gLV/3ycptBHv5Do6aXOIvtBxyQ9rIEWQPniXA=;
        b=YO8GRZX3BEyybhp1z8f3bcQhe2sFTvfTkcsCRGigjUhzr2kPI2UYIi2msxXUgSUNsf
         /fg4WzDB8cn+jDQz+U/g779tFoQz/+umbl9gRdtYHn96Jj2bmtSknv+DhezSqAec1MN7
         XuU5e0GxlYEnxBuHE2fC8Nx2dYf0179jsc9w7wqxc/GoWpjQQrusf/tJhas25hwHc/IZ
         CYPChowoOMoPd6V22VsbxcDkTU8FTpAvAvZgY90SlnBggFIJ8BfW+Igxx0JJo95ybiTK
         NwNiNCzKVhTsqCmKmr3nfuM7u0RVz67kkJqx+f8YWVuAk4QCsik/LePFh+Zfjacm4i8B
         M92g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of robin.murphy@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=robin.murphy@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id a18si5183043edt.154.2019.05.08.05.50.34
        for <linux-mm@kvack.org>;
        Wed, 08 May 2019 05:50:34 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of robin.murphy@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of robin.murphy@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=robin.murphy@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id A6F5380D;
	Wed,  8 May 2019 05:50:33 -0700 (PDT)
Received: from [10.1.196.75] (e110467-lin.cambridge.arm.com [10.1.196.75])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 2459A3F575;
	Wed,  8 May 2019 05:50:30 -0700 (PDT)
Subject: Re: [Question] Memory hotplug clarification for Qemu ARM/virt
To: Shameerali Kolothum Thodi <shameerali.kolothum.thodi@huawei.com>,
 "will.deacon@arm.com" <will.deacon@arm.com>,
 Catalin Marinas <Catalin.Marinas@arm.com>,
 Anshuman Khandual <anshuman.khandual@arm.com>,
 "linux-arm-kernel@lists.infradead.org"
 <linux-arm-kernel@lists.infradead.org>, linux-mm <linux-mm@kvack.org>
Cc: "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>,
 "qemu-arm@nongnu.org" <qemu-arm@nongnu.org>,
 "eric.auger@redhat.com" <eric.auger@redhat.com>,
 Igor Mammedov <imammedo@redhat.com>, Laszlo Ersek <lersek@redhat.com>,
 "peter.maydell@linaro.org" <peter.maydell@linaro.org>,
 Linuxarm <linuxarm@huawei.com>,
 "ard.biesheuvel@linaro.org" <ard.biesheuvel@linaro.org>,
 Jonathan Cameron <jonathan.cameron@huawei.com>, "xuwei (O)"
 <xuwei5@huawei.com>
References: <5FC3163CFD30C246ABAA99954A238FA83F1B6A66@lhreml524-mbs.china.huawei.com>
From: Robin Murphy <robin.murphy@arm.com>
Message-ID: <ca5f7231-6924-0720-73a5-766eb13ee331@arm.com>
Date: Wed, 8 May 2019 13:50:29 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <5FC3163CFD30C246ABAA99954A238FA83F1B6A66@lhreml524-mbs.china.huawei.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-GB
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Shameer,

On 08/05/2019 11:15, Shameerali Kolothum Thodi wrote:
> Hi,
> 
> This series here[0] attempts to add support for PCDIMM in QEMU for
> ARM/Virt platform and has stumbled upon an issue as it is not clear(at least
> from Qemu/EDK2 point of view) how in physical world the hotpluggable
> memory is handled by kernel.
> 
> The proposed implementation in Qemu, builds the SRAT and DSDT parts
> and uses GED device to trigger the hotplug. This works fine.
> 
> But when we added the DT node corresponding to the PCDIMM(cold plug
> scenario), we noticed that Guest kernel see this memory during early boot
> even if we are booting with ACPI. Because of this, hotpluggable memory
> may end up in zone normal and make it non-hot-un-pluggable even if Guest
> boots with ACPI.
> 
> Further discussions[1] revealed that, EDK2 UEFI has no means to interpret the
> ACPI content from Qemu(this is designed to do so) and uses DT info to
> build the GetMemoryMap(). To solve this, introduced "hotpluggable" property
> to DT memory node(patches #7 & #8 from [0]) so that UEFI can differentiate
> the nodes and exclude the hotpluggable ones from GetMemoryMap().
> 
> But then Laszlo rightly pointed out that in order to accommodate the changes
> into UEFI we need to know how exactly Linux expects/handles all the
> hotpluggable memory scenarios. Please find the discussion here[2].
> 
> For ease, I am just copying the relevant comment from Laszlo below,
> 
> /******
> "Given patches #7 and #8, as I understand them, the firmware cannot distinguish
>   hotpluggable & present, from hotpluggable & absent. The firmware can only
>   skip both hotpluggable cases. That's fine in that the firmware will hog neither
>   type -- but is that OK for the OS as well, for both ACPI boot and DT boot?
> 
> Consider in particular the "hotpluggable & present, ACPI boot" case. Assuming
> we modify the firmware to skip "hotpluggable" altogether, the UEFI memmap
> will not include the range despite it being present at boot. Presumably, ACPI
> will refer to the range somehow, however. Will that not confuse the OS?
> 
> When Igor raised this earlier, I suggested that hotpluggable-and-present should
> be added by the firmware, but also allocated immediately, as EfiBootServicesData
> type memory. This will prevent other drivers in the firmware from allocating AcpiNVS
> or Reserved chunks from the same memory range, the UEFI memmap will contain
> the range as EfiBootServicesData, and then the OS can release that allocation in
> one go early during boot.
> 
> But this really has to be clarified from the Linux kernel's expectations. Please
> formalize all of the following cases:
> 
> OS boot (DT/ACPI)  hotpluggable & ...  GetMemoryMap() should report as  DT/ACPI should report as
> -----------------  ------------------  -------------------------------  ------------------------
> DT                 present             ?                                ?
> DT                 absent              ?                                ?
> ACPI               present             ?                                ?
> ACPI               absent              ?                                ?
> 
> Again, this table is dictated by Linux."
> 
> ******/
> 
> Could you please take a look at this and let us know what is expected here from
> a Linux kernel view point.

For arm64, so far we've not even been considering DT-based hotplug - as 
far as I'm aware there would still be a big open question there around 
notification mechanisms and how to describe them. The DT stuff so far 
has come from the PowerPC folks, so it's probably worth seeing what 
their ideas are.

ACPI-wise I've always assumed/hoped that hotplug-related things should 
be sufficiently well-specified in UEFI that "do whatever x86/IA-64 do" 
would be enough for us.

Robin.

> (Hi Laszlo/Igor/Eric, please feel free to add/change if I have missed any valid
> points above).
> 
> Thanks,
> Shameer
> [0] https://patchwork.kernel.org/cover/10890919/
> [1] https://patchwork.kernel.org/patch/10863299/
> [2] https://patchwork.kernel.org/patch/10890937/
> 
> 

