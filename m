Return-Path: <SRS0=t1VS=SW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1746BC282DD
	for <linux-mm@archiver.kernel.org>; Sat, 20 Apr 2019 16:56:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B563C20821
	for <linux-mm@archiver.kernel.org>; Sat, 20 Apr 2019 16:56:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=soleen.com header.i=@soleen.com header.b="KyyYJ4rz"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B563C20821
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=soleen.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4FC076B0003; Sat, 20 Apr 2019 12:56:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4A9476B0006; Sat, 20 Apr 2019 12:56:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 399D36B000D; Sat, 20 Apr 2019 12:56:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id DAA0D6B0003
	for <linux-mm@kvack.org>; Sat, 20 Apr 2019 12:56:21 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id f7so4226902edi.3
        for <linux-mm@kvack.org>; Sat, 20 Apr 2019 09:56:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=Y7jvqePrB1R8RcQSpXk/WHrFOQWIqpXtojXeqSYofx8=;
        b=WXpFH50VOVIIoU1JgL7/Tj6Rm/AtESz4ZpA+6Pxhik81YnGkOLPmxn4EFu1cu+etVE
         sbuwrZJjsHO8O6hCVzbfhb135I1hmdKcdXzcgsRsH7AxRZVA7gYXcg0M/izt1pJ49H9z
         f6Y36JW6iSw+sLFQx7OWtLLqGo9N1N5/T+TpGDD97YbNBzGwUrmgF5v7JplhNDvYn5Oz
         SnxLyaciHFQI3M5WkwxkUBtKrDIpI6L9yGB2VlAC0ULJBkIiyIzEwbfuwqL6vLllWdz1
         khKHlDdfeexzpXamIeS76SFeTbKQyDnWgY/v5qen+XOabQYGXgO/8/wOb/5Ew/AE8ctI
         KBxA==
X-Gm-Message-State: APjAAAWvSRa/TYCC6F4pDO3R5ILSmvlsJ/h4IqnZCLIsAYagstHT4Set
	PZLQkbBIUCGCY1X9Rtj52RzBWDGRhtIacwZwAybVDegiZYKzTwh/ubj62k0EC2mcFQuOHsvDWSh
	RfrIez3mZhawH0n7CDp2PF1kKrsc2dzCR1snjLn7vDaLGXRowKfT5W6acqXkG6xTQZA==
X-Received: by 2002:a50:ea87:: with SMTP id d7mr6449379edo.70.1555779381441;
        Sat, 20 Apr 2019 09:56:21 -0700 (PDT)
X-Received: by 2002:a50:ea87:: with SMTP id d7mr6449363edo.70.1555779380800;
        Sat, 20 Apr 2019 09:56:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555779380; cv=none;
        d=google.com; s=arc-20160816;
        b=s+MV1LibqSADyAGEXVesSDgdBP/hwdHoHJU/WfdbUsZE8Wzdbv2j502AC/zfyAmBbK
         cPLjX6IYbX0LrT3MZDvW4McYa9Q9lgN2m88QLAYCyzNEIgjWPpyJ34YvMNfcGCVgRksZ
         O3iPygkXsV8WUB5VYNY4FBTlb0slfoAuFie+oAVQ2vcHj/aN1Ho8535iubiTy33XRhwe
         J2yKNGuhBereGNzyULm4IB8N5Vjg7t9NxXYnEG031U5u8/xCKhVqeegB0HLJnNly0814
         up6CqQCjtp6IZiQyPEy69cMTirP32xiYZFguuGLKbnzEAAaeQvkfnVTRl105sNV7WP/m
         8S3A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=Y7jvqePrB1R8RcQSpXk/WHrFOQWIqpXtojXeqSYofx8=;
        b=LcJTNnVfP60XOThYW+PmwqvKAjGs+0DVN/FCNzVlCSEtAtAQvQGcC+byO4CwsQ5HNm
         ghK4GzUskQdOnMtlPEArtEl1HvKS5gVuudV4Qun6wc5HI755ULIOyf4gBUVmyqORyH1x
         E1qmSHa7h/lSzzFU/jPBn3Ff/VEztfSzypDO/5U5aZTCEHCMS3tcU//JPese9zxprJBC
         P1ebVuBE6sfK5IABKfPLRiA1mOk4aRWfsIZvM22TziqvZwp/IlwZESO/iObUUMdA6vny
         EijwvzGrkcfs107s3EEVfrO0nJ2caIXuk4kKSkEh4+bkcABsBgWadpbI46Hxu/6+pLw3
         VsXg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@soleen.com header.s=google header.b=KyyYJ4rz;
       spf=pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pasha.tatashin@soleen.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f20sor1701014ejq.15.2019.04.20.09.56.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 20 Apr 2019 09:56:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@soleen.com header.s=google header.b=KyyYJ4rz;
       spf=pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pasha.tatashin@soleen.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=soleen.com; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=Y7jvqePrB1R8RcQSpXk/WHrFOQWIqpXtojXeqSYofx8=;
        b=KyyYJ4rzKUMCy/3XSYeWyMDH+nta39krwYu+3f+Hx1K9QPRRrKYCdKrQ+E0NCvO6rO
         rAi+v2jd7evE0ZQMiGxjRsOZttiw0ZbirQaocZjhRbr6VcXx4o+QwK5orJNSYfZkdGxR
         L7Bwp90laz5z3nWfswVp2FFMmOt1qFzHt0ODD/TO4KA1RuUKzVsKG/mh2NJY60nYualI
         37e4xCHkuTPsnfIRsgNichCrk3TYoTcHyUOgKFgaRG8STOBzQn2a8oJnvgQszP0F8ACl
         LEDkQXxJqBoBHkGKDErHLYsc4WoX3PGi+SbRK3idmSqadptOT1TzpCJU3F1PVRaj2Y8H
         MPJg==
