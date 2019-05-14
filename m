Return-Path: <SRS0=IoHm=TO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 497CDC04A6B
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 04:12:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DF4CE208C3
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 04:12:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="hhohANEL"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DF4CE208C3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8810B6B0003; Tue, 14 May 2019 00:12:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 831236B0005; Tue, 14 May 2019 00:12:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 720786B0007; Tue, 14 May 2019 00:12:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f200.google.com (mail-oi1-f200.google.com [209.85.167.200])
	by kanga.kvack.org (Postfix) with ESMTP id 45A296B0003
	for <linux-mm@kvack.org>; Tue, 14 May 2019 00:12:39 -0400 (EDT)
Received: by mail-oi1-f200.google.com with SMTP id f143so1980735oig.13
        for <linux-mm@kvack.org>; Mon, 13 May 2019 21:12:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=y/rQm3oEyoX488IyJ+t/DcdnSheU9nuqxEV2kABn8Po=;
        b=bvY7ikOqvVmJkM+YKAU0Y81CGttGFu6LqfqBJOnq6CNDDO/TNXAlTtvLjMDtCuQBff
         JMdDiZ+X0+X74ZCoTkk4m5p5kwpmAARZsVlcMs5npA7J003OA5jKf6/SSRGzBQXUkLiI
         H+4P7XDmzqmZEWitjADRG9JX8NHP19J/WgrOD0Lgus49CgrucOzmTVlRJL25FZYfXHDD
         rEsCie+fhHQgnSFm+DfaLXVmUrwMv0nQON5mzdbLCaaIYzggiMPImXiMrRolAMEAAfJ1
         l7tKf1t6pnvUWWfI7ZLwTdv9NLj7SOMCCUPIjiufI0IjdV3Te2ko1estymCyjwONwsWp
         tRIw==
X-Gm-Message-State: APjAAAXvhFRog55Gdwn5Z/N4wjadSldlZKTMCLNNmdF3tNV8DGeKGske
	jUio4AOFrSMsfwS0NE9mXE+NfBJY8wB48HHF21wxFgSNZFAtjZT9D6bpkSllwa/uLEh8ZJTGFlM
	n480J3nMS4wJb91XDgTGxvWfdpphf19L/muXOmgJ7WvaR/UENgF9uWhwi9fu2UcDaGQ==
X-Received: by 2002:aca:fc86:: with SMTP id a128mr1654894oii.36.1557807158732;
        Mon, 13 May 2019 21:12:38 -0700 (PDT)
X-Received: by 2002:aca:fc86:: with SMTP id a128mr1654879oii.36.1557807158140;
        Mon, 13 May 2019 21:12:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557807158; cv=none;
        d=google.com; s=arc-20160816;
        b=h/MHgLKsBAetzWQX0eDlnmvrK+voYTWZMFMdPmtC2B7odapaa/RbZCDFIIqITdrv+Y
         4RVSO3vxfYZytTh4KQ9lgAHjpVB6Bpjj1HjdVmg4F5JxdFpcimEZMFYWpZXsBz+mHPKJ
         8+X3VTBn2dfUot1hTq7WjKqy0DdnYoJYm6k6+PZ1NGKVMbuLDfLdOnXkB1cPu7kqjCNj
         2hNCJG6UFwZG6VCBB+uThIV84keqKhmmSvFc5CJ1OfgPCacWMMJm16atcahzu3rY5BwR
         8P4LuBsJZjS6nlr4kutu6VPHh5wT1K6XzFjFWCIVz2mZv+Rm/wphIHJa+n+4xEWENkR+
         GR4w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=y/rQm3oEyoX488IyJ+t/DcdnSheU9nuqxEV2kABn8Po=;
        b=Owil8AWIwJWTLPItOqw7auX3VLS0tlddhNRuIJogWCFlyoa6Fnyi1iUfh51rhoWDbg
         u0Ds7wdhclatvqRw6EuDRqRAlJMfzznV2pVYeP0Y9HcupoXgD346w/qfYkebd+NO/CVe
         cfy/vje718q6uhGO+7y2tKJfA5wZsE0/0iqc6i3N5hTqMrEfArQVosTFdLlwCHm4+AJF
         ZpP4p06XEJgSw2TTsZOsv9EOTIcdob7YTEhAkn8Pjlyfv38SXKaCwyRXP9z4YqdzlGgj
         7oC5VygEnfMgHXpgf0vDBtdiV9JjuQ0N1nzQBuSVD7j2ovafJZ9sjSuVCWnf966wh2uh
         BuDQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=hhohANEL;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f79sor70168oib.125.2019.05.13.21.12.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 13 May 2019 21:12:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=hhohANEL;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=y/rQm3oEyoX488IyJ+t/DcdnSheU9nuqxEV2kABn8Po=;
        b=hhohANELP/S8ZDrcbe5ySnAiD347I3u8fu2KWY8VOIA0JUoHJjU5L08w7enZz49LD1
         /+elYJmVdTy/qm720hDo8dQPJyWir62FRIQgcQnaKINF/zRhlYqf1IkBxMnsWa8oA1Dp
         3GsmnqllWqDf2p4ENWNRbufhty9e1nWx3IM7ZSzjrrSrhr+v4kZMTf9qrrgQ9MUIM1Ka
         zhfGe/anBmZbhvfYhpbG/bcdGv6vEhusZO62Dyv/jjHw7w7/I9qUU+kqo99MDVfTJDBR
         S3ktaDFfBKwcSBTKD2Btr6Q2MhNWgJNgfFVyKHddUs0hrwdhOANW0mJdYoBh0PYgHLVL
         LMuw==
X-Google-Smtp-Source: APXvYqzzfxfOpIdKcIo7DuHfJxoY0QMBgRq8Df8EJpuM7dGb/os63wJ0kQomjiwA4aTBer7zd0AQjOw5WljDWwc9Uk0=
X-Received: by 2002:aca:4208:: with SMTP id p8mr1800747oia.105.1557807157734;
 Mon, 13 May 2019 21:12:37 -0700 (PDT)
MIME-Version: 1.0
References: <20190514025604.9997-1-aneesh.kumar@linux.ibm.com>
 <CAPcyv4iNgFbSq0Hqb+CStRhGWMHfXx7tL3vrDaQ95DcBBY8QCQ@mail.gmail.com> <f99c4f11-a43d-c2d3-ab4f-b7072d090351@linux.ibm.com>
In-Reply-To: <f99c4f11-a43d-c2d3-ab4f-b7072d090351@linux.ibm.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 13 May 2019 21:12:26 -0700
Message-ID: <CAPcyv4gOr8SFbdtBbWhMOU-wdYuMCQ4Jn2SznGRsv6Vku97Xnw@mail.gmail.com>
Subject: Re: [PATCH] mm/nvdimm: Use correct #defines instead of opencoding
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Cc: linux-nvdimm <linux-nvdimm@lists.01.org>, Linux MM <linux-mm@kvack.org>, 
	linuxppc-dev <linuxppc-dev@lists.ozlabs.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, May 13, 2019 at 9:05 PM Aneesh Kumar K.V
<aneesh.kumar@linux.ibm.com> wrote:
>
> On 5/14/19 9:28 AM, Dan Williams wrote:
> > On Mon, May 13, 2019 at 7:56 PM Aneesh Kumar K.V
> > <aneesh.kumar@linux.ibm.com> wrote:
> >>
> >> The nfpn related change is needed to fix the kernel message
> >>
> >> "number of pfns truncated from 2617344 to 163584"
> >>
> >> The change makes sure the nfpns stored in the superblock is right value.
> >>
> >> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
> >> ---
> >>   drivers/nvdimm/pfn_devs.c    | 6 +++---
> >>   drivers/nvdimm/region_devs.c | 8 ++++----
> >>   2 files changed, 7 insertions(+), 7 deletions(-)
> >>
> >> diff --git a/drivers/nvdimm/pfn_devs.c b/drivers/nvdimm/pfn_devs.c
> >> index 347cab166376..6751ff0296ef 100644
> >> --- a/drivers/nvdimm/pfn_devs.c
> >> +++ b/drivers/nvdimm/pfn_devs.c
> >> @@ -777,8 +777,8 @@ static int nd_pfn_init(struct nd_pfn *nd_pfn)
> >>                   * when populating the vmemmap. This *should* be equal to
> >>                   * PMD_SIZE for most architectures.
> >>                   */
> >> -               offset = ALIGN(start + reserve + 64 * npfns,
> >> -                               max(nd_pfn->align, PMD_SIZE)) - start;
> >> +               offset = ALIGN(start + reserve + sizeof(struct page) * npfns,
> >> +                              max(nd_pfn->align, PMD_SIZE)) - start;
> >
> > No, I think we need to record the page-size into the superblock format
> > otherwise this breaks in debug builds where the struct-page size is
> > extended.
> >
> >>          } else if (nd_pfn->mode == PFN_MODE_RAM)
> >>                  offset = ALIGN(start + reserve, nd_pfn->align) - start;
> >>          else
> >> @@ -790,7 +790,7 @@ static int nd_pfn_init(struct nd_pfn *nd_pfn)
> >>                  return -ENXIO;
> >>          }
> >>
> >> -       npfns = (size - offset - start_pad - end_trunc) / SZ_4K;
> >> +       npfns = (size - offset - start_pad - end_trunc) / PAGE_SIZE;
> >
> > Similar comment, if the page size is variable then the superblock
> > needs to explicitly account for it.
> >
>
> PAGE_SIZE is not really variable. What we can run into is the issue you
> mentioned above. The size of struct page can change which means the
> reserved space for keeping vmemmap in device may not be sufficient for
> certain kernel builds.
>
> I was planning to add another patch that fails namespace init if we
> don't have enough space to keep the struct page.
>
> Why do you suggest we need to have PAGE_SIZE as part of pfn superblock?

So that the kernel has a chance to identify cases where the superblock
it is handling was created on a system with different PAGE_SIZE
assumptions.

