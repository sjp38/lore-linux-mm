Return-Path: <SRS0=iTus=TK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 64100C04AB2
	for <linux-mm@archiver.kernel.org>; Fri, 10 May 2019 15:05:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E35232175B
	for <linux-mm@archiver.kernel.org>; Fri, 10 May 2019 15:05:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E35232175B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 463076B02A9; Fri, 10 May 2019 11:05:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3EE686B02AA; Fri, 10 May 2019 11:05:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 28DA96B02AB; Fri, 10 May 2019 11:05:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 01BF16B02A9
	for <linux-mm@kvack.org>; Fri, 10 May 2019 11:05:22 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id g7so5712456qkb.7
        for <linux-mm@kvack.org>; Fri, 10 May 2019 08:05:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=EjdIb3oSgOcQyov67hebVbAGGHf4CbqDbqo+sWd/ai0=;
        b=hn0IZHV0yprjLasy9ow8wYp0pDaPxY5K05Q9vlTDzcyjMcgNc/Lh7Z+Bxwxc6aW/eK
         CAlmSKWkw+YGDJzUMp+fqMauAZvY29ublXHo4m3Fo7j2ALlPOyF9IMsRWWbcjo8RuXUu
         UIusd/IByMsusN2F+htyaO32PktJ89wx5RlZmBe0qtMEB+v9oEJUBoeUV3A+bDL0to5a
         DEQd3jvlFG52Ftey5CAr9+5bXkAd0K8DNuPLJQHEdEjMIQeH15orQWbNT72dEU0p1Se1
         GE/4kU8TAxuz0pHaAmzkmlXF2px+n34tDcrPeqVldj3b5SEPpslMbcufxAVSFWo3CkMg
         rr4g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of imammedo@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=imammedo@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXzb0Z1DmzgesjPiXROu8fPeWvRTASR8s4ueMljRHcu+dzs7I80
	VS0AJmi6jst08TkwftooymaF29vIFwNI7xh12JFKS/1oGphUjN8Ctjzjmuefwb479Fg8/MdUX5h
	7k9s7/8/ufwaDzOB58J/9s0C+q8iHO+KxbRYmBBAv7S4vbjCZFn8Dc2yxqbt5SkgYug==
X-Received: by 2002:ac8:a81:: with SMTP id d1mr4934557qti.276.1557500721704;
        Fri, 10 May 2019 08:05:21 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxJCFWnHH8Wox3ECEuoYPd9N+pCgA+34Xa2P27OQZqAXCXbPRrMA1OnzbOP3IHaP6wZDE4N
X-Received: by 2002:ac8:a81:: with SMTP id d1mr4934453qti.276.1557500720711;
        Fri, 10 May 2019 08:05:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557500720; cv=none;
        d=google.com; s=arc-20160816;
        b=XZQ7uFWa/U0/niPYjmxBEz+FLvb5Hm7T88ZP6th/X9zgF4KiZrTcxaplKfGf4TIoCU
         dI7t8bMzWC5FnklgdhQykXsIIduM2bTs6lT3SBth9dYS51IPkic1iZLRfsRplb72tz9s
         CdO192xBcMnolfFjVdQed6r63adopxznrq9nSw9z0I3zLs8R0UhkZ4igGH0+k2hUy06q
         15V5p5RWgJo2jSylke6AmCwVMkLtFP0h4BaB6NzcStZzuUbKBMnbu2tzBNm4oIofTgyp
         NLBjIjVaK/f900ZYc+IXn2j8YzKTGYn6/kxnClpcXk3PcHxbcdpC9aLs6zaOMrSNpQDl
         1r5g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=EjdIb3oSgOcQyov67hebVbAGGHf4CbqDbqo+sWd/ai0=;
        b=RStckDMs+AEeFS6vlx+qIhZL6I3h5IByvVR4iKn/zB7mrqskXl9QbXZzWqLEHomV3A
         Awf8Hn7UgoPn992vCBKnXFrZgXh8WRmRFtVYgMYsgthZx6jBo1g8iM++zpopumBnVk6x
         8diwoe7p1Vj/XzGqCsR69oWe0P5xlD0MVnOGwuW6iB/DJEfTLJ3Ljcv4a92/SsBXJDTc
         0lrS4T7S+zX5Xf6+6arkgkpSbvJxrhJJC3tHuJ6NPMvHe1RxxDIeN5XojG/vO5bICm0K
         s6hmuWt7gRNbHi7utRqxOkN+eWgj+ubAPJNnhc88nbqgYBTrpyNF29yBP0YU8cC0VcOU
         5Ycw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of imammedo@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=imammedo@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id p10si132070qtc.1.2019.05.10.08.05.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 May 2019 08:05:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of imammedo@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of imammedo@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=imammedo@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 672577DCC2;
	Fri, 10 May 2019 15:05:19 +0000 (UTC)
