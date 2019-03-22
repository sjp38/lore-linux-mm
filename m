Return-Path: <SRS0=SIh7=RZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BE426C4360F
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 13:37:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 86EA720693
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 13:37:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 86EA720693
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-m68k.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 208796B000D; Fri, 22 Mar 2019 09:37:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1B9846B000E; Fri, 22 Mar 2019 09:37:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0A9466B0010; Fri, 22 Mar 2019 09:37:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vs1-f72.google.com (mail-vs1-f72.google.com [209.85.217.72])
	by kanga.kvack.org (Postfix) with ESMTP id D51C36B000D
	for <linux-mm@kvack.org>; Fri, 22 Mar 2019 09:37:31 -0400 (EDT)
Received: by mail-vs1-f72.google.com with SMTP id 2so826595vsf.15
        for <linux-mm@kvack.org>; Fri, 22 Mar 2019 06:37:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :references:in-reply-to:from:date:message-id:subject:to:cc;
        bh=XzQ9NHyI634XKb+UUobZCMcWq8m8E9RK1f4ELxnBy2E=;
        b=T9zNTAU7eg7gOxUxVeP0pKzzpp/dXNU2gVBj9u2TKnWmI1yRbyYoY5ewKGq0G755jd
         x46pqUctdo72pim3YaNsfFNhTGHyzR3dTV1SvjITf3gDTP80uAoozdgaUXfSM9X8ofSR
         P7X6RbwZ3A9gah2LnFrYoze14DViWDViVX3UdDgbUFEx4bCxQjm8/16CYrPHG7xcXi6I
         zM5W9NKRxq+anWHqBK4tdc8S9GoF1QM6MPMBz43PyY23zZeqnKT67nmmW1wDfvAgHy0I
         Ge7EHyCOESJNt5X9Hr403KtJYvdBDVxzc2ZWSkmO3mD45x+KS/ll3dvyGN8Tog2u3tJW
         AX5g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of geert.uytterhoeven@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=geert.uytterhoeven@gmail.com
X-Gm-Message-State: APjAAAUNRkpwIvfdYEcgBRbfpYiHBs/kCFnxvHEeZNoGlCY/+1uPFaT/
	FYaQj7NLgySlQ3sVeMlAhNE55TvwTTRtlhACCaHXokEeP2JrJcFtEZtiSPRQ2DfNPw/XsJOh5un
	nR/MSodQ2xl8X+C4rl5a5HcWYj7nH2EKCC471sIVghrbJc8p1PCJXaJmqvScssrM=
X-Received: by 2002:ab0:300a:: with SMTP id f10mr5515818ual.32.1553261851468;
        Fri, 22 Mar 2019 06:37:31 -0700 (PDT)
X-Received: by 2002:ab0:300a:: with SMTP id f10mr5515789ual.32.1553261850839;
        Fri, 22 Mar 2019 06:37:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553261850; cv=none;
        d=google.com; s=arc-20160816;
        b=ZoE1xScU9Ga3NAgqKPMhZZR2w6HXAZSZDEI7XvPbW/gA5EoGkLBUlk2jgg5aE9Tb2z
         DT/FKkHgQ89o1KVj8iAOdGNbEVs3gM2DobTt1UPBUDTNH9N/KAS7JvZ99fXEJQuBy0ZE
         FTezp92Tx5meHa/HJ1Z+QOmlMJKx8BxYVgV6/VXRn69yFo4pck+Mtw6s+O+RwdLoAC3A
         mtOsGBNZCmOjHzfCFCYy3gGqAGFpnMsqgXRUCGd4VZWeJWg8GedkTuQamX8ZhDgYtB8J
         4b0eC2Uf9xiAWhkVQ/TpwM3Szz4xm52Zalb1EcpM0ctRvks0vnoZWwvsscMpJEV9VJ3X
         zjIg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version;
        bh=XzQ9NHyI634XKb+UUobZCMcWq8m8E9RK1f4ELxnBy2E=;
        b=RwgTaR6KEP+BzfUHni+aIPB+1ga4kMG6SQ3rG+5OqDmV+fD2YGdjLAauWYpIIzXoMF
         vtWIwe7HyNssbHepCfFDtNqA1lkjy38PWK36QF7Wt8jyrnzSfjgPeRKIQzSHLs3IB9w7
         tU09GZyARDvlPoRLNhN445S23EAQeK1YvrT7oSSuDptgXYYsWRC7UcQLB4NWK/8yNB/C
         2hUCt8x91HEyITUxLRXdiSqkwLoZ7COdJrJS+f1vqru2D29ykttRlMWr/L2XuikMuZjA
         23XF3quulneVNOT6uMwTovSo8W04ccdLXiRkXzZQn8PWbDjd/iDpCD16R5dZI2QTN1RU
         G6aA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of geert.uytterhoeven@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=geert.uytterhoeven@gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k16sor5694041uao.8.2019.03.22.06.37.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 22 Mar 2019 06:37:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of geert.uytterhoeven@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of geert.uytterhoeven@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=geert.uytterhoeven@gmail.com
