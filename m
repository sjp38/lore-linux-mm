Return-Path: <SRS0=QIji=SN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EAA2DC10F13
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 17:35:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9554F2084D
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 17:35:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="Pe2CTJwF"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9554F2084D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6B11F6B026D; Thu, 11 Apr 2019 13:35:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 65DB36B026E; Thu, 11 Apr 2019 13:35:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 54C0E6B026F; Thu, 11 Apr 2019 13:35:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f197.google.com (mail-vk1-f197.google.com [209.85.221.197])
	by kanga.kvack.org (Postfix) with ESMTP id 301F06B026D
	for <linux-mm@kvack.org>; Thu, 11 Apr 2019 13:35:24 -0400 (EDT)
Received: by mail-vk1-f197.google.com with SMTP id b75so2826719vke.6
        for <linux-mm@kvack.org>; Thu, 11 Apr 2019 10:35:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=IFQ2qc30fvBPdVTm6E0fqqBDLHFIUqXIvbHwaJ+icCI=;
        b=CumTEPZdUR0Ddr6DLvKg+iyZkd9897lS3jLGFTtfeSFntwRlsnmVSRkQG1ZwXIZVcc
         zhsTyLkkviMlXyInu1pu6efh3dy0uxoqcyH7MXE5Q0HE98mUPn8DWySKNLVjpOjiAw7p
         WOak4eV97LpsEChRzvFkR81QmX53T5UwC4RPt0whvjqAO0ALw+K+BCJaq9esVFDmqtJT
         Jb1NCaV2zv2vOvDrqTkC2cWGTiYpK3lX6fDh678/FH4fkBZE4IZSVcYLwPSMdA1xe2Pl
         iX/joXXs14iCrs5nvXHhCIsJg4r9PRWqIzCJ45qVdPGMv3NGGFNhpBuRDDPVFBh8fp3T
         wq0w==
X-Gm-Message-State: APjAAAUr3qUs/8F+IUu2PAETvErwypJ5rP2EfsLLxD2gGoawxjyqMGVU
	cZXMAZrQypZerpYZCN0FVSmaHIP6U1NXjZDKv4Lv55DOkGxKl74mwzLiTOM9jTiDB5EyfqRX1OT
	2p43NYRZR1MC9AKgLyT1pPJzxnvTU8WTZ3smdhigSMDeuczVxyl5p35bZp2JYo24IUg==
X-Received: by 2002:ab0:70d4:: with SMTP id r20mr946347ual.67.1555004123868;
        Thu, 11 Apr 2019 10:35:23 -0700 (PDT)
X-Received: by 2002:ab0:70d4:: with SMTP id r20mr946328ual.67.1555004123351;
        Thu, 11 Apr 2019 10:35:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555004123; cv=none;
        d=google.com; s=arc-20160816;
        b=mfFKcCShBfJd1PQVmGP0+Vkw6LGIixHIQojf7wnFDqswzwzlTmu/uDRyVvMJGfhjSj
         WBo1LlwB0M4U2HwkqEyAWb73lmqbzMaTYv28OhCCi629wPFXsYyb8T/3Nk//evAQwfVH
         MP4Bere7H/vL5KfwN3W9u8boMyTOQqHCbJ4LIUrJqou2y1GkBuYJveKBTlrumDa2IBZB
         b/EUYCbEczKAVjLICqIPZTK31YlrGqaAax3EMOZJBCTAH83eG91zmrLRSgSUpL5rLKBT
         smympOATvl1UlQ5JKgryIMkD05tSug+GmxPZ0hpEytMeEIFylY5W0Gin2/VJslF8knyU
         gjiA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=IFQ2qc30fvBPdVTm6E0fqqBDLHFIUqXIvbHwaJ+icCI=;
        b=FCYwJVlg/hKy5/EscxvGi3X0CB2y6KOC21xlE9c36eIx0/uSvyT91Ox2nrbr45yU90
         3lgK4VHv3fFNZY9GFjJbHzeTv3tsT/UTgPnHFAvr46DbYQgOjjij13IiImzAOKcWYq22
         DCA5ZvGCQGbXFdfOm3CGN94Zusa8OEIjlan6+V44rg+3qYY68jx6k40Eq+jfqR4qQNOp
         hnvZHFjFiT0iWYnnRFip72R1nJn9ZEVlH7JlH6qtWKKgDtXK9tB43io23TPy43toTn34
         R2i23l+n+AD0xpyhatIr5Gjf6VJ+laVHB3197kNqXLLVEWcZJChzHjV9N+cHQz4hj03O
         yUIA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=Pe2CTJwF;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y140sor10875170vsc.13.2019.04.11.10.35.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 11 Apr 2019 10:35:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=Pe2CTJwF;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=IFQ2qc30fvBPdVTm6E0fqqBDLHFIUqXIvbHwaJ+icCI=;
        b=Pe2CTJwFxEwXkNUoQqsrnd6W3m64wCfVEBUbQv7WMNR4tAylXbROeUT7alXM8mo9/t
         m2IZzClels8s5qkUGDdlvSMoqIfVXvtkI945pECdlC/vvzVmgGWirTG5A9reB+wMBaGz
         lHWHk/C0hob8NqiA4sl6kwSHqt0daCQ5tVleo=
