Return-Path: <SRS0=ZelW=WN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9139DC3A59B
	for <linux-mm@archiver.kernel.org>; Sat, 17 Aug 2019 09:14:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 450B22075E
	for <linux-mm@archiver.kernel.org>; Sat, 17 Aug 2019 09:14:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="mvJ529A/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 450B22075E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D2D376B0007; Sat, 17 Aug 2019 05:14:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CB6D86B000A; Sat, 17 Aug 2019 05:14:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B57A16B000C; Sat, 17 Aug 2019 05:14:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0024.hostedemail.com [216.40.44.24])
	by kanga.kvack.org (Postfix) with ESMTP id 929756B0007
	for <linux-mm@kvack.org>; Sat, 17 Aug 2019 05:14:26 -0400 (EDT)
Received: from smtpin19.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 43D0B8248AD6
	for <linux-mm@kvack.org>; Sat, 17 Aug 2019 09:14:26 +0000 (UTC)
X-FDA: 75831358932.19.ear16_26ac7de3f7959
X-HE-Tag: ear16_26ac7de3f7959
X-Filterd-Recvd-Size: 4314
Received: from mail-ed1-f66.google.com (mail-ed1-f66.google.com [209.85.208.66])
	by imf15.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Sat, 17 Aug 2019 09:14:25 +0000 (UTC)
Received: by mail-ed1-f66.google.com with SMTP id g8so7102843edm.6
        for <linux-mm@kvack.org>; Sat, 17 Aug 2019 02:14:25 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=Sirr0PNWi30rC1+3FoJFRyHctdtSV+xSzXjml2UEUC4=;
        b=mvJ529A/blvAFkMU0nkpXUBqz+Yk2QjPFjBP3Sn3pBPDEC6EGRey+JFkd+viVaYzXb
         8oudACB0vsLfN2fo63EIDmVE7slQCVBLL1vrUgW9cTrxhNPQ9k5QvhhItUIycUSyCFAj
         xCk/XxFyo2O82cg/ToR2jzwSBfYlJxvXXKgocycw7Kp6Aixk1aW6HxdNmcz7Un6AZY03
         0LXD+CifY8ayqjXyDsQMH9NuyUDEZ/pf7205OnhWtdvTlWuhXUdkkXmz0lH9GbiVcRbG
         eDYoN+U44rBrE0dyd+NuYJJD8CNWDUr6Tpuncmhzpxly8nw7lNQaBswAve2VZPN3Y9Bf
         T7Vg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=Sirr0PNWi30rC1+3FoJFRyHctdtSV+xSzXjml2UEUC4=;
        b=BI08+1LQRoGVMpCWhxC/nOG6wozlwddbhQdb5y8VXnXlSgsMk0V8IeoJIGnclTwzpH
         K1DpccLU78igD8GdIJH/lxkNpB+pNF7eXzADZ+YNn3hlw00fKCQEazvuPTw7NFswXxqE
         otzM+PtG87ynkXUfUI5yRkrGyhnm8GOkKkvlpp0VCm1Mg3W/7mDXvNmLI7rIawnxgZVK
         EAIbCb0icc+3b9hmmIkErjy2IFO4Kzo/hvQKlne3OZMVrO0SRCk4mXcxJHxy2YdMAuHt
         ynXSpz3U8p2ZjU7DjgD4TMlJBb0BHX+DENGrMCOO87nKvlOoXNR7IcanSL8+9OymItke
         p4rQ==
X-Gm-Message-State: APjAAAW4KH5YOKAs6aRCviUEaWlghpKYNt85M8geS5mUaXuv+ctogIJW
	G/Wu3U2BgVqLTJc/HgSdzeITgG8zc8gXFcvMRW8=
X-Google-Smtp-Source: APXvYqx8YnCqgmW+SJMM2KxQi7LlM/1/loQXZvtlig2ikAJSeV0lKhadRN+FfbIn1ocNg/q9kdwGfz8QG+DIlsEjpWs=
X-Received: by 2002:a17:906:2310:: with SMTP id l16mr6536483eja.0.1566033264390;
 Sat, 17 Aug 2019 02:14:24 -0700 (PDT)
MIME-Version: 1.0
References: <1566010813-27219-1-git-send-email-huangzhaoyang@gmail.com> <20190817090021.GA10627@rapoport-lnx>
In-Reply-To: <20190817090021.GA10627@rapoport-lnx>
From: Zhaoyang Huang <huangzhaoyang@gmail.com>
Date: Sat, 17 Aug 2019 17:14:13 +0800
Message-ID: <CAGWkznGs0Y2PCowr2SDRnJrKXk08RS-sptTxhqR=6yo8G3tBnQ@mail.gmail.com>
Subject: Re: [PATCH] arch : arm : add a criteria for pfn_valid
To: Mike Rapoport <rppt@linux.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Zhaoyang Huang <zhaoyang.huang@unisoc.com>, 
	Russell King <linux@armlinux.org.uk>, Rob Herring <robh@kernel.org>, 
	Florian Fainelli <f.fainelli@gmail.com>, Geert Uytterhoeven <geert@linux-m68k.org>, 
	Doug Berger <opendmb@gmail.com>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, 
	LKML <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Aug 17, 2019 at 5:00 PM Mike Rapoport <rppt@linux.ibm.com> wrote:
>
> On Sat, Aug 17, 2019 at 11:00:13AM +0800, Zhaoyang Huang wrote:
> > From: Zhaoyang Huang <zhaoyang.huang@unisoc.com>
> >
> > pfn_valid can be wrong while the MSB of physical address be trimed as pfn
> > larger than the max_pfn.
>
> How the overflow of __pfn_to_phys() is related to max_pfn?
> Where is the guarantee that __pfn_to_phys(max_pfn) won't overflow?
eg, the invalid pfn value as 0x1bffc0 will pass pfn_valid if there is
a memory block while the max_pfn is 0xbffc0.
In ARM64, bellowing condition check will help to
>
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
>
> --
> Sincerely yours,
> Mike.
>