X-Google-Smtp-Source: APXvYqz+01cR3hHp5UbAXs/R5xp7syVX65tIoYJPYblGitJV0pOtK59VuzQYfKdPXF05WneN21sp+JUQWokjtBb2zB4=
X-Received: by 2002:a17:906:b291:: with SMTP id q17mr5107900ejz.56.1555779380463;
 Sat, 20 Apr 2019 09:56:20 -0700 (PDT)
MIME-Version: 1.0
References: <20190420153148.21548-1-pasha.tatashin@soleen.com> <CAPcyv4h73gUwntDYx012qcyMYCmzZDU3HOvKcW5DRkO-GoTc+w@mail.gmail.com>
In-Reply-To: <CAPcyv4h73gUwntDYx012qcyMYCmzZDU3HOvKcW5DRkO-GoTc+w@mail.gmail.com>
From: Pavel Tatashin <pasha.tatashin@soleen.com>
Date: Sat, 20 Apr 2019 12:56:09 -0400
Message-ID: <CA+CK2bBpyiUKeiT5tPtT9Dt73DmKX9pOFLU2iZy=Xpubt1AhAA@mail.gmail.com>
Subject: Re: [v1 0/2] "Hotremove" persistent memory
To: Dan Williams <dan.j.williams@intel.com>
Cc: James Morris <jmorris@namei.org>, Sasha Levin <sashal@kernel.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, 
	linux-nvdimm <linux-nvdimm@lists.01.org>, Andrew Morton <akpm@linux-foundation.org>, 
	Michal Hocko <mhocko@suse.com>, Dave Hansen <dave.hansen@linux.intel.com>, 
	Keith Busch <keith.busch@intel.com>, Vishal L Verma <vishal.l.verma@intel.com>, 
	Dave Jiang <dave.jiang@intel.com>, Ross Zwisler <zwisler@kernel.org>, 
	Tom Lendacky <thomas.lendacky@amd.com>, "Huang, Ying" <ying.huang@intel.com>, 
	Fengguang Wu <fengguang.wu@intel.com>, Borislav Petkov <bp@suse.de>, Bjorn Helgaas <bhelgaas@google.com>, 
	Yaowei Bai <baiyaowei@cmss.chinamobile.com>, Takashi Iwai <tiwai@suse.de>, 
	=?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

> Makes sense, but I have some questions about the details.
>
> >
> > Copy the state, and hotadd the persistent memory so machine still has all
> > 8G for runtime. Before reboot, hotremove device-dax 2G, copy the memory
> > that is needed to be preserved to pmem0 device, and reboot.
> >
> > The series of operations look like this:
> >
> >         1. After boot restore /dev/pmem0 to boot

s/boot/to a ramdisk from which is is picked by apps/

> >         2. Convert raw pmem0 to devdax
> >         ndctl create-namespace --mode devdax --map mem -e namespace0.0 -f
> >         3. Hotadd to System RAM
> >         echo dax0.0 > /sys/bus/dax/drivers/device_dax/unbind
> >         echo dax0.0 > /sys/bus/dax/drivers/kmem/new_id
> >         4. Before reboot hotremove device-dax memory from System RAM
> >         echo dax0.0 > /sys/bus/dax/drivers/kmem/unbind
> >         5. Create raw pmem0 device
> >         ndctl create-namespace --mode raw  -e namespace0.0 -f
> >         6. Copy the state to this device
>
> What is the source of this copy? The state that was in the hot-added
> memory? Isn't it "already there" since you effectively renamed dax0.0
> to pmem0?

Before hotremove, applications create a file in a ramdisk that is 2G
in size. After that applications, exist. We copy this file from
ramdisk to /dev/pmem0  (RAM to RAM copy) to be able to quickly restore
after reboot. After reboot, applications take that file from ramdisk,
and ramdisk is freed.

>
> >         7. Do kexec reboot, or reboot through firmware, is firmware does not
> >         zero memory in pmem region.
s/is/if/
>
> Wouldn't the dax0.0 contents be preserved regardless? How does the
> guest recover the pre-initialized state / how does the kernel know to
> give out the same pages to the application as the previous boot?

On these machines we do not have real persistent memory, only regular
volatile RAM. So, kernel has to either be booted via memap arguments
that specify persistent range, or via special pmem device node in DTB.

