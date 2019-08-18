Return-Path: <SRS0=q2Op=WO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D0339C3A589
	for <linux-mm@archiver.kernel.org>; Sun, 18 Aug 2019 07:47:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 788B720851
	for <linux-mm@archiver.kernel.org>; Sun, 18 Aug 2019 07:47:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="A4os+5u3"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 788B720851
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DCF536B0008; Sun, 18 Aug 2019 03:47:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D56F16B000A; Sun, 18 Aug 2019 03:47:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C1DCA6B000C; Sun, 18 Aug 2019 03:47:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0168.hostedemail.com [216.40.44.168])
	by kanga.kvack.org (Postfix) with ESMTP id 9B2676B0008
	for <linux-mm@kvack.org>; Sun, 18 Aug 2019 03:47:04 -0400 (EDT)
Received: from smtpin19.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 56AF38E5A
	for <linux-mm@kvack.org>; Sun, 18 Aug 2019 07:47:04 +0000 (UTC)
X-FDA: 75834767568.19.seat56_3daccab1d8957
X-HE-Tag: seat56_3daccab1d8957
X-Filterd-Recvd-Size: 5631
Received: from mail-ed1-f68.google.com (mail-ed1-f68.google.com [209.85.208.68])
	by imf34.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Sun, 18 Aug 2019 07:47:03 +0000 (UTC)
Received: by mail-ed1-f68.google.com with SMTP id a21so8532631edt.11
        for <linux-mm@kvack.org>; Sun, 18 Aug 2019 00:47:03 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=0i8dYHRhjyQq56TtntndePfnzxoMqtxxO44HUTYu3/I=;
        b=A4os+5u3AY9vy+3QQo6CEH4KDIVd4rEY00yVYB+1nr3SPCydBTHH0NOAOGDCZTwXoP
         dWGdwe5366Lr2S9fz2ZmeWNVYUC2YwIKV2bgX+BRfY+phiLBKAvPs/H/h45jDmL4CdGQ
         CteNzyH9QlemetYkgT9DeRfjDBH5U2LOUQIFhYjilIYw90x6pb1Rsu/2kRF9ZijBoo5B
         8PWMwAOCDouoYs5TJHkVyJ0UqCQclg/bmcNadOReHzElgAnejEfXBij+QydXCVlKryu6
         YTh8+9xgFIsSJTVT0rDxOec55sC5eyTtbR2z+YXabdtEdV4QEioEZNioH3vCjWqmfRKO
         dNPQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=0i8dYHRhjyQq56TtntndePfnzxoMqtxxO44HUTYu3/I=;
        b=W0YaEIgs+LTPfBo3z3Cokult0tMmbWVY1FQQkbWeojuOt+kAT8wd1/55Af/Hdbxi6X
         KI0lkIsGNL1qmcF9TGIHcsn2YpxSf0O4oU2JAPQNo/aOlV6ATXCsWUz0+HW0oTeRETMd
         N3+hm/TbfCe1e8yaT/HQZVNAz8Y8niCc0lYW/A7LdXszzT1fJ/IiVsWSBHfBMm5FaOAt
         M3pscp6pK6AYZZP5w5K5TnZ3Jfoymm4QsU8vomvbIhjnmELuyb306Uq01dnQ/hJAIJwo
         0bl7cC80LqA8Tgtceey12iOtRS7X0+KxinIO3pZl7hsjZIHE25Q7GuGi5yeOhETzLvsF
         UXow==
X-Gm-Message-State: APjAAAVGJeb6AYm7tRMqDCEBnp+S1LOshtYAiaiISC4GJzx364M5P28B
	vjflR4wVo82rNvV7v69m8GXc8KjxH6O5cKV2rHrLUafb
X-Google-Smtp-Source: APXvYqz1mUZECTJrsCX8TbM4B5MfF4HYsBDtV4p4ZNqdgilx7DGF6UwwN+cffa9ljLeQJ/iS6MkNUUMRvRqMIdwbhx4=
X-Received: by 2002:aa7:d94f:: with SMTP id l15mr19034091eds.299.1566114422571;
 Sun, 18 Aug 2019 00:47:02 -0700 (PDT)
