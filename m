Return-Path: <SRS0=5q+O=TJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CBDF3C04AB1
	for <linux-mm@archiver.kernel.org>; Thu,  9 May 2019 16:35:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6D4072173C
	for <linux-mm@archiver.kernel.org>; Thu,  9 May 2019 16:35:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6D4072173C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DFD1E6B0003; Thu,  9 May 2019 12:35:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DAEB16B0006; Thu,  9 May 2019 12:35:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C753A6B0007; Thu,  9 May 2019 12:35:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id A2C5D6B0003
	for <linux-mm@kvack.org>; Thu,  9 May 2019 12:35:34 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id l20so3145686qtq.21
        for <linux-mm@kvack.org>; Thu, 09 May 2019 09:35:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=Z3wQEF6tMh8M20m6RPRu/K8V03r1TTBjl7ghso4mRWo=;
        b=DJ3tYGQMgtujDS5gHYYQIDq7jlUpfXphx7d/GwP68QCmFy9aTnmAIpjW20G69bN8qy
         wpIHPXyzPoBmouPbOmLgM0F7SefaCwF0pSYKZBsXjwkrgyqpNM9iHXVrBGa4BKoWaPUG
         knikkNOleL6rKsgQxEa+DcTiVMPhAzBQ0WSELDVpgn+Aqa/IYatcJQIbdDQX44xG4O3T
         zkQLhn1/M/fDeX8WQo3Aq4EDaXzokVqUMarIWyCSHBYg6nh6YTEeLOh7/b2Y+bc+AKjx
         AFIpubNUKxAw/YKAsGAfuW2AvLrSApwmkHykDeLnrDzAcTJKQs9D5UxZYVq8mOjBLqvz
         Bdxw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of imammedo@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=imammedo@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUVH7SnPTfMqzraE+ia+kZCFBbcccD/68hvJ8HZi9eCuzgSg/DW
	sz6+AnT6joSBkw9Skdg8+pgvPsroKI0PbeYgIK4ilc5CGbPg12jpJaYvF6lL7We+dSP44Rc3Imc
	H1ZmLRDoO/TFnte65LF5P+azOzO46oY7Mmgpv3hNS8wJfCq+Tk5Wdh7mRwAJwcBdZMA==
X-Received: by 2002:a37:4e94:: with SMTP id c142mr4044277qkb.274.1557419734398;
        Thu, 09 May 2019 09:35:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxlolSoYdS33E4VTXuhdhThNMyrgc9pQXLdxEOH8obZi4c3eUg0nbyC2Z5juBZtGJviSy15
X-Received: by 2002:a37:4e94:: with SMTP id c142mr4044202qkb.274.1557419733558;
        Thu, 09 May 2019 09:35:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557419733; cv=none;
        d=google.com; s=arc-20160816;
        b=TLprqI1QaK+cPGdzRU3N2BevvN6DdbZHeu+xKRicSL3dkeRsuI03wjkM6gsC8KvtDu
         NuCdE5ZFCn5MNuGrfoea0LUmZX/9cdtE+mKlP35x85VgvrzK/yXtRPBbz7veUvghMDL5
         Ko0MD6ryuJxxLae4Vc6ZJ/THppeMKO1aqzBMyKaZQM3Zl+gKJhruT84KeQVXcwZEn1m0
         zGS0EscvBvSIQ6YWFOIfQ/uJA9b6Z0/iX3HUw5IGz4dcrE4tqb8r+Pnb+6lQmpCIv498
         sEAMntsH/Rc1qP1VGOp7YX5dWz8JGtQQRpR/wSXpiIrhnoV3poBR9OXpMzkBt0CDH1N9
         RMLg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=Z3wQEF6tMh8M20m6RPRu/K8V03r1TTBjl7ghso4mRWo=;
        b=up/IQIzT3Fv7FMbrmLRHz+y3aHqxwEw1Ad8UcszllyA6pX6x3cSaMK9CPz5OC6U+Vp
         Wk8FCNC7ttmVzLX038gaILa+K1E9xVKx3AkQOAz8D3H4lK+kFIQXN8uEJKe53ppUvme6
         X4DCU0xcmIn7Pz1AHL6iZu+YV9EA4xW9DNLOlLAb3Rbi6ZDcOQREjqUhOcSV41lIeXBQ
         +fjBe2ZGql7Ur5fP9GMvavO2BFUu1AAV8RVPVyC+Y4bADLyosBaUSGyUSHVai2K7ZN7q
         VvtzaSsdCWTFNDpNOph2TpPip/+lt5SFVJ4O8HC471jo+5/V6ZCAAwQ9AH2s48yH/lOm
         3H7Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of imammedo@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=imammedo@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c185si1154232qkd.249.2019.05.09.09.35.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 May 2019 09:35:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of imammedo@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of imammedo@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=imammedo@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 630CB308FC5E;
	Thu,  9 May 2019 16:35:32 +0000 (UTC)
