Return-Path: <SRS0=007R=T7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 68B01C28CC2
	for <linux-mm@archiver.kernel.org>; Fri, 31 May 2019 14:52:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2DFBD26AEC
	for <linux-mm@archiver.kernel.org>; Fri, 31 May 2019 14:52:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="j/GsBEIA"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2DFBD26AEC
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BA7B26B026F; Fri, 31 May 2019 10:52:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B31146B0278; Fri, 31 May 2019 10:52:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9F9626B027A; Fri, 31 May 2019 10:52:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	by kanga.kvack.org (Postfix) with ESMTP id 759486B026F
	for <linux-mm@kvack.org>; Fri, 31 May 2019 10:52:37 -0400 (EDT)
Received: by mail-oi1-f197.google.com with SMTP id p83so3561396oih.17
        for <linux-mm@kvack.org>; Fri, 31 May 2019 07:52:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=dazNgH0WSo6RBdntgfM2itxBiI4ct6zLibwem/T/a7w=;
        b=MoF54zMYuW6ZNmitCO219Px809t+mcAGqOE0vCeZeB39ZoSBv4bz6XpHUxf8oKkrpO
         +EiYYGvi51zoBxwFw8to9tdn5oENq7hoXaPW/EdP0hrHtFDScvY+dPc7PHF73V9wWwmf
         I+ZI7YshGrexngiHDxffNRWpfrneqHBP7Y3R6ErpIzUlbm0yiQpeK8mIznb9WOznp3d0
         l80eenofu9X1AhGELYafhw7aV0UigNQ0hpMmuKsfYjWRMNQP8yKaHUEvp1kn4WpWIwA6
         pmLQP56dL+aCR5McVMVdex7OV8Lhn4dg/MYIF2FbN+MKFVbCoiLMBVQ5hZ2HT8Jfy9Q7
         uSfg==
X-Gm-Message-State: APjAAAUYsYU9RwEz0Qm0573yJpGK4/Gc4NRiunTb5sRrUzUjDCZ9VYPV
	XqZyW4Ts1DEuU2KI6p4pyuyaxC3ruagLTS2EP2okUhtTC1QXuYNerpE/2kapgdbu2VNWCq/XwiP
	GOnsDGlXl272Zqlo8KyHiGq08IJ3cvnbdYCsXpE+26UlCWOfIJZBeZ5vNuU4mDKkC8A==
X-Received: by 2002:a05:6808:cc:: with SMTP id t12mr6153530oic.165.1559314357088;
        Fri, 31 May 2019 07:52:37 -0700 (PDT)
