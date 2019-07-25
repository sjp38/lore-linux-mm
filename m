Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7D11AC41514
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 09:23:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 45FF322C7D
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 09:23:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 45FF322C7D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E5C1B6B0297; Thu, 25 Jul 2019 05:22:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E33B48E0057; Thu, 25 Jul 2019 05:22:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D495D6B029A; Thu, 25 Jul 2019 05:22:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id AE2B36B0297
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 05:22:59 -0400 (EDT)
Received: by mail-ot1-f69.google.com with SMTP id a21so27101766otk.17
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 02:22:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :references:in-reply-to:from:date:message-id:subject:to:cc;
        bh=d6bXcLy59IZQ/jzA1KAA80JAzsTaXl85YCv6d26dui4=;
        b=RsMglgtx5UpaQqkFqZM0vfd3Javyvq5+8MtdIo+xFockN7u8Otg9OYu7V9BFHqsEIq
         4eOmuYMe0GkHxDhjVr57peq0g7m+fxXugy6lg/pjwEuM0prLb/RsDZhBZJzB2itksa6T
         eYV3WB3NFfJLrslmiWmq3NJkV5GKchrvVhmBo46qN7SklBW3DX8fpnFu240XU8BaP261
         wZahSMC+yq3FGs5V9RRURNDMcNSb2YlA2DUdHltj/b1mSqIwMlGjMpoiOX2m7+Tigj8V
         jof47ZXLZxPBvuoIOSWBshEPMbZP1sv9Z9HmuT22eNBMM/Hqhulj2zmDdu/yyDqRLXr8
         bJiA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rjwysocki@gmail.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAUuzwYWPDzmpeyVY5gFCO2OA+6LKsrV2IkbhVGxJectkl0D16nd
	ypYouwacLUXaQeTM+WXR6UCpS2bAYsa0nrgOD6VT9Bi7AaBEnRjbfzPgi0zDgjHc6iCCdmmZXZ7
	rchTnmtORHwTe+/YPG8+h+w0Lpb+gem8sw1DJq9Pik7Z2uTjZ715Rohltxuhw1IA=
X-Received: by 2002:aca:cd4f:: with SMTP id d76mr44280993oig.147.1564046579291;
        Thu, 25 Jul 2019 02:22:59 -0700 (PDT)
X-Received: by 2002:aca:cd4f:: with SMTP id d76mr44280969oig.147.1564046578640;
        Thu, 25 Jul 2019 02:22:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564046578; cv=none;
        d=google.com; s=arc-20160816;
        b=bvmrnRMhVP5AHMqamxI+GnfhB2d3o0zIeVoGGBn1s1uyvvdRrTrbe2/tygJ57XcXnY
         +2xTLoKfMyMeWfbde+7EeQyiBQ4e5Dx+ZOZcF3t3nkxt5ZEjpojJ5YjSE6K5puSTdqrk
         ldv65MceVoBgdgdmqagrEPeBt6YHhq+YXcKatdV+vXii7O/5knqM9rHprzYwmM7jeY5C
         336joKbcnRLaHClpuSznawb5P5PC+5rBkLKADQFQS/7jYsaGcR+O8vsFDaFz6nt4gDnX
         8jp7NNWwIz6QDGj7ic65rTuRZZ085IHXf7YYf7tCFQlBqbT8xE5N1SUDnAKnKmZpJyzZ
         ABVQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version;
        bh=d6bXcLy59IZQ/jzA1KAA80JAzsTaXl85YCv6d26dui4=;
        b=io+4ATKoUju7+4ptY8T5q21K2jg1LFOeqclwICFv/DkW9ybEi66/sWgj/IL6CfQV4i
         g2fxUHDEMRjvZyha/gsU9nHG6rcw1gCMD3x7Kgnk3IwJ17iZXCjC/HriUT7rgtcMGGrM
         rINZlwB9ZqgED609W6pUD8fD0v00YcGeG4vMmIqRngCmsGaX5aYT5a1ypkZzrBEFRhrN
         h1457rwhPvGKC32RlK7TASvf0qpAJ4nQs63c2CllRX4N74zekppdPmvbbCpWa2DM2YRt
         DeVCRaXvfT0Nwp6gbL/HDcf0VeQJdnpwRFGZL8eLIXfl9ENMQ1yJAjO8yc1BSBdkos1s
         Ig0g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rjwysocki@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m8sor25684074otm.167.2019.07.25.02.22.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 25 Jul 2019 02:22:58 -0700 (PDT)