X-Google-Smtp-Source: APXvYqy4ogpwjpSonoiPfh2lc9ghBw42usNLeIrbxmtszFsz2NZOsJfJk0zpTsb127+lhrr709ywFNgm7FrLQ8o0S0U=
X-Received: by 2002:ab0:6419:: with SMTP id x25mr938049uao.86.1553261850477;
 Fri, 22 Mar 2019 06:37:30 -0700 (PDT)
MIME-Version: 1.0
References: <20190322132108.25501-1-sakari.ailus@linux.intel.com>
In-Reply-To: <20190322132108.25501-1-sakari.ailus@linux.intel.com>
From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Fri, 22 Mar 2019 14:37:18 +0100
Message-ID: <CAMuHMdVmqqjVx7As9AAywYxYXG=grijF5rF77OBn6TUjM9+xKw@mail.gmail.com>
Subject: Re: [PATCH 0/2] Remove support for deprecated %pf and %pF in vsprintf
To: Sakari Ailus <sakari.ailus@linux.intel.com>
Cc: Petr Mladek <pmladek@suse.com>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, scsi <linux-scsi@vger.kernel.org>, 
	Linux PM list <linux-pm@vger.kernel.org>, Linux MMC List <linux-mmc@vger.kernel.org>, 
	"linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, linux-um@lists.infradead.org, 
	linux-f2fs-devel@lists.sourceforge.net, linux-block@vger.kernel.org, 
	ACPI Devel Maling List <linux-acpi@vger.kernel.org>, netdev <netdev@vger.kernel.org>, 
	linux-btrfs <linux-btrfs@vger.kernel.org>, linux-pci <linux-pci@vger.kernel.org>, 
	sparclinux <sparclinux@vger.kernel.org>, xen-devel@lists.xenproject.org, 
	ceph-devel <ceph-devel@vger.kernel.org>, 
	Andy Shevchenko <andriy.shevchenko@linux.intel.com>, Linux MM <linux-mm@kvack.org>, 
	Linux ARM <linux-arm-kernel@lists.infradead.org>, 
	Lars Ellenberg <drbd-dev@lists.linbit.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Sakari,

On Fri, Mar 22, 2019 at 2:25 PM Sakari Ailus
<sakari.ailus@linux.intel.com> wrote:
> The printk family of functions supports %ps and %pS conversion specifiers
> to print function names. Yet the deprecated %pf and %pF conversion
> specifiers with equivalent functionality remain supported. A number of
> users of %pf and %pF remain.
>
> This patchsets converts the existing users of %pf and %pF to %ps and %pS,
> respectively, and removes support for the deprecated %pf and %pF.
>
> The patches apply cleanly both on 5.1-rc1 as well as on Linux-next. No new
> %pf or %pF users have been added in the meantime so the patch is
> sufficient as itself on linux-next, too.

Do you know in which commit they became deprecated, so the backporters
know how far this can be backported safely?

Thanks!

Gr{oetje,eeting}s,

                        Geert

-- 
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds

