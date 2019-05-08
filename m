Return-Path: <SRS0=OmxZ=TI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B5EC3C04A6B
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 20:26:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6F12220989
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 20:26:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6F12220989
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 097E46B0003; Wed,  8 May 2019 16:26:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 04A336B0005; Wed,  8 May 2019 16:26:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E79536B0007; Wed,  8 May 2019 16:26:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id C5DA76B0003
	for <linux-mm@kvack.org>; Wed,  8 May 2019 16:26:21 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id b46so204975qte.6
        for <linux-mm@kvack.org>; Wed, 08 May 2019 13:26:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=i3K+aC6oh3nHkKBolesJxB87q22raEk9yaetGxzfsjU=;
        b=jT8VwlCu3nKb6GOpckoGZYESTQfS5BgdcjBGZDvzUMpzE8GHRNl4+Sjzck8wCZWwuc
         QKvXTr5SisILbClC287YwOryXSNEI7oSt3SoXFdpYMkDA2JWg+kd60IaTyPIdIrEo+AE
         hxCADMTLS7C6EbXDyqAT54KbhawUzdxMCpJ2CeCApWd+2v2LqQtLaDgH5oa5zb6Olx+R
         CBdvxpSLURmmjQQr55ordUxqZBQNgmgsKz4Ju7NY1pYQrthL19mKjXgP98U4SEWELV5H
         /b/rFA1LTlHLFHI6dwYvIdeoQv1COR+QkHAr+YYZiRxlQgorvSlkCuZvZwTw6JjPB1x+
         7GVA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of lersek@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=lersek@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXnqWm4J2EWzDQffdQYL+64o8WuvxH49N1K4sG/zao5xtuL74bD
	YBVI63kvO+ya2zaOHdBobDwbM+oFTo1JMFXYS7sLfw2GID4kjo5FjlJQQG27dv4FZasjrtzvl+m
	r2XmnlTS73G8WLO7kOE/vu1nKNhB6HLF2csIV/eHp8Mp7mmFxczQmP1nlM+US5b+Bkw==
X-Received: by 2002:a0c:980b:: with SMTP id c11mr143555qvd.115.1557347181497;
        Wed, 08 May 2019 13:26:21 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwrnm58W7imsrqBfdNMYaPvWBYBHlImrIRLY78aet3N28bLQpIjnM+zd1hqOGUQNzSQ1/+t
X-Received: by 2002:a0c:980b:: with SMTP id c11mr143511qvd.115.1557347180780;
        Wed, 08 May 2019 13:26:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557347180; cv=none;
        d=google.com; s=arc-20160816;
        b=oPysABBPGSng01350vsIteiGQbC2Rl+rggqBrV+HDSuVfou7CbeswbZk8bYC9AmPYl
         CT3Vbz9uRuhJ1AnCD3PlNHMWXYAGZOfQbho0jnw7hAPjG7dUUJfYWdfLZg07AOkizEMX
         horeKTvKgIOJsJcdQoX+5ls7iN5/0ieBOZWzXGinOCqti9ONu9oD3Ru41SAaMpmmrJKD
         CDrdyAScNx1YsD/thnSVh+hvYz7gbK1f3jpsdZ9rtn36K8EEeMGCJiVmmd+mzSaaUvu+
         JVVs/Ax5ZLb3u/+g241w+3UM6cT2A/pzuBLfdQvHdIGETOy0ay0DMVW//UXKoRV26SX2
         21rw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=i3K+aC6oh3nHkKBolesJxB87q22raEk9yaetGxzfsjU=;
        b=SeaAcxRu7opwKQjEzxTCW4LcpgMIi4X5Ct/uv2AC7SdozTD7igz6nGKvpsLkk9bRzi
         FcPYufKg9x1fmBF1qOtgvzlsukvNUO6S7Smc16SsjD7Jo2HZgwWJ21QA8f+sRARgIfkm
         w/sO0gPz1kxCr2Jxg8wuZRHHCTgUjn7QMun/rnMLwmuhTxOFt5Pun7ECul/DwPVJnjCh
         o0nO1f9px7JAQtGKzrhxCzBtpMAjv1L4XhciP6fy/cJJGtbjbiumbH4UTaiXiM2h5XCI
         f4MGYvNrEiTZt2Aue/a2j1mmzKxviChEoZ4fq5vwvCUC9uCCTpKPpVs4xKoto4Umyix7
         5I1g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of lersek@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=lersek@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c7si12523367qtm.365.2019.05.08.13.26.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 May 2019 13:26:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of lersek@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of lersek@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=lersek@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id BBB083083391;
	Wed,  8 May 2019 20:26:19 +0000 (UTC)
Received: from lacos-laptop-7.usersys.redhat.com (ovpn-120-255.rdu2.redhat.com [10.10.120.255])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 99F891001DDD;
	Wed,  8 May 2019 20:26:13 +0000 (UTC)
Subject: Re: [Question] Memory hotplug clarification for Qemu ARM/virt
To: Robin Murphy <robin.murphy@arm.com>,
 Shameerali Kolothum Thodi <shameerali.kolothum.thodi@huawei.com>,
 "will.deacon@arm.com" <will.deacon@arm.com>,
 Catalin Marinas <Catalin.Marinas@arm.com>,
 Anshuman Khandual <anshuman.khandual@arm.com>,
 "linux-arm-kernel@lists.infradead.org"
 <linux-arm-kernel@lists.infradead.org>, linux-mm <linux-mm@kvack.org>
