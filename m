Return-Path: <SRS0=JxSR=R6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 829FCC43381
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 03:57:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3D8F0206B8
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 03:57:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="aD9NBc9i"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3D8F0206B8
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C17556B0007; Tue, 26 Mar 2019 23:57:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BC6BE6B0008; Tue, 26 Mar 2019 23:57:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id ADC8B6B000A; Tue, 26 Mar 2019 23:57:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id 61A7B6B0007
	for <linux-mm@kvack.org>; Tue, 26 Mar 2019 23:57:48 -0400 (EDT)
Received: by mail-wm1-f70.google.com with SMTP id b133so5770883wmg.7
        for <linux-mm@kvack.org>; Tue, 26 Mar 2019 20:57:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=L2DezMdYEOzR/bwdOsV89vwOEsShIwrQUGZoxM2U1Cw=;
        b=c6wJ33+/4KYFlZDBAdQDzQWoNsALBZl1UcV+bgvBUm/APkCHoLiU+B3ehiOJPlQdNq
         RWZuJpHxggxdFtdyPGWUaAch5/Dvj8V2m2eCxJvG+VlyrU+z9MPmzWXal2aKKEey1HxS
         Dqji5ssQo6YJy1Ucorvp14hxmyh8FxYdb6tzIcMcgrNrxL5iJXtL98mvKd6DWdPJHLyE
         /c4dGX2mN6TyXaZIqrVJXK0hbCoH9Lf3SWHTqcb+eE92GNoDC/JAyH0YzcnewC5VEDdt
         Fc3KfKMZeKaXnLpyBi4+O2hw+9rcJj4RME/PziY1PXxfoO3uWIX+V7COWgPBFdE0LZNA
         gP2g==
X-Gm-Message-State: APjAAAW06BF5pRA66ZzvKUcxoIZrOI3xUB1ewQvw3VuCvlRbvoX/wdoa
	JbW03O93TRUs1+jMWeNKw+j+akyJuDT3YZqFGm8IjJeO4pYjYKRfryUpli9jBEmWhiCJCr8m+lm
	PW0n8evSD2jNFtYs5gJ65ZQXzPhvFMEqmDOxWh68o+M7Rw1bJfYCP6KgAAbnft14TQQ==
X-Received: by 2002:a1c:1d97:: with SMTP id d145mr10498014wmd.136.1553659067973;
        Tue, 26 Mar 2019 20:57:47 -0700 (PDT)