Received: from Igors-MacBook-Pro (ovpn-204-72.brq.redhat.com [10.40.204.72])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 9E91A5B680;
	Thu,  9 May 2019 16:35:26 +0000 (UTC)
Date: Thu, 9 May 2019 18:35:20 +0200
From: Igor Mammedov <imammedo@redhat.com>
To: Laszlo Ersek <lersek@redhat.com>
Cc: Robin Murphy <robin.murphy@arm.com>, Shameerali Kolothum Thodi
 <shameerali.kolothum.thodi@huawei.com>, "will.deacon@arm.com"
 <will.deacon@arm.com>, Catalin Marinas <Catalin.Marinas@arm.com>, Anshuman
 Khandual <anshuman.khandual@arm.com>,
 "linux-arm-kernel@lists.infradead.org"
 <linux-arm-kernel@lists.infradead.org>, linux-mm <linux-mm@kvack.org>,
 "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "qemu-arm@nongnu.org"
 <qemu-arm@nongnu.org>, "eric.auger@redhat.com" <eric.auger@redhat.com>,
 "peter.maydell@linaro.org" <peter.maydell@linaro.org>, Linuxarm
 <linuxarm@huawei.com>, "ard.biesheuvel@linaro.org"
 <ard.biesheuvel@linaro.org>, Jonathan Cameron
 <jonathan.cameron@huawei.com>, "xuwei (O)" <xuwei5@huawei.com>
Subject: Re: [Question] Memory hotplug clarification for Qemu ARM/virt
Message-ID: <20190509183520.6dc47f2e@Igors-MacBook-Pro>
In-Reply-To: <190831a5-297d-addb-ea56-645afb169efb@redhat.com>
References: <5FC3163CFD30C246ABAA99954A238FA83F1B6A66@lhreml524-mbs.china.huawei.com>
	<ca5f7231-6924-0720-73a5-766eb13ee331@arm.com>
	<190831a5-297d-addb-ea56-645afb169efb@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.43]); Thu, 09 May 2019 16:35:32 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 8 May 2019 22:26:12 +0200
Laszlo Ersek <lersek@redhat.com> wrote:

> On 05/08/19 14:50, Robin Murphy wrote:
> > Hi Shameer,
> >=20
> > On 08/05/2019 11:15, Shameerali Kolothum Thodi wrote:
> >> Hi,
> >>
> >> This series here[0] attempts to add support for PCDIMM in QEMU for
> >> ARM/Virt platform and has stumbled upon an issue as it is not clear(at
> >> least
> >> from Qemu/EDK2 point of view) how in physical world the hotpluggable
> >> memory is handled by kernel.
> >>
> >> The proposed implementation in Qemu, builds the SRAT and DSDT parts
> >> and uses GED device to trigger the hotplug. This works fine.
> >>
> >> But when we added the DT node corresponding to the PCDIMM(cold plug
> >> scenario), we noticed that Guest kernel see this memory during early b=
oot
> >> even if we are booting with ACPI. Because of this, hotpluggable memory
> >> may end up in zone normal and make it non-hot-un-pluggable even if Gue=
st
> >> boots with ACPI.
> >>
> >> Further discussions[1] revealed that, EDK2 UEFI has no means to
> >> interpret the
> >> ACPI content from Qemu(this is designed to do so) and uses DT info to
> >> build the GetMemoryMap(). To solve this, introduced "hotpluggable"
> >> property
> >> to DT memory node(patches #7 & #8 from [0]) so that UEFI can
> >> differentiate
> >> the nodes and exclude the hotpluggable ones from GetMemoryMap().
> >>
> >> But then Laszlo rightly pointed out that in order to accommodate the
> >> changes
> >> into UEFI we need to know how exactly Linux expects/handles all the
> >> hotpluggable memory scenarios. Please find the discussion here[2].
> >>
> >> For ease, I am just copying the relevant comment from Laszlo below,
> >>
> >> /******
> >> "Given patches #7 and #8, as I understand them, the firmware cannot
> >> distinguish
> >> =C2=A0 hotpluggable & present, from hotpluggable & absent. The firmwar=
e can
> >> only
> >> =C2=A0 skip both hotpluggable cases. That's fine in that the firmware =
will
> >> hog neither
> >> =C2=A0 type -- but is that OK for the OS as well, for both ACPI boot a=
nd DT
> >> boot?
> >>
> >> Consider in particular the "hotpluggable & present, ACPI boot" case.
> >> Assuming
> >> we modify the firmware to skip "hotpluggable" altogether, the UEFI mem=
map
> >> will not include the range despite it being present at boot.
> >> Presumably, ACPI
> >> will refer to the range somehow, however. Will that not confuse the OS?
> >>
> >> When Igor raised this earlier, I suggested that
> >> hotpluggable-and-present should
> >> be added by the firmware, but also allocated immediately, as
> >> EfiBootServicesData
> >> type memory. This will prevent other drivers in the firmware from
> >> allocating AcpiNVS
> >> or Reserved chunks from the same memory range, the UEFI memmap will
> >> contain
> >> the range as EfiBootServicesData, and then the OS can release that
> >> allocation in
> >> one go early during boot.
> >>
> >> But this really has to be clarified from the Linux kernel's
> >> expectations. Please
> >> formalize all of the following cases:
> >>
> >> OS boot (DT/ACPI)=C2=A0 hotpluggable & ...=C2=A0 GetMemoryMap() should=
 report
> >> as=C2=A0 DT/ACPI should report as
> >> -----------------=C2=A0 ------------------=C2=A0
> >> -------------------------------=C2=A0 ------------------------
> >> DT=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 present=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 ?=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
 ?
> >> DT=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 absent=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 ?=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0 ?
> >> ACPI=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0 present=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0 ?=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 ?
> >> ACPI=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0 absent=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 ?=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 ?
> >>
> >> Again, this table is dictated by Linux."
> >>
> >> ******/
> >>
> >> Could you please take a look at this and let us know what is expected
> >> here from
> >> a Linux kernel view point.
> >=20
> > For arm64, so far we've not even been considering DT-based hotplug - as
> > far as I'm aware there would still be a big open question there around
> > notification mechanisms and how to describe them. The DT stuff so far
> > has come from the PowerPC folks, so it's probably worth seeing what
> > their ideas are.
> >=20
> > ACPI-wise I've always assumed/hoped that hotplug-related things should
> > be sufficiently well-specified in UEFI that "do whatever x86/IA-64 do"
> > would be enough for us.
>=20
> As far as I can see in UEFI v2.8 -- and I had checked the spec before
> dumping the table with the many question marks on Shameer --, all the
> hot-plug language in the spec refers to USB and PCI hot-plug in the
> preboot environment. There is not a single word about hot-plug at OS
> runtime (regarding any device or component type), nor about memory
> hot-plug (at any time).
>
> Looking to x86 appears valid -- so what does the Linux kernel expect on
> that architecture, in the "ACPI" rows of the table?

I could only answer from QEMU x86 perspective.
QEMU for x86 guests currently doesn't add hot-pluggable RAM into E820
because of different linux guests tend to cannibalize it, making it non
unpluggable. The last culprit I recall was KASLR.

So I'd refrain from reporting hotpluggable RAM in GetMemoryMap() if
it's possible (it's probably hack (spec deosn't say anything about it)
but it mostly works for Linux (plug/unplug) and Windows guest also
fine with plug part (no unplug there)).

As for physical systems, there are out there ones that do report
hotpluggable RAM in GetMemoryMap().

> Shameer: if you (Huawei) are represented on the USWG / ASWG, I suggest
> re-raising the question on those lists too; at least the "ACPI" rows of
> the table.
>=20
> Thanks!
> Laszlo
>=20
> >=20
> > Robin.
> >=20
> >> (Hi Laszlo/Igor/Eric, please feel free to add/change if I have missed
> >> any valid
> >> points above).
> >>
> >> Thanks,
> >> Shameer
> >> [0] https://patchwork.kernel.org/cover/10890919/
> >> [1] https://patchwork.kernel.org/patch/10863299/
> >> [2] https://patchwork.kernel.org/patch/10890937/
> >>
> >>
>=20

