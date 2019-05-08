Return-Path: <SRS0=OmxZ=TI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 24ED3C04A6B
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 20:08:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B8ABA21734
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 20:08:36 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B8ABA21734
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2A1286B0003; Wed,  8 May 2019 16:08:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 252936B0005; Wed,  8 May 2019 16:08:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 13FB76B0007; Wed,  8 May 2019 16:08:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id E6CB56B0003
	for <linux-mm@kvack.org>; Wed,  8 May 2019 16:08:35 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id k6so23062542qkf.13
        for <linux-mm@kvack.org>; Wed, 08 May 2019 13:08:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=65RFg5uMqxh0s8mQ24gFPE6CGJbl4k3/PrkDJ2703YQ=;
        b=k+1Lula8LQzlxs04Ta6ixlQAcNw+MwComhek+p2cTc0vRbRlwwQ7xXtKogumZmwOMB
         nlDBesjsuk3XtLig+haQFDUziVfVSxtjHKmdc2/c3hvKjinM8n4+xasEWVJDhqmnGYSy
         Pu/XkYraESmtMA9LogVlDC/SA1VUnApP5lclLYBQ3eTroAV0l5jzuih5VluIdjqXaPUw
         iW0HIDb1u/Pij1tXgOki1irjxWMYXnf33qYGrNvs4+Alf7/p+320iY2ByZmP40/AD/rg
         BqUVsnC0BM1+wd9y4rIGKUxOhj2nrG55BKuVZ4nwlQw56Uh3X2y+vDB2WNphrFsernMz
         5TPw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of lersek@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=lersek@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAU2IjE3fOBLHtgohsf0gTJ5NRoEheNMAAtGUp2qLaHgORpgBNZI
	DIbsIsaf1WuCxVO8sgO8qrXGQ7Ha4uCc6Es4xM7mKsE2TksEK82ErTp6aQCPbRts+z9GAHCpUTL
	Y0ufKy3tnUzqEuki9+6mmkjg6e8lWguQ2wZOmu8YL2rWdW+IqXjTyZ2Kuj+g9cVZhzQ==
X-Received: by 2002:ac8:38e1:: with SMTP id g30mr4190608qtc.108.1557346115654;
        Wed, 08 May 2019 13:08:35 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzc0KQPugJ40A/mqqdROJxL7I1njMm2QZisD+lpXoKq+imxbSoZ7PzOwxzt1V8zF008X8kO
X-Received: by 2002:ac8:38e1:: with SMTP id g30mr4190522qtc.108.1557346114444;
        Wed, 08 May 2019 13:08:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557346114; cv=none;
        d=google.com; s=arc-20160816;
        b=wpsGOwBvpg3qUxwS0klBROqCQc0KDM8HPWBqjtsYynkBmCaKvzN+7az2fKS4Sc/CAk
         6iIEEE3VP2YLDMWPmUmjQYqyg/pASYhQij0Z3jx7rdg8IYNHuuZAltCSRMeoXY9z9/D/
         omQguNW8QBh4Iaq6nN3qyIHjD1obdm3HRYXCCLtBNfMgvCwKfpk4CO0Qp41aZjeK467y
         349KRA97hpMjjw7xyDFburPsGQZAJ2svbXxNp4Sad0Q1+Udg0ySLMwa9WMnglmD7PquJ
         VgVGE4dE8Z4utOFvC70v0FpXbeo7bsdEyIv33mv6QZ4Im1f8+5Wy4jJnVqWT1uYGEnkH
         McBg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=65RFg5uMqxh0s8mQ24gFPE6CGJbl4k3/PrkDJ2703YQ=;
        b=mZKqbmQqgxjpVQl37iwupEk6xUwkqdSoXizjix+wRnCUlgNI47Aj+bg4xQ86yBvrUP
         DVr8EvH5i28kbbQLO8bTK/SAbOPsITZnO+cHB2cw9wjT55w8VvTz9KK5JWB7rEQLYkof
         eCspXEoZuDbzu0c/kBDxQoIYgANLxiX02SILuBWoF8orqYLIqCObWSvOgdlUyf4Ht6uI
         JfZhehTgyXJFdfjS2jBLJg0zFwJ6/ZyldFGP69v8hbw4+k1xM3udwC/y9voBNJAf0hNM
         jJwpgbuPgZQghS1h3Raqvs2za/sdommaV20sv0Zs+qxBFBah740sbTDDIPwXKQ8c3q1o
         yiKQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of lersek@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=lersek@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id z9si23012qvs.166.2019.05.08.13.08.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 May 2019 13:08:34 -0700 (PDT)
Received-SPF: pass (google.com: domain of lersek@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of lersek@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=lersek@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 53AA789C40;
	Wed,  8 May 2019 20:08:33 +0000 (UTC)
Received: from lacos-laptop-7.usersys.redhat.com (ovpn-120-255.rdu2.redhat.com [10.10.120.255])
	by smtp.corp.redhat.com (Postfix) with ESMTP id D04335D9D1;
	Wed,  8 May 2019 20:08:24 +0000 (UTC)
Subject: Re: [Question] Memory hotplug clarification for Qemu ARM/virt
To: Shameerali Kolothum Thodi <shameerali.kolothum.thodi@huawei.com>,
 "robin.murphy@arm.com" <robin.murphy@arm.com>,
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
From: Laszlo Ersek <lersek@redhat.com>
Message-ID: <d379bc06-b4b5-833b-aaf1-eec0547c30af@redhat.com>
Date: Wed, 8 May 2019 22:08:23 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <5FC3163CFD30C246ABAA99954A238FA83F1B6A66@lhreml524-mbs.china.huawei.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.27]); Wed, 08 May 2019 20:08:33 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 05/08/19 12:15, Shameerali Kolothum Thodi wrote:
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
>  hotpluggable & present, from hotpluggable & absent. The firmware can only
>  skip both hotpluggable cases. That's fine in that the firmware will hog neither
>  type -- but is that OK for the OS as well, for both ACPI boot and DT boot?
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
> 
> (Hi Laszlo/Igor/Eric, please feel free to add/change if I have missed any valid
> points above).

I'm happy with your summary, thank you!
Laszlo

> 
> Thanks,
> Shameer
> [0] https://patchwork.kernel.org/cover/10890919/
> [1] https://patchwork.kernel.org/patch/10863299/
> [2] https://patchwork.kernel.org/patch/10890937/
> 
> 