X-Received: by 2002:a05:6808:cc:: with SMTP id t12mr6153512oic.165.1559314356504;
        Fri, 31 May 2019 07:52:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559314356; cv=none;
        d=google.com; s=arc-20160816;
        b=ndCBPH8BLEOOP7dYoB0OlNCRXpc7R5INbWJGnSCDMuz82a45r9Ee9YEwXTHQJGmqmf
         7eRBw2MEtfVLCPfWXuW8d5r8KRTuANtJSi2u6l6E0Pjmvad2wBlV/Xa2r3qC2me0iXPe
         hXWRePlz6xN+i0IaurXlip4cX7sMO44Y5sOzZZI4f7Bb61/zEWmX3P8bdWiIeizwq5Jk
         Do/ZqkEdtNEx9UyEdGUnafGrb6qynHaiig/j3vZ5og8x391qe4hQrSTQ2jezuT8NGMCt
         17x3j2vaMcIHvVGhSdVaIu6XH7EmfRD9pWopZKZi+ijLGGQcktsL1yc84gKRpE7fJ0uh
         wAlw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=dazNgH0WSo6RBdntgfM2itxBiI4ct6zLibwem/T/a7w=;
        b=rgQhdQjUry2Kfxbom2+7QRi/7RNk8Q4gv3w/xU3HJFDGw3WbvTEn+xXMEAsEKHvujF
         iKdQUGQg5C1TgV5NW2ZaAi9dXy43irjZrkPuPfgbYZ9OBe888l97lJtuy7yQ/YqHdxRX
         KN21xvvEfQjuEPnONt684NbZytlo7X9WintAG3B6lEtLtO5oTJwTCSPNGipIDrlhAD33
         Dc6a77Emok77BGZvlQrdzk1heHXUWz9eqEBuqdVXpXOvk9eaGiie8kZSwMc1AmHWnt4K
         hmmI3qMPOxjAYmoGvDHel6ho/bUabh2cNo7b7MeWFj0JQuyr1h/1zledYMs9UsOIFen8
         hFlw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b="j/GsBEIA";
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m9sor3163165otq.7.2019.05.31.07.52.36
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 31 May 2019 07:52:36 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b="j/GsBEIA";
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=dazNgH0WSo6RBdntgfM2itxBiI4ct6zLibwem/T/a7w=;
        b=j/GsBEIAjVbZy5Y3mimHxH4kZFIlLlKkT8Acinmv2sLTumtJSAz4+K45i94HMcU8B5
         5vuoBjVllo8eLWfIEEGmSHN3y18C2+WtOf2ld9xfh/eBfNzfI08ywejx6/WFhh2Qh1Js
         U/xC31+TIvuIg3zpSPwdusI6fAgBAbuf9ZVsZWxcMq9qesaxUCnyu+Jm/j/acoKaQrVk
         /xZ6KTMGmaqDluJACKDkBZki6qenzP6ucLDP6nqi5PMISHPe9me9sBfBu16SCQ9MmPmY
         x6x0pxCLwDJjV9HwPASaVKILGYScIoM8oWLKnlfoOZ9C4wOlTg6towcaz/+2kExeQ+Ur
         a5bQ==
X-Google-Smtp-Source: APXvYqz4eQwsdM8n+GXsG5v0XO/vAmXg8NEkFxvIGNZys/6jEKVlKq5wCfwFwo8AbFTYskZ23wp82lAK4anye2kHMfM=
X-Received: by 2002:a05:6830:1417:: with SMTP id v23mr1948581otp.71.1559314356156;
 Fri, 31 May 2019 07:52:36 -0700 (PDT)
MIME-Version: 1.0
References: <155925716254.3775979.16716824941364738117.stgit@dwillia2-desk3.amr.corp.intel.com>
 <155925716783.3775979.13301455166290564145.stgit@dwillia2-desk3.amr.corp.intel.com>
 <4965161.Uu1Nigf0I0@kreacher>
In-Reply-To: <4965161.Uu1Nigf0I0@kreacher>
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 31 May 2019 07:52:24 -0700
Message-ID: <CAPcyv4ib1twvDBz6W=JU18JyvtYmyHeAU4iOruRGHf_cY+3Yvg@mail.gmail.com>
Subject: Re: [PATCH v2 1/8] acpi: Drop drivers/acpi/hmat/ directory
To: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Cc: linux-efi@vger.kernel.org, Len Brown <lenb@kernel.org>, 
	Keith Busch <keith.busch@intel.com>, Vishal L Verma <vishal.l.verma@intel.com>, 
	Ard Biesheuvel <ard.biesheuvel@linaro.org>, Linux MM <linux-mm@kvack.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, X86 ML <x86@kernel.org>, 
	linux-nvdimm <linux-nvdimm@lists.01.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, May 31, 2019 at 1:24 AM Rafael J. Wysocki <rjw@rjwysocki.net> wrote:
>
> On Friday, May 31, 2019 12:59:27 AM CEST Dan Williams wrote:
> > As a single source file object there is no need for the hmat enabling to
> > have its own directory.
>
> Well, I asked Keith to add that directory as the code in hmat.c is more related to mm than to
> the rest of the ACPI subsystem.

...but hmat/hmat.c does not say anything about mm?

> Is there any problem with retaining it?

It feels redundant for no benefit to type hmat/hmat.c. How about create:

    drivers/acpi/numa/ or drivers/acpi/mm/

...and move numa.c and hmat.c there if you want to separate mm
concerns from the rest of drivers/acpi/?