Received-SPF: pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rjwysocki@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Google-Smtp-Source: APXvYqxJ49+1aZ6N4TDMyBMfQsD/Uphq9/3dCsGS122VqG+v2Ww7f6i5dT2dazWN0C3ylFEI+mrm0iTK0F636Zu0+Q8=
X-Received: by 2002:a05:6830:1516:: with SMTP id k22mr59724305otp.189.1564046578263;
 Thu, 25 Jul 2019 02:22:58 -0700 (PDT)
MIME-Version: 1.0
References: <20190724143017.12841-1-david@redhat.com> <20190725091625.GA15848@linux>
In-Reply-To: <20190725091625.GA15848@linux>
From: "Rafael J. Wysocki" <rafael@kernel.org>
Date: Thu, 25 Jul 2019 11:22:46 +0200
Message-ID: <CAJZ5v0iBntT1c7gKkXG-RJpabZne2n-Afq40GKeA6-tUViVZuQ@mail.gmail.com>
Subject: Re: [PATCH v1] ACPI / scan: Acquire device_hotplug_lock in acpi_scan_init()
To: Oscar Salvador <osalvador@suse.de>
Cc: David Hildenbrand <david@redhat.com>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, 
	Linux Memory Management List <linux-mm@kvack.org>, ACPI Devel Maling List <linux-acpi@vger.kernel.org>, 
	"Rafael J. Wysocki" <rjw@rjwysocki.net>, Andrew Morton <akpm@linux-foundation.org>, 
	Michal Hocko <mhocko@suse.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jul 25, 2019 at 11:18 AM Oscar Salvador <osalvador@suse.de> wrote:
>
> On Wed, Jul 24, 2019 at 04:30:17PM +0200, David Hildenbrand wrote:
> > We end up calling __add_memory() without the device hotplug lock held.
> > (I used a local patch to assert in __add_memory() that the
> >  device_hotplug_lock is held - I might upstream that as well soon)
> >
> > [   26.771684]        create_memory_block_devices+0xa4/0x140
> > [   26.772952]        add_memory_resource+0xde/0x200
> > [   26.773987]        __add_memory+0x6e/0xa0
> > [   26.775161]        acpi_memory_device_add+0x149/0x2b0
> > [   26.776263]        acpi_bus_attach+0xf1/0x1f0
> > [   26.777247]        acpi_bus_attach+0x66/0x1f0
> > [   26.778268]        acpi_bus_attach+0x66/0x1f0
> > [   26.779073]        acpi_bus_attach+0x66/0x1f0
> > [   26.780143]        acpi_bus_scan+0x3e/0x90
> > [   26.780844]        acpi_scan_init+0x109/0x257
> > [   26.781638]        acpi_init+0x2ab/0x30d
> > [   26.782248]        do_one_initcall+0x58/0x2cf
> > [   26.783181]        kernel_init_freeable+0x1bd/0x247
> > [   26.784345]        kernel_init+0x5/0xf1
> > [   26.785314]        ret_from_fork+0x3a/0x50
> >
> > So perform the locking just like in acpi_device_hotplug().
> >
> > Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>
> > Cc: Len Brown <lenb@kernel.org
> > Cc: Andrew Morton <akpm@linux-foundation.org>
> > Cc: Oscar Salvador <osalvador@suse.de>
> > Cc: Michal Hocko <mhocko@suse.com>
> > Signed-off-by: David Hildenbrand <david@redhat.com>
>
> Given that that call comes from a __init function, so while booting, I wonder
> how bad it is.

Yes, it probably does not matter.

> Anyway, let us be consistent:

Right.