MIME-Version: 1.0
References: <1566010813-27219-1-git-send-email-huangzhaoyang@gmail.com> <20190817183240.GM13294@shell.armlinux.org.uk>
In-Reply-To: <20190817183240.GM13294@shell.armlinux.org.uk>
From: Zhaoyang Huang <huangzhaoyang@gmail.com>
Date: Sun, 18 Aug 2019 15:46:51 +0800
Message-ID: <CAGWkznEvHE6B+eLnCn=s8Hgm3FFbbXcEdj_OxCM4NOj0u61FGA@mail.gmail.com>
Subject: Re: [PATCH] arch : arm : add a criteria for pfn_valid
To: Russell King - ARM Linux admin <linux@armlinux.org.uk>
Cc: Andrew Morton <akpm@linux-foundation.org>, Zhaoyang Huang <zhaoyang.huang@unisoc.com>, 
	Mike Rapoport <rppt@linux.ibm.com>, Rob Herring <robh@kernel.org>, 
	Florian Fainelli <f.fainelli@gmail.com>, Geert Uytterhoeven <geert@linux-m68k.org>, 
	Doug Berger <opendmb@gmail.com>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, 
	LKML <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Aug 18, 2019 at 2:32 AM Russell King - ARM Linux admin
<linux@armlinux.org.uk> wrote:
>
> On Sat, Aug 17, 2019 at 11:00:13AM +0800, Zhaoyang Huang wrote:
> > From: Zhaoyang Huang <zhaoyang.huang@unisoc.com>
> >
> > pfn_valid can be wrong while the MSB of physical address be trimed as pfn
> > larger than the max_pfn.
>
> What scenario are you addressing here?  At a guess, you're addressing
> the non-LPAE case with PFNs that correspond with >= 4GiB of memory?
Please find bellowing for the callstack caused by this defect. The
original reason is a invalid PFN passed from userspace which will
introduce a invalid page within stable_page_flags and then kernel
panic.

[46886.723249] c7 [<c031ff98>] (stable_page_flags) from [<c03203f8>]
(kpageflags_read+0x90/0x11c)
[46886.723256] c7  r9:c101ce04 r8:c2d0bf70 r7:c2d0bf70 r6:1fbb10fb
r5:a8686f08 r4:a8686f08
[46886.723264] c7 [<c0320368>] (kpageflags_read) from [<c0312030>]
(proc_reg_read+0x80/0x94)
[46886.723270] c7  r10:000000b4 r9:00000008 r8:c2d0bf70 r7:00000000
r6:00000001 r5:ed8e7240
[46886.723272] c7  r4:00000000
[46886.723280] c7 [<c0311fb0>] (proc_reg_read) from [<c02a6e6c>]
(__vfs_read+0x48/0x150)
[46886.723284] c7  r7:c2d0bf70 r6:c0f09208 r5:c0a4f940 r4:c40326c0
[46886.723290] c7 [<c02a6e24>] (__vfs_read) from [<c02a7018>]
(vfs_read+0xa4/0x158)
[46886.723296] c7  r9:a8686f08 r8:00000008 r7:c2d0bf70 r6:a8686f08
r5:c40326c0 r4:00000008
[46886.723301] c7 [<c02a6f74>] (vfs_read) from [<c02a778c>]
(SyS_pread64+0x80/0xb8)
[46886.723306] c7  r8:00000008 r7:c0f09208 r6:c40326c0 r5:c40326c0 r4:fdd887d8
[46886.723315] c7 [<c02a770c>] (SyS_pread64) from [<c0108620>]
(ret_fast_syscall+0x0/0x28)

>
> >
> > Signed-off-by: Zhaoyang Huang <huangzhaoyang@gmail.com>
> > ---
> >  arch/arm/mm/init.c | 3 ++-
> >  1 file changed, 2 insertions(+), 1 deletion(-)
> >
> > diff --git a/arch/arm/mm/init.c b/arch/arm/mm/init.c
> > index c2daabb..9c4d938 100644
> > --- a/arch/arm/mm/init.c
> > +++ b/arch/arm/mm/init.c
> > @@ -177,7 +177,8 @@ static void __init zone_sizes_init(unsigned long min, unsigned long max_low,
> >  #ifdef CONFIG_HAVE_ARCH_PFN_VALID
> >  int pfn_valid(unsigned long pfn)
> >  {
> > -     return memblock_is_map_memory(__pfn_to_phys(pfn));
> > +     return (pfn > max_pfn) ?
> > +             false : memblock_is_map_memory(__pfn_to_phys(pfn));
> >  }
> >  EXPORT_SYMBOL(pfn_valid);
> >  #endif
> > --
> > 1.9.1
> >
> >
>
> --
> RMK's Patch system: https://www.armlinux.org.uk/developer/patches/
> FTTC broadband for 0.8mile line in suburbia: sync at 12.1Mbps down 622kbps up
> According to speedtest.net: 11.9Mbps down 500kbps up