X-Google-Smtp-Source: APXvYqwQrt7Ml0Zn4DsX1iEk21idkpDs+VmXYZx12sdQrLqrwUSxSU/T83aYzx/ZXgHQd3th8jz2DQ==
X-Received: by 2002:a67:f753:: with SMTP id w19mr28121509vso.27.1555004122524;
        Thu, 11 Apr 2019 10:35:22 -0700 (PDT)
Received: from mail-vk1-f174.google.com (mail-vk1-f174.google.com. [209.85.221.174])
        by smtp.gmail.com with ESMTPSA id s194sm18145991vkf.37.2019.04.11.10.35.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Apr 2019 10:35:21 -0700 (PDT)
Received: by mail-vk1-f174.google.com with SMTP id g24so1560820vki.2
        for <linux-mm@kvack.org>; Thu, 11 Apr 2019 10:35:21 -0700 (PDT)
X-Received: by 2002:a1f:29c5:: with SMTP id p188mr28647311vkp.24.1555004120656;
 Thu, 11 Apr 2019 10:35:20 -0700 (PDT)
MIME-Version: 1.0
References: <20190215185151.GG7897@sirena.org.uk> <20190226155948.299aa894a5576e61dda3e5aa@linux-foundation.org>
 <CAPcyv4ivjC8fNkfjdFyaYCAjGh7wtvFQnoPpOcR=VNZ=c6d6Rg@mail.gmail.com>
 <20190228151438.fc44921e66f2f5d393c8d7b4@linux-foundation.org>
 <CAPcyv4hDmmK-L=0txw7L9O8YgvAQxZfVFiSoB4LARRnGQ3UC7Q@mail.gmail.com>
 <026b5082-32f2-e813-5396-e4a148c813ea@collabora.com> <20190301124100.62a02e2f622ff6b5f178a7c3@linux-foundation.org>
 <3fafb552-ae75-6f63-453c-0d0e57d818f3@collabora.com> <CAPcyv4hMNiiM11ULjbOnOf=9N=yCABCRsAYLpjXs+98bRoRpCA@mail.gmail.com>
 <36faea07-139c-b97d-3585-f7d6d362abc3@collabora.com> <20190306140529.GG3549@rapoport-lnx>
 <21d138a5-13e4-9e83-d7fe-e0639a8d180a@collabora.com> <CAPcyv4jBjUScKExK09VkL8XKibNcbw11ET4WNUWUWbPXeT9DFQ@mail.gmail.com>
 <CAGXu5jLAPKBE-EdfXkg2AK5P=qZktW6ow4kN5Yzc0WU2rtG8LQ@mail.gmail.com> <CABXOdTdVvFn=Nbd_Anhz7zR1H-9QeGByF3HFg4ZFt58R8=H6zA@mail.gmail.com>
In-Reply-To: <CABXOdTdVvFn=Nbd_Anhz7zR1H-9QeGByF3HFg4ZFt58R8=H6zA@mail.gmail.com>
From: Kees Cook <keescook@chromium.org>
Date: Thu, 11 Apr 2019 10:35:08 -0700
X-Gmail-Original-Message-ID: <CAGXu5j+Sw2FyMc8L+8hTpEKbOsySFGrCmFtVP5gt9y2pJhYVUw@mail.gmail.com>
Message-ID: <CAGXu5j+Sw2FyMc8L+8hTpEKbOsySFGrCmFtVP5gt9y2pJhYVUw@mail.gmail.com>
Subject: Re: next/master boot bisection: next-20190215 on beaglebone-black
To: Guenter Roeck <groeck@google.com>
Cc: kernelci@groups.io, Dan Williams <dan.j.williams@intel.com>, 
	Guillaume Tucker <guillaume.tucker@collabora.com>, Mike Rapoport <rppt@linux.ibm.com>, 
	Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, 
	Mark Brown <broonie@kernel.org>, Tomeu Vizoso <tomeu.vizoso@collabora.com>, 
	Matt Hart <matthew.hart@linaro.org>, Stephen Rothwell <sfr@canb.auug.org.au>, 
	Kevin Hilman <khilman@baylibre.com>, 
	Enric Balletbo i Serra <enric.balletbo@collabora.com>, Nicholas Piggin <npiggin@gmail.com>, 
	Dominik Brodowski <linux@dominikbrodowski.net>, 
	Masahiro Yamada <yamada.masahiro@socionext.com>, Adrian Reber <adrian@lisas.de>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, 
	Linux MM <linux-mm@kvack.org>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, 
	Richard Guy Briggs <rgb@redhat.com>, "Peter Zijlstra (Intel)" <peterz@infradead.org>, info@kernelci.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 11, 2019 at 9:42 AM Guenter Roeck <groeck@google.com> wrote:
>
> On Thu, Apr 11, 2019 at 9:19 AM Kees Cook <keescook@chromium.org> wrote:
> >
> > On Thu, Mar 7, 2019 at 7:43 AM Dan Williams <dan.j.williams@intel.com> wrote:
> > > I went ahead and acquired one of these boards to see if I can can
> > > debug this locally.
> >
> > Hi! Any progress on this? Might it be possible to unblock this series
> > for v5.2 by adding a temporary "not on ARM" flag?
> >
>
> Can someone send me a pointer to the series in question ? I would like
> to run it through my testbed.

It's already in -mm and linux-next (",mm: shuffle initial free memory
to improve memory-side-cache utilization") but it gets enabled with
CONFIG_SHUFFLE_PAGE_ALLOCATOR=y (which was made the default briefly in
-mm which triggered problems on ARM as was reverted).

-- 
Kees Cook

