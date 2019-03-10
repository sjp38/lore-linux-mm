Return-Path: <SRS0=tu4S=RN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ED6C6C43381
	for <linux-mm@archiver.kernel.org>; Sun, 10 Mar 2019 23:54:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 558F1207E0
	for <linux-mm@archiver.kernel.org>; Sun, 10 Mar 2019 23:54:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="lMsDbSqu"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 558F1207E0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B55EC8E0003; Sun, 10 Mar 2019 19:54:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B0FD88E0002; Sun, 10 Mar 2019 19:54:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9CF8C8E0003; Sun, 10 Mar 2019 19:54:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	by kanga.kvack.org (Postfix) with ESMTP id 683948E0002
	for <linux-mm@kvack.org>; Sun, 10 Mar 2019 19:54:44 -0400 (EDT)
Received: by mail-oi1-f197.google.com with SMTP id w130so1604850oiw.19
        for <linux-mm@kvack.org>; Sun, 10 Mar 2019 16:54:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=yoSe6Z/a+RRQ6U0Ns6hRLVWf24WoPrnlmUg/LWRdcts=;
        b=Mm0WHcRCj20F8CvPb7fxUaECy2d0iDqGaqN610LocLNsMnKyHJadiMvZlO6iPfww5D
         VJRo4XstZ6DPbDOI7tQVrHvvJgR1auybKufHU3bTUMfFKY3TZF/jDEJJ/zhV548TXGg9
         Aqxkv3SWsSperdP7d+t8OA7jP1ZkLCXB7o3bQUmwCpirSxz2DnqWQyd2biphmwx0uBEv
         rXi0e2d6afv1fbkYJzRFCOSfxImopVvRgVuHC0bk714yqpUhvNEWv0r3Lnbq59u8vfI4
         pvf+hedKpyizqvhRqiM3I0UPnhSmuc6Nc4SeJjNwts+tR5kV/nD3/hui0CMHvKabrQBZ
         As8w==
X-Gm-Message-State: APjAAAVHON0GPeJBBXeaGSUxZ6cgY4CB1mud4wvYhUiDMXnSKDEfG8+i
	fl+ZuKAsbXlSvJ6gAjdu1aUBD5/bmflGnWCEYRsiGIMZVDD+bZB1hufmNN+FxkKLddqzxxybsyt
	+/gsPmgWTIU0nK3ox2aJuGtKoEWThKGtxPak3kd59g1dU+hJhHEYq7i+nJnRvKEgNrMM3/gPMWt
	ibk9yKfESPSIac3l0amLbjf23V0MRCA99LjFcwz4KEofTgWleVhv8mqMc8C5qopZ/11Q9VvUlOj
	r0Wa7JZ4YBINxpP9bI75w17Oh6yuM2+KIdxiOHF+7pfHbfE5L2gi8+mp+OiWAdONE4OIdaIoWRr
	ia8Fsi2oXYaZhbzPThqAuk2bexfJkWgicw4EJMbZp2cB2OLTeyyRFXNfmJh0qUmf8BrT49FJAyg
	L
X-Received: by 2002:aca:5dc1:: with SMTP id r184mr15224037oib.127.1552262084051;
        Sun, 10 Mar 2019 16:54:44 -0700 (PDT)
X-Received: by 2002:aca:5dc1:: with SMTP id r184mr15224017oib.127.1552262083219;
        Sun, 10 Mar 2019 16:54:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552262083; cv=none;
        d=google.com; s=arc-20160816;
        b=clkOY+gKwLaA23SXkQJ3x3nie+w9GTgvFRUmrmcU1ys3PBHeppD2/rxGjLF8HBQm3+
         Qh47+xM8CLsbSzcxpm565QjX19Zn+kF2QCDBA1VL0vuCzHrJzpinHIgtGPD8Oh3zy3Y0
         xXvAX5s8UX4wDYzNF0XUAPzdkPmMgYjlZrS1xC7va0ZTWVi58+Yen/7oAcTcAlLOzB3F
         BcQoJXv5mNtRjwr6PUVK6POHlTTjOtfhNEHGrVnmniJn1XFLKZk2rDd6ZG8J5wZvDkP5
         tlMV8Zmo4z0coJS69be80hJTmZ9UmJTzLYqQ3eLkjlod/ze2CHPlLvd7XjDXNoYt/PIx
         eoUA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=yoSe6Z/a+RRQ6U0Ns6hRLVWf24WoPrnlmUg/LWRdcts=;
        b=GwNyK9vKgG0QGK46K9x9emszcixrwoU/PVVVSqv+nEhCkFpEgYF2PGdpvlL69A0bRD
         ojocSzcg/L/cCTSSRDSM8MJm/NMf+OxgaGHOa7b8cIIPSbb9EOWJEgMnpL191sSzSCF3
         fQ+OjYJKLprf00azECjbl2H7sD1MQww50Z48G8q//CqL2N3nmrTU0UJTfrjNgNbBE4v+
         ua31piF3EhM/mTvqC91loMkmVyZDNHH35usdKeLj2VQsS2+W1FEV2dlT6f6T6iuSjRiK
         ea0s5hkcS3PMGXBrt88gqFsHx4HrTIns9zgzTrIM7W9qQCoPZ2UKjBFkZRjMQPfSo90F
         M2hw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=lMsDbSqu;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e68sor1806564oih.92.2019.03.10.16.54.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 10 Mar 2019 16:54:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=lMsDbSqu;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=yoSe6Z/a+RRQ6U0Ns6hRLVWf24WoPrnlmUg/LWRdcts=;
        b=lMsDbSquzK+wxeInWsUe1ndqpM9OM9/OB7dMQrMvZ9097++6Ct+wpXm0dqgb7ZjMyL
         mnqx0XfIpkzoj3r/+wUm5jvJX0lYV3hfaJd0jcSPb/keDEt4peF0a8NgAbV3h10yVcgy
         faZdoQg4zPIIaqHJQ7v3Vovrjqd2qjwZ2ipGKqFU1ljVegDQ4Z2ncr9m/1TiR1iCaFM4
         pMLwGTJI8ZEw/OgebS+k25P3TqVXeRLU4xX8OL7LKxMR/HWuJCu/ce/MOS1+ajJ+f4cf
         HaYNH/45TwyQGagvuLDV8rT4jbb2uUs7OpsJs/8eXeAAJvkFg0IZ55sa2HhDLJiHcOHa
         YDVw==
X-Google-Smtp-Source: APXvYqwFn91XEpww+BFQB83/xV8SzljK9yYHpQHlAWoikQE2Le/KJgxWPDHFRksbZv/CbhUUridG+auz58mLWbvTxrI=
X-Received: by 2002:aca:fc06:: with SMTP id a6mr15527931oii.0.1552262081496;
 Sun, 10 Mar 2019 16:54:41 -0700 (PDT)
MIME-Version: 1.0
References: <CAPcyv4he0q_FdqqiXarp0bXjcggs8QZX8Od560E2iFxzCU3Qag@mail.gmail.com>
 <CAHk-=wjvmwD_0=CRQtNs5RBh8oJwrriXDn+XNWOU=wk8OyQ5ew@mail.gmail.com>
In-Reply-To: <CAHk-=wjvmwD_0=CRQtNs5RBh8oJwrriXDn+XNWOU=wk8OyQ5ew@mail.gmail.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Sun, 10 Mar 2019 16:54:29 -0700
Message-ID: <CAPcyv4hafLUr2rKdLG+3SHXyWaa0d_2g8AKKZRf2mKPW+3DUSA@mail.gmail.com>
Subject: Re: [GIT PULL] device-dax for 5.1: PMEM as RAM
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-nvdimm <linux-nvdimm@lists.01.org>, 
	Linux MM <linux-mm@kvack.org>, Dave Hansen <dave.hansen@intel.com>, 
	"Luck, Tony" <tony.luck@intel.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

[ add Tony, who has wrestled with how to detect rep; movs recover-ability ]

On Sun, Mar 10, 2019 at 1:02 PM Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
> On Sun, Mar 10, 2019 at 12:54 PM Dan Williams <dan.j.williams@intel.com> wrote:
> >
> > Hi Linus, please pull from:
> >
> >   git://git.kernel.org/pub/scm/linux/kernel/git/nvdimm/nvdimm
> > tags/devdax-for-5.1
> >
> > ...to receive new device-dax infrastructure to allow persistent memory
> > and other "reserved" / performance differentiated memories, to be
> > assigned to the core-mm as "System RAM".
>
> I'm not pulling this until I get official Intel clarification on the
> whole "pmem vs rep movs vs machine check" behavior.
>
> Last I saw it was deadly and didn't work, and we have a whole "mc-safe
> memory copy" thing for it in the kernel because repeat string
> instructions didn't work correctly on nvmem.
>
> No way am I exposing any users to something like that.
>
> We need a way to know when it works and when it doesn't, and only do
> it when it's safe.

Unfortunately this particular b0rkage is not constrained to nvmem.
I.e. there's nothing specific about nvmem requiring mc-safe memory
copy, it's a cpu problem consuming any poison regardless of
source-media-type with "rep; movs".

