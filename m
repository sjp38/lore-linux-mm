Return-Path: <SRS0=OmxZ=TI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2E11EC04A6B
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 10:16:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9779420578
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 10:16:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9779420578
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E71006B0003; Wed,  8 May 2019 06:16:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E21226B0005; Wed,  8 May 2019 06:16:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CE9666B0007; Wed,  8 May 2019 06:16:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 802B26B0003
	for <linux-mm@kvack.org>; Wed,  8 May 2019 06:16:03 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id h12so16498066edl.23
        for <linux-mm@kvack.org>; Wed, 08 May 2019 03:16:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:thread-topic:thread-index:date:message-id:accept-language
         :content-language:content-transfer-encoding:mime-version;
        bh=byJdI3x3VFtFKMHbhuSBdGP3x+peDDG32uwuyiS7/1c=;
        b=mYXpZHU/1MH8ou4hbTwCz+u/JwqfF4bvmZ3vpSqz3XLSPKURf/MvjEu26Ixl6E3RST
         E6PMU4iyhaMoFT4mmpwlSi9JADwxfI/+umhuqlXPUvtvcLe9YjYhex0It7WrlaiLVddE
         9HZ4LkSRc8VPd5Clb06aMR+W0BkzcWKrc46U4r1ZcZUtrGtEDU4BWPX2X/MIP4JX81s0
         vGE4dMmxQTykSvKdEydxBO1bHuV3Nc8RrOixcR2P0mge8k5Gkc8HsPIirxGryb4OVn8Q
         6EC5R7DnZy94Yz+5UoPexGaVQzbh+C7hgDwBG7RZUSF3Z+QjuU2mIqMCCly8BOdSMJwu
         6LlQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of shameerali.kolothum.thodi@huawei.com designates 185.176.76.210 as permitted sender) smtp.mailfrom=shameerali.kolothum.thodi@huawei.com
X-Gm-Message-State: APjAAAU+JgRGpQluum8TuX9aRJQUrRtXd5K3lDAkXwFp1ADpjW6kOOlZ
	T/Hzqbx977L94BoLtJhwVr2RcLtGLoU48Gukx9aGjPpywoDQagGUWC9/exuj2QyLwDZ+xsWAjin
	QZEiC+68lJc30S7mO4AX739yX1atlOaJEGUjtxnGnmBSEpY9A/nReZQzovOXID89Dvw==
X-Received: by 2002:a50:be44:: with SMTP id b4mr32520812edi.35.1557310562898;
        Wed, 08 May 2019 03:16:02 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw2g3ZFrUZr5NIDcVOmLFVUNd8tWA1QFObHrnjSlG3jfAarw85wvv41DS/jcVlQF8llYRPI
X-Received: by 2002:a50:be44:: with SMTP id b4mr32520721edi.35.1557310561802;
        Wed, 08 May 2019 03:16:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557310561; cv=none;
        d=google.com; s=arc-20160816;
        b=AGWLItWQGUfNTbzBHzLYmbF6Prz5SqECu7jJFrCEbt76Llr5aPZCg8NtGMaMK/8d0c
         QuCArl+Dim/xegGg15qSrwpAoiIF82lABmoZYAlCMdhsTglHn8gcbNES+wIXM93PBXnC
         IvqL2asjEi+XKH0pYDDzyhTMNenp5mkdWd7/37tcVwno3viFEmuFr2Sh3oLd0a2l0ESm
         sSRn1CZ/ihD7VqGSAhwkFs1Y1wPwqEwQUAMwDsDFkbwjhWDcunuFo8+/WvhG6KNnHt+v
         WRRBBXOtzOCfJHZtZtfvNve6CXHngf/YqGOiV+Gm+nYGVesAKvh3uwswIJzsB9O+YVcc
         xMnw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-language
         :accept-language:message-id:date:thread-index:thread-topic:subject
         :cc:to:from;
        bh=byJdI3x3VFtFKMHbhuSBdGP3x+peDDG32uwuyiS7/1c=;
        b=L8q8JeKBrYRxr7D/79JgdcYKYaZy7bTd4sjn98USWSdKobCfzaUKh2QxwgZreHjVY0
         wnRDJFZJYXycXDecLksL/gE2NBzrUg19O5NfxDNdt2DZL7R/RF3xUy7cXdqrajjo6uHA
         svLz4iVhJMPXEU5LCamq8vD+fG8slL3ZFnWotGfLrugALwUph9EPZ8wWK7WBHwlpmhPu
         +ZgXxny07ruaFBECMT6wyo6E83KPfcPIe8v3nMuk6sg1LMAnDCYrmLNw/jdpUzMcPL8l
         oBH2REXZTsjh0eDULbIVWKgXBS7Jp4ftLOIVwIGXY/G9viXfziZi2XdH0+VbaIwOsLmq
         XmOQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of shameerali.kolothum.thodi@huawei.com designates 185.176.76.210 as permitted sender) smtp.mailfrom=shameerali.kolothum.thodi@huawei.com
Received: from huawei.com (lhrrgout.huawei.com. [185.176.76.210])
        by mx.google.com with ESMTPS id i5si4138333ejb.16.2019.05.08.03.16.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 May 2019 03:16:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of shameerali.kolothum.thodi@huawei.com designates 185.176.76.210 as permitted sender) client-ip=185.176.76.210;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of shameerali.kolothum.thodi@huawei.com designates 185.176.76.210 as permitted sender) smtp.mailfrom=shameerali.kolothum.thodi@huawei.com