X-Received: by 2002:a1c:1d97:: with SMTP id d145mr10497987wmd.136.1553659067231;
        Tue, 26 Mar 2019 20:57:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553659067; cv=none;
        d=google.com; s=arc-20160816;
        b=FQzWZYWUqvBca3U5AbxRM20nhCjqz77V83iwF7erw8+bP/gt9lRHZjTyQt4q17SmeA
         AxZEsh9/Gn+hXud2xKbnrrB7hnKLm6oNUD6je/yh3BbzgJSdeX94p7MkTywApPuXs4Ec
         uNGK+f440d8UM+XNIDmmSPOrNnFV5CdEgBSJXGB9Vv6YafpGGOWW23ehBFK9V8No6EG1
         GGxU0LC0mKyBjuO8no4wpqEjSf842ysQsp7p9Pus7loC1oUmTBYEr1JZyQsNXx17r1JP
         E0l445kMLybAcfiGY2R5xW54tKE7UOFKHeuT+QNUDUxsE/AwLNxUoeDrXsZXyPtbOsTD
         PD4w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=L2DezMdYEOzR/bwdOsV89vwOEsShIwrQUGZoxM2U1Cw=;
        b=rPs7BNuTTgOH4BXdaJtlIezlq/EGnqLk/myFm7U/2GkXPEAe1fIKdbl49Ds2kTDjaB
         +MPFFZwxPjluHK+uz8C8bj4roq2DnGBDeCexgmfapXA4hRwHx1nues6zq3a81DDtOu6Y
         SXBZZUtVJfbeBhfebooD1o0hn1wXAtUee8gC88dIWIRuURVJn7PFKZseYXqsT309zjGe
         F2M/0MTiZOYinx/D9ReDcanNAwA/zVu6YBigMfiSBhl61lL0bF2MIW7PzjFbQ5406OFC
         cW/EYUxN6hiGaXvYK2JZXp2axau5SJkeVxqeIQ5XgNVp5vrwKnd/+7Hz2u/KodyAWwvN
         9MCQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=aD9NBc9i;
       spf=pass (google.com: domain of mikhail.v.gavrilov@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mikhail.v.gavrilov@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z4sor8144311wmb.29.2019.03.26.20.57.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 26 Mar 2019 20:57:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of mikhail.v.gavrilov@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=aD9NBc9i;
       spf=pass (google.com: domain of mikhail.v.gavrilov@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mikhail.v.gavrilov@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=L2DezMdYEOzR/bwdOsV89vwOEsShIwrQUGZoxM2U1Cw=;
        b=aD9NBc9ipJlWH8d0AXxzIg9RQZmnc7+XE5PpXKA+vR+mh61BN+yByplIHpMaqG0eG4
         0E8WkD3DPooZWBAR0mZ/gZBE9/9wGbfv+1zaXDP7/TE4Sg/t9dwmbvUdeJvFGa2tznrH
         RwsEj4JcxglJA0dPyz/8Ma2WTkAoBseZHxeLS8iq4pzHw0fRgYPXK9fyUKo5Iz43cda6
         YkbV4dBT8sJNWYUk+aYU1C8//YSM1LShB0Vt9A1OatccxmYz4tSpIHSoS7lNiYXP8qar
         EEciiBg71rQvrQThxGqzcddC1sPVdvfta6rb9lOVlgWq/wtrojkAkrtnl7B2SDVGyIxi
         BW5g==
X-Google-Smtp-Source: APXvYqzvec8EKMcY+1+SkZLV8QDF2l3axnKr/0hLTGoVDFDpH/TRQpfcH+fOgfSsqqOCAHI5gme2Fs7bI+6aWkUn1ow=
X-Received: by 2002:a1c:cc0a:: with SMTP id h10mr16859528wmb.22.1553659066604;
 Tue, 26 Mar 2019 20:57:46 -0700 (PDT)
MIME-Version: 1.0
References: <CABXGCsM-SgUCAKA3=WpL7oWZ0Xq8A1Wf-Eh6MO0seee+TviDWQ@mail.gmail.com>
 <20190315205826.fgbelqkyuuayevun@ca-dmjordan1.us.oracle.com>
 <CABXGCsMcXb_W-w0AA4ZFJ5aKNvSMwFn8oAMaFV7AMHgsH_UB7g@mail.gmail.com>
 <CABXGCsO+DoEu5KMW8bELCKahhfZ1XGJCMYJ3Nka8B0Xi0A=aKg@mail.gmail.com>
 <20190322111527.GG3189@techsingularity.net> <CABXGCsMG+oCTxiEv1vmiK0P+fvr7ZiuOsbX-GCE13gapcRi5-Q@mail.gmail.com>
 <20190325105856.GI3189@techsingularity.net> <CABXGCsMjY4uQ_xpOXZ93idyzTS5yR2k-ZQ2R2neOgm_hDxd7Og@mail.gmail.com>
 <20190325203142.GJ3189@techsingularity.net> <CABXGCsNFNHee3Up78m7qH0NjEp_KCiNwQorJU=DGWUC4meGx1w@mail.gmail.com>
 <20190326120327.GK3189@techsingularity.net>
In-Reply-To: <20190326120327.GK3189@techsingularity.net>
From: Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>
Date: Wed, 27 Mar 2019 08:57:35 +0500
Message-ID: <CABXGCsMPmxMRDn2mebirBv9B2uhskLMfzRWr3t8_=HNcU=SZ9Q@mail.gmail.com>
Subject: Re: kernel BUG at include/linux/mm.h:1020!
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Daniel Jordan <daniel.m.jordan@oracle.com>, Qian Cai <cai@lca.pw>, linux-mm@kvack.org, 
	vbabka@suse.cz
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 26 Mar 2019 at 17:03, Mel Gorman <mgorman@techsingularity.net> wrote:
>
> Good news (for now at least). I've written an appropriate changelog and
> it's ready to send. I'll wait to hear confirmation on whether your
> machine survives for a day or not. Thanks.
>
> --
> Mel Gorman
> SUSE Labs

30 hours uptime I think it's enough for believe that bug was fixed.
I will wait this patch in mainline.

--
Best Regards,
Mike Gavrilov.