Received: from Igors-MacBook-Pro (ovpn-204-97.brq.redhat.com [10.40.204.97])
	by smtp.corp.redhat.com (Postfix) with ESMTP id E907C5ED2A;
	Fri, 10 May 2019 15:05:06 +0000 (UTC)
Date: Fri, 10 May 2019 17:05:01 +0200
From: Igor Mammedov <imammedo@redhat.com>
To: Auger Eric <eric.auger@redhat.com>
Cc: Shameerali Kolothum Thodi <shameerali.kolothum.thodi@huawei.com>, Laszlo
 Ersek <lersek@redhat.com>, "peter.maydell@linaro.org"
 <peter.maydell@linaro.org>, "xuwei (O)" <xuwei5@huawei.com>, Anshuman
 Khandual <anshuman.khandual@arm.com>, Catalin Marinas
 <Catalin.Marinas@arm.com>, "ard.biesheuvel@linaro.org"
 <ard.biesheuvel@linaro.org>, "will.deacon@arm.com" <will.deacon@arm.com>,
 "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, Linuxarm
 <linuxarm@huawei.com>, linux-mm <linux-mm@kvack.org>, "qemu-arm@nongnu.org"
 <qemu-arm@nongnu.org>, Jonathan Cameron <jonathan.cameron@huawei.com>,
 Robin Murphy <robin.murphy@arm.com>, "linux-arm-kernel@lists.infradead.org"
 <linux-arm-kernel@lists.infradead.org>
Subject: Re: [Qemu-devel] [Question] Memory hotplug clarification for Qemu
 ARM/virt
Message-ID: <20190510170501.4f2d006a@Igors-MacBook-Pro>
In-Reply-To: <aacca139-39a7-bdf2-c4dc-75d6a6cc1274@redhat.com>
References: <5FC3163CFD30C246ABAA99954A238FA83F1B6A66@lhreml524-mbs.china.huawei.com>
	<ca5f7231-6924-0720-73a5-766eb13ee331@arm.com>
	<190831a5-297d-addb-ea56-645afb169efb@redhat.com>
	<20190509183520.6dc47f2e@Igors-MacBook-Pro>
	<cd2aa867-5367-b470-0a2b-33897697c23f@redhat.com>
	<5FC3163CFD30C246ABAA99954A238FA83F1DDFE5@lhreml524-mbs.china.huawei.com>
	<499f2bc5-da85-72b2-4f7b-32f2d25d842b@redhat.com>
	<5FC3163CFD30C246ABAA99954A238FA83F1DE1C0@lhreml524-mbs.china.huawei.com>
	<aacca139-39a7-bdf2-c4dc-75d6a6cc1274@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.27]); Fri, 10 May 2019 15:05:19 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 10 May 2019 11:58:38 +0200
Auger Eric <eric.auger@redhat.com> wrote:

> Hi Shameer,
>=20
> On 5/10/19 11:27 AM, Shameerali Kolothum Thodi wrote:
> > Hi Eric,
> >=20
> >> -----Original Message-----
> >> From: Auger Eric [mailto:eric.auger@redhat.com]
> >> Sent: 10 May 2019 10:16
> >> To: Shameerali Kolothum Thodi <shameerali.kolothum.thodi@huawei.com>;
> >> Laszlo Ersek <lersek@redhat.com>; Igor Mammedov
> >> <imammedo@redhat.com>
> >> Cc: peter.maydell@linaro.org; xuwei (O) <xuwei5@huawei.com>; Anshuman
> >> Khandual <anshuman.khandual@arm.com>; Catalin Marinas
> >> <Catalin.Marinas@arm.com>; ard.biesheuvel@linaro.org;
> >> will.deacon@arm.com; qemu-devel@nongnu.org; Linuxarm
> >> <linuxarm@huawei.com>; linux-mm <linux-mm@kvack.org>;
> >> qemu-arm@nongnu.org; Jonathan Cameron
> >> <jonathan.cameron@huawei.com>; Robin Murphy <robin.murphy@arm.com>;
> >> linux-arm-kernel@lists.infradead.org
> >> Subject: Re: [Qemu-devel] [Question] Memory hotplug clarification for =
Qemu
> >> ARM/virt
> >>
> >> Hi Shameer,
> >>
> >> On 5/10/19 10:34 AM, Shameerali Kolothum Thodi wrote:
> >>>
> >>>
> >>>> -----Original Message-----
> >>>> From: Laszlo Ersek [mailto:lersek@redhat.com]
> >>>> Sent: 09 May 2019 22:48
> >>>> To: Igor Mammedov <imammedo@redhat.com>
> >>>> Cc: Robin Murphy <robin.murphy@arm.com>; Shameerali Kolothum Thodi
> >>>> <shameerali.kolothum.thodi@huawei.com>; will.deacon@arm.com; Catalin
> >>>> Marinas <Catalin.Marinas@arm.com>; Anshuman Khandual
> >>>> <anshuman.khandual@arm.com>; linux-arm-kernel@lists.infradead.org;
> >>>> linux-mm <linux-mm@kvack.org>; qemu-devel@nongnu.org;
> >>>> qemu-arm@nongnu.org; eric.auger@redhat.com;
> >> peter.maydell@linaro.org;
> >>>> Linuxarm <linuxarm@huawei.com>; ard.biesheuvel@linaro.org; Jonathan
> >>>> Cameron <jonathan.cameron@huawei.com>; xuwei (O)
> >> <xuwei5@huawei.com>
> >>>> Subject: Re: [Question] Memory hotplug clarification for Qemu ARM/vi=
rt
> >>>>
> >>>> On 05/09/19 18:35, Igor Mammedov wrote:
> >>>>> On Wed, 8 May 2019 22:26:12 +0200
> >>>>> Laszlo Ersek <lersek@redhat.com> wrote:
> >>>>>
> >>>>>> On 05/08/19 14:50, Robin Murphy wrote:
> >>>>>>> Hi Shameer,
> >>>>>>>
> >>>>>>> On 08/05/2019 11:15, Shameerali Kolothum Thodi wrote:
> >>>>>>>> Hi,
> >>>>>>>>
> >>>>>>>> This series here[0] attempts to add support for PCDIMM in QEMU f=
or
> >>>>>>>> ARM/Virt platform and has stumbled upon an issue as it is not cl=
ear(at
> >>>>>>>> least
> >>>>>>>> from Qemu/EDK2 point of view) how in physical world the hotplugg=
able
> >>>>>>>> memory is handled by kernel.
> >>>>>>>>
> >>>>>>>> The proposed implementation in Qemu, builds the SRAT and DSDT pa=
rts
> >>>>>>>> and uses GED device to trigger the hotplug. This works fine.
> >>>>>>>>
> >>>>>>>> But when we added the DT node corresponding to the PCDIMM(cold
> >> plug
> >>>>>>>> scenario), we noticed that Guest kernel see this memory during e=
arly
> >>>> boot
> >>>>>>>> even if we are booting with ACPI. Because of this, hotpluggable
> >> memory
> >>>>>>>> may end up in zone normal and make it non-hot-un-pluggable even =
if
> >>>> Guest
> >>>>>>>> boots with ACPI.
> >>>>>>>>
> >>>>>>>> Further discussions[1] revealed that, EDK2 UEFI has no means to
> >>>>>>>> interpret the
> >>>>>>>> ACPI content from Qemu(this is designed to do so) and uses DT in=
fo to
> >>>>>>>> build the GetMemoryMap(). To solve this, introduced "hotpluggabl=
e"
> >>>>>>>> property
> >>>>>>>> to DT memory node(patches #7 & #8 from [0]) so that UEFI can
> >>>>>>>> differentiate
> >>>>>>>> the nodes and exclude the hotpluggable ones from GetMemoryMap().
> >>>>>>>>
> >>>>>>>> But then Laszlo rightly pointed out that in order to accommodate=
 the
> >>>>>>>> changes
> >>>>>>>> into UEFI we need to know how exactly Linux expects/handles all =
the
> >>>>>>>> hotpluggable memory scenarios. Please find the discussion here[2=
].
> >>>>>>>>
> >>>>>>>> For ease, I am just copying the relevant comment from Laszlo bel=
ow,
> >>>>>>>>
> >>>>>>>> /******
> >>>>>>>> "Given patches #7 and #8, as I understand them, the firmware can=
not
> >>>>>>>> distinguish
> >>>>>>>> =C2=A0 hotpluggable & present, from hotpluggable & absent. The f=
irmware
> >>>> can
> >>>>>>>> only
> >>>>>>>> =C2=A0 skip both hotpluggable cases. That's fine in that the fir=
mware will
> >>>>>>>> hog neither
> >>>>>>>> =C2=A0 type -- but is that OK for the OS as well, for both ACPI =
boot and DT
> >>>>>>>> boot?
> >>>>>>>>
> >>>>>>>> Consider in particular the "hotpluggable & present, ACPI boot" c=
ase.
> >>>>>>>> Assuming
> >>>>>>>> we modify the firmware to skip "hotpluggable" altogether, the UE=
FI
> >>>> memmap
> >>>>>>>> will not include the range despite it being present at boot.
> >>>>>>>> Presumably, ACPI
> >>>>>>>> will refer to the range somehow, however. Will that not confuse =
the
> >> OS?
> >>>>>>>>
> >>>>>>>> When Igor raised this earlier, I suggested that
> >>>>>>>> hotpluggable-and-present should
> >>>>>>>> be added by the firmware, but also allocated immediately, as
> >>>>>>>> EfiBootServicesData
> >>>>>>>> type memory. This will prevent other drivers in the firmware from
> >>>>>>>> allocating AcpiNVS
> >>>>>>>> or Reserved chunks from the same memory range, the UEFI memmap
> >> will
> >>>>>>>> contain
> >>>>>>>> the range as EfiBootServicesData, and then the OS can release th=
at
> >>>>>>>> allocation in
> >>>>>>>> one go early during boot.
> >>>>>>>>
> >>>>>>>> But this really has to be clarified from the Linux kernel's
> >>>>>>>> expectations. Please
> >>>>>>>> formalize all of the following cases:
> >>>>>>>>
> >>>>>>>> OS boot (DT/ACPI)=C2=A0 hotpluggable & ...=C2=A0 GetMemoryMap() =
should
> >> report
> >>>>>>>> as=C2=A0 DT/ACPI should report as
> >>>>>>>> -----------------=C2=A0 ------------------
> >>>>>>>> -------------------------------=C2=A0 ------------------------
> >>>>>>>>
> >>>> DT=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 present=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 ?
> >>>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0 ?
> >>>>>>>>
> >>>> DT=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 absent=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 ?
> >>>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0 ?
> >>>>>>>>
> >>>> ACPI=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0 present=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0 ?
> >>>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0 ?
> >>>>>>>>
> >>>> ACPI=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0 absent=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 ?
> >>>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0 ?
> >>>>>>>>
> >>>>>>>> Again, this table is dictated by Linux."
> >>>>>>>>
> >>>>>>>> ******/
> >>>>>>>>
> >>>>>>>> Could you please take a look at this and let us know what is exp=
ected
> >>>>>>>> here from
> >>>>>>>> a Linux kernel view point.
> >>>>>>>
> >>>>>>> For arm64, so far we've not even been considering DT-based hotplu=
g - as
> >>>>>>> far as I'm aware there would still be a big open question there a=
round
> >>>>>>> notification mechanisms and how to describe them. The DT stuff so=
 far
> >>>>>>> has come from the PowerPC folks, so it's probably worth seeing wh=
at
> >>>>>>> their ideas are.
> >>>>>>>
> >>>>>>> ACPI-wise I've always assumed/hoped that hotplug-related things
> >> should
> >>>>>>> be sufficiently well-specified in UEFI that "do whatever x86/IA-6=
4 do"
> >>>>>>> would be enough for us.
> >>>>>>
> >>>>>> As far as I can see in UEFI v2.8 -- and I had checked the spec bef=
ore
> >>>>>> dumping the table with the many question marks on Shameer --, all =
the
> >>>>>> hot-plug language in the spec refers to USB and PCI hot-plug in the
> >>>>>> preboot environment. There is not a single word about hot-plug at =
OS
> >>>>>> runtime (regarding any device or component type), nor about memory
> >>>>>> hot-plug (at any time).
> >>>>>>
> >>>>>> Looking to x86 appears valid -- so what does the Linux kernel expe=
ct on
> >>>>>> that architecture, in the "ACPI" rows of the table?
> >>>>>
> >>>>> I could only answer from QEMU x86 perspective.
> >>>>> QEMU for x86 guests currently doesn't add hot-pluggable RAM into E8=
20
> >>>>> because of different linux guests tend to cannibalize it, making it=
 non
> >>>>> unpluggable. The last culprit I recall was KASLR.
> >>>>>
> >>>>> So I'd refrain from reporting hotpluggable RAM in GetMemoryMap() if
> >>>>> it's possible (it's probably hack (spec deosn't say anything about =
it)
> >>>>> but it mostly works for Linux (plug/unplug) and Windows guest also
> >>>>> fine with plug part (no unplug there)).
> >>>>
> >>>> I can accept this as a perfectly valid design. Which would mean, QEMU
> >> should
> >>>> mark each hotpluggable RAM range in the DTB for the firmware with the
> >>>> special new property, regardless of its initial ("cold") plugged-nes=
s, and then
> >>>> the firmware will not expose the range in the GCD memory space map, =
and
> >>>> consequently in the UEFI memmap either.
> >>>>
> >>>> IOW, our table is, thus far:
> >>>>
> >>>> OS boot (DT/ACPI)  hotpluggable & ...  GetMemoryMap() should report =
as
> >>>> DT/ACPI should report as
> >>>> -----------------  ------------------  -----------------------------=
--  ------------------------
> >>>> DT                 present
> >>>> ABSENT                           ?
> >>>> DT                 absent
> >>>> ABSENT                           ?
> >>>> ACPI               present             ABSENT
> >>>> PRESENT
> >>>> ACPI               absent              ABSENT
> >>>> ABSENT
> >>>> In the firmware, I only need to care about the GetMemoryMap() column=
, so
> >> I
> >>>> can work with this.
> >>>
> >>> Thank you all for the inputs.
> >>>
> >>> I assume we will still report the DT cold plug case to kernel(hotplug=
gable &
> >> present).
> >>> so the table will be something like this,
> >>>
> >>> OS boot (DT/ACPI)  hotpluggable & ...  GetMemoryMap() should report as
> >> DT/ACPI should report as
> >>> -----------------  ------------------  ------------------------------=
-  ------------------------
> >>> DT                 present             ABSENT
> >> PRESENT
> >>> DT                 absent              ABSENT
> >> ABSENT
> >> With DT boot, how does the OS get to know if thehotpluggable memory is
> >> present or absent? Or maybe I misunderstand the last column.
> >=20
> > It doesn't. For hotpluggable & present case it will be just like normal=
 memory and