Received: from lhreml703-cah.china.huawei.com (unknown [172.18.7.108])
	by Forcepoint Email with ESMTP id 1AD5B8EA87B25B67F17B;
	Wed,  8 May 2019 11:16:01 +0100 (IST)
Received: from LHREML524-MBS.china.huawei.com ([169.254.2.137]) by
 lhreml703-cah.china.huawei.com ([10.201.108.44]) with mapi id 14.03.0415.000;
 Wed, 8 May 2019 11:15:51 +0100
From: Shameerali Kolothum Thodi <shameerali.kolothum.thodi@huawei.com>
To: "robin.murphy@arm.com" <robin.murphy@arm.com>, "will.deacon@arm.com"
	<will.deacon@arm.com>, Catalin Marinas <Catalin.Marinas@arm.com>, "Anshuman
 Khandual" <anshuman.khandual@arm.com>, "linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>, linux-mm <linux-mm@kvack.org>
CC: "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "qemu-arm@nongnu.org"
	<qemu-arm@nongnu.org>, "eric.auger@redhat.com" <eric.auger@redhat.com>,
	"Igor Mammedov" <imammedo@redhat.com>, Laszlo Ersek <lersek@redhat.com>,
	"peter.maydell@linaro.org" <peter.maydell@linaro.org>, Linuxarm
	<linuxarm@huawei.com>, "ard.biesheuvel@linaro.org"
	<ard.biesheuvel@linaro.org>, Jonathan Cameron <jonathan.cameron@huawei.com>,
	"xuwei (O)" <xuwei5@huawei.com>
Subject: [Question] Memory hotplug clarification for Qemu ARM/virt 
Thread-Topic: [Question] Memory hotplug clarification for Qemu ARM/virt 
Thread-Index: AdUFf3K/4T6J1HYjRj6wDE9hxn3APQ==
Date: Wed, 8 May 2019 10:15:50 +0000
Message-ID: <5FC3163CFD30C246ABAA99954A238FA83F1B6A66@lhreml524-mbs.china.huawei.com>
Accept-Language: en-GB, en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-originating-ip: [10.202.227.237]
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-CFilter-Loop: Reflected
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

This series here[0] attempts to add support for PCDIMM in QEMU for
ARM/Virt platform and has stumbled upon an issue as it is not clear(at leas=
t
from Qemu/EDK2 point of view) how in physical world the hotpluggable
memory is handled by kernel.

The proposed implementation in Qemu, builds the SRAT and DSDT parts
and uses GED device to trigger the hotplug. This works fine.

But when we added the DT node corresponding to the PCDIMM(cold plug
scenario), we noticed that Guest kernel see this memory during early boot
even if we are booting with ACPI. Because of this, hotpluggable memory
may end up in zone normal and make it non-hot-un-pluggable even if Guest
boots with ACPI.

Further discussions[1] revealed that, EDK2 UEFI has no means to interpret t=
he
ACPI content from Qemu(this is designed to do so) and uses DT info to
build the GetMemoryMap(). To solve this, introduced "hotpluggable" property
to DT memory node(patches #7 & #8 from [0]) so that UEFI can differentiate
the nodes and exclude the hotpluggable ones from GetMemoryMap().

But then Laszlo rightly pointed out that in order to accommodate the change=
s
into UEFI we need to know how exactly Linux expects/handles all the=20
hotpluggable memory scenarios. Please find the discussion here[2].

For ease, I am just copying the relevant comment from Laszlo below,

/******
"Given patches #7 and #8, as I understand them, the firmware cannot disting=
uish
 hotpluggable & present, from hotpluggable & absent. The firmware can only
 skip both hotpluggable cases. That's fine in that the firmware will hog ne=
ither
 type -- but is that OK for the OS as well, for both ACPI boot and DT boot?

Consider in particular the "hotpluggable & present, ACPI boot" case. Assumi=
ng
we modify the firmware to skip "hotpluggable" altogether, the UEFI memmap
will not include the range despite it being present at boot. Presumably, AC=
PI
will refer to the range somehow, however. Will that not confuse the OS?

When Igor raised this earlier, I suggested that hotpluggable-and-present sh=
ould
be added by the firmware, but also allocated immediately, as EfiBootService=
sData
type memory. This will prevent other drivers in the firmware from allocatin=
g AcpiNVS
or Reserved chunks from the same memory range, the UEFI memmap will contain
the range as EfiBootServicesData, and then the OS can release that allocati=
on in
one go early during boot.

But this really has to be clarified from the Linux kernel's expectations. P=
lease
formalize all of the following cases:

OS boot (DT/ACPI)  hotpluggable & ...  GetMemoryMap() should report as  DT/=
ACPI should report as
-----------------  ------------------  -------------------------------  ---=
---------------------
DT                 present             ?                                ?
DT                 absent              ?                                ?
ACPI               present             ?                                ?
ACPI               absent              ?                                ?

Again, this table is dictated by Linux."

******/

Could you please take a look at this and let us know what is expected here =
from
a Linux kernel view point.

(Hi Laszlo/Igor/Eric, please feel free to add/change if I have missed any v=
alid
points above).

Thanks,
Shameer
[0] https://patchwork.kernel.org/cover/10890919/
[1] https://patchwork.kernel.org/patch/10863299/
[2] https://patchwork.kernel.org/patch/10890937/