Cc: "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>,
 "qemu-arm@nongnu.org" <qemu-arm@nongnu.org>,
 "eric.auger@redhat.com" <eric.auger@redhat.com>,
 Igor Mammedov <imammedo@redhat.com>,
 "peter.maydell@linaro.org" <peter.maydell@linaro.org>,
 Linuxarm <linuxarm@huawei.com>,
 "ard.biesheuvel@linaro.org" <ard.biesheuvel@linaro.org>,
 Jonathan Cameron <jonathan.cameron@huawei.com>, "xuwei (O)"
 <xuwei5@huawei.com>
References: <5FC3163CFD30C246ABAA99954A238FA83F1B6A66@lhreml524-mbs.china.huawei.com>
 <ca5f7231-6924-0720-73a5-766eb13ee331@arm.com>
From: Laszlo Ersek <lersek@redhat.com>
Message-ID: <190831a5-297d-addb-ea56-645afb169efb@redhat.com>
Date: Wed, 8 May 2019 22:26:12 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <ca5f7231-6924-0720-73a5-766eb13ee331@arm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.44]); Wed, 08 May 2019 20:26:20 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 05/08/19 14:50, Robin Murphy wrote:
> Hi Shameer,
> 
> On 08/05/2019 11:15, Shameerali Kolothum Thodi wrote:
>> Hi,
>>
>> This series here[0] attempts to add support for PCDIMM in QEMU for
>> ARM/Virt platform and has stumbled upon an issue as it is not clear(at
>> least
>> from Qemu/EDK2 point of view) how in physical world the hotpluggable
>> memory is handled by kernel.
>>
>> The proposed implementation in Qemu, builds the SRAT and DSDT parts
>> and uses GED device to trigger the hotplug. This works fine.
>>
>> But when we added the DT node corresponding to the PCDIMM(cold plug
>> scenario), we noticed that Guest kernel see this memory during early boot
>> even if we are booting with ACPI. Because of this, hotpluggable memory
>> may end up in zone normal and make it non-hot-un-pluggable even if Guest
>> boots with ACPI.
>>
>> Further discussions[1] revealed that, EDK2 UEFI has no means to
>> interpret the
>> ACPI content from Qemu(this is designed to do so) and uses DT info to
>> build the GetMemoryMap(). To solve this, introduced "hotpluggable"
>> property
>> to DT memory node(patches #7 & #8 from [0]) so that UEFI can
>> differentiate
>> the nodes and exclude the hotpluggable ones from GetMemoryMap().
>>
>> But then Laszlo rightly pointed out that in order to accommodate the
>> changes
>> into UEFI we need to know how exactly Linux expects/handles all the
>> hotpluggable memory scenarios. Please find the discussion here[2].
>>
>> For ease, I am just copying the relevant comment from Laszlo below,
>>
>> /******
>> "Given patches #7 and #8, as I understand them, the firmware cannot
>> distinguish
>>   hotpluggable & present, from hotpluggable & absent. The firmware can
>> only
>>   skip both hotpluggable cases. That's fine in that the firmware will
>> hog neither
>>   type -- but is that OK for the OS as well, for both ACPI boot and DT
>> boot?
>>
>> Consider in particular the "hotpluggable & present, ACPI boot" case.
>> Assuming
>> we modify the firmware to skip "hotpluggable" altogether, the UEFI memmap
>> will not include the range despite it being present at boot.
>> Presumably, ACPI
>> will refer to the range somehow, however. Will that not confuse the OS?
>>
>> When Igor raised this earlier, I suggested that
>> hotpluggable-and-present should
>> be added by the firmware, but also allocated immediately, as
>> EfiBootServicesData
>> type memory. This will prevent other drivers in the firmware from
>> allocating AcpiNVS
>> or Reserved chunks from the same memory range, the UEFI memmap will
>> contain
>> the range as EfiBootServicesData, and then the OS can release that
>> allocation in
>> one go early during boot.
>>
>> But this really has to be clarified from the Linux kernel's
>> expectations. Please
>> formalize all of the following cases:
>>
>> OS boot (DT/ACPI)  hotpluggable & ...  GetMemoryMap() should report
>> as  DT/ACPI should report as
>> -----------------  ------------------ 
>> -------------------------------  ------------------------
>> DT                 present             ?                                ?
>> DT                 absent              ?                                ?
>> ACPI               present             ?                                ?
>> ACPI               absent              ?                                ?
>>
>> Again, this table is dictated by Linux."
>>
>> ******/
>>
>> Could you please take a look at this and let us know what is expected
>> here from
>> a Linux kernel view point.
> 
> For arm64, so far we've not even been considering DT-based hotplug - as
> far as I'm aware there would still be a big open question there around
> notification mechanisms and how to describe them. The DT stuff so far
> has come from the PowerPC folks, so it's probably worth seeing what
> their ideas are.
> 
> ACPI-wise I've always assumed/hoped that hotplug-related things should
> be sufficiently well-specified in UEFI that "do whatever x86/IA-64 do"
> would be enough for us.

As far as I can see in UEFI v2.8 -- and I had checked the spec before
dumping the table with the many question marks on Shameer --, all the
hot-plug language in the spec refers to USB and PCI hot-plug in the
preboot environment. There is not a single word about hot-plug at OS
runtime (regarding any device or component type), nor about memory
hot-plug (at any time).

Looking to x86 appears valid -- so what does the Linux kernel expect on
that architecture, in the "ACPI" rows of the table?

Shameer: if you (Huawei) are represented on the USWG / ASWG, I suggest
re-raising the question on those lists too; at least the "ACPI" rows of
the table.

Thanks!
Laszlo

> 
> Robin.
> 
>> (Hi Laszlo/Igor/Eric, please feel free to add/change if I have missed
>> any valid
>> points above).
>>
>> Thanks,
>> Shameer
>> [0] https://patchwork.kernel.org/cover/10890919/
>> [1] https://patchwork.kernel.org/patch/10863299/
>> [2] https://patchwork.kernel.org/patch/10890937/
>>
>>