> > for absent case no memory node(hotpluaggble) is populated in DT. Is thi=
s acceptable?
> OK I get it now. Yes it makes sense.
> >=20
> > On another note, if there are no strong case for DT cold plug for PCDIM=
M we can drop
> > it altogether which will make everything much simpler and no change req=
uired for
> > UEFI as well.
> I don't think we have strong requirements for PCDIMM in DT mode (initial
> RAM can be used). As long as we can detect an attempt to use PCDIMM in
> DT only mode and reject it (-no-acpi or !firmware_loaded ?), personally
> I don't have any objection.
It seems we are in agreement here, let's skip DT part for now.
We can add it later if there is demand for it (I don't see any issues wrt m=
igration here).

>=20
> Thanks
>=20
> Eric
> >=20
> > Thanks,
> > Shameer
> >=20
> >=20
> >> Thanks
> >>
> >> Eric
> >>> ACPI               present             ABSENT
> >> PRESENT
> >>> ACPI               absent              ABSENT
> >> ABSENT
> >>>
> >>>
> >>>  Can someone please file a feature request at
> >>>> <https://bugzilla.tianocore.org/>, for the ArmVirtPkg Package, with =
these
> >>>> detais?
> >>>
> >>> Ok. I will do that.
> >>>
> >>> Thanks,
> >>> Shameer
> >>>
> >>>> Thanks
> >>>> Laszlo
> >>>>
> >>>>>
> >>>>> As for physical systems, there are out there ones that do report
> >>>>> hotpluggable RAM in GetMemoryMap().
> >>>>>
> >>>>>> Shameer: if you (Huawei) are represented on the USWG / ASWG, I
> >> suggest
> >>>>>> re-raising the question on those lists too; at least the "ACPI" ro=
ws of
> >>>>>> the table.
> >>>>>>
> >>>>>> Thanks!
> >>>>>> Laszlo
> >>>>>>
> >>>>>>>
> >>>>>>> Robin.
> >>>>>>>
> >>>>>>>> (Hi Laszlo/Igor/Eric, please feel free to add/change if I have m=
issed
> >>>>>>>> any valid
> >>>>>>>> points above).
> >>>>>>>>
> >>>>>>>> Thanks,
> >>>>>>>> Shameer
> >>>>>>>> [0] https://patchwork.kernel.org/cover/10890919/
> >>>>>>>> [1] https://patchwork.kernel.org/patch/10863299/
> >>>>>>>> [2] https://patchwork.kernel.org/patch/10890937/
> >>>>>>>>
> >>>>>>>>
> >>>>>>
> >>>>>
> >>>

