Return-Path: <SRS0=i6a/=S4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 53771C43218
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 00:33:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 124DF206C1
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 00:33:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="yxMG00XR"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 124DF206C1
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 743EB6B0007; Thu, 25 Apr 2019 20:33:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6F3866B0008; Thu, 25 Apr 2019 20:33:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5E26D6B000A; Thu, 25 Apr 2019 20:33:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f200.google.com (mail-oi1-f200.google.com [209.85.167.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3475C6B0007
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 20:33:17 -0400 (EDT)
Received: by mail-oi1-f200.google.com with SMTP id d198so719564oih.6
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 17:33:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=husfLeAUYRUpmyxx/IOBfWRF88c+2Bw6W/zLaIXEA5s=;
        b=sVkCVTxdSFKV1UevjihsoWzvQOC4LSTsEFHc2WDArm13Vl60tbkLYMQS61OmlYmt1T
         2ZCuBakuwkzVXcLtesAQDgQ16aRLIvngQ95nQ92sXcNe5miYm/aHai1PhWxZW0+SRImq
         vyaHoK6gztMI6/OqHBztH+upBYW7S41Rb7jtYGQ3oShlyMvpJ7G8kJZRq1/IZjQzwWcc
         HRwtk6Sus5eQZpiA4FQnikRUSbS15CQzluyFnXML9L2yvfCgE/XmI1F4o/dXw2Ic1xnk
         zIgOD+K6Czsgopl4DxyNfSdFTS/5ne4YdpYvOgsDNLAv67UFn3ZnDGK+nb1RIfMtOWfk
         Mb+w==
X-Gm-Message-State: APjAAAWnC6XxD5Q2Xq0AyP58WHFnBCxZ0VyVa6jEUg1ROAK9S406t7ad
	fq6Ikz4g30RtIU6UEMMESdrgnsfhz3DyBu4naFMacgw1fZmDVuBYgprW6LFBmEMUpSxDDTYjoOY
	pQQT1Er971fo6rNdwQIV7Sy8CNv3wugt+m4xqCEszKCRTvbGu/YJq8+EOu7KtMsmouQ==
X-Received: by 2002:a9d:841:: with SMTP id 59mr24317119oty.15.1556238796806;
        Thu, 25 Apr 2019 17:33:16 -0700 (PDT)
X-Received: by 2002:a9d:841:: with SMTP id 59mr24317099oty.15.1556238796105;
        Thu, 25 Apr 2019 17:33:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556238796; cv=none;
        d=google.com; s=arc-20160816;
        b=CjxDCB1AdARZ6KLMTWFDDCIos5e9kLLpdB0I8piSffsX78mh6854/eKCeRAgzVV7IY
         phXJdzx7Jl9FXnefSDStntRnv+pG072t/PMpK178LDGKexDAUnssDQpT3eYD3yQjolRt
         56Ofs666fjVSWbYx9hqoaXUE5XyuHD7GGuOrs+Fr+VxuskCfbBWG7/dXXikNzcQAhNEq
         jk/vIie2tMdr2ZsyQiLo+VS5edd2XgC4HcDGPH1zsffdP3oqu537snb5fj7hBZth7fX0
         c6E9W0FxW358o5nelB+MwftDeGFeLCUwtg/5M//4flFWC40ke7E0vFLPWlDO6RZ0zqm8
         xuTg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=husfLeAUYRUpmyxx/IOBfWRF88c+2Bw6W/zLaIXEA5s=;
        b=UQS3uKczzYYFsI7HQYs61cJsUFHM1PzzJb32fxOf8cUghtfX/wXcqBUb8JFwEHdu6a
         AHosBR5VlDGVsmt4Z15IlRf3cF/iJy14UqhvDder60x0K5qrqUxdZku4Tl5e8Ez364se
         tIWc6ZupSqvjQaxnnRkd+b51KsnFy9rIO8QB2XrjnG4XZ7xJSbWfYCWPNT8Bjrr9/5qz
         3S6kSjuIBVnmc6+DGtSLr0wWNfLrco5+oaxjmWz+SlTNvin0DKGNCbZn5nKr9PxUcipf
         KusUtdEDd5xDIN+WkEh1v57RLFIXMWdMr/9OBda2xjgnvkPCR4cV63LM1og/uXhE21Cc
         2XvA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=yxMG00XR;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c127sor2747358oif.94.2019.04.25.17.33.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 25 Apr 2019 17:33:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=yxMG00XR;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=husfLeAUYRUpmyxx/IOBfWRF88c+2Bw6W/zLaIXEA5s=;
        b=yxMG00XRw8W8gPUsSvOidLXP7LF3BedxzpWzi1PTS4ri+eYU8v80sONYvSsjtJM2GW
         wFTOb6JqEVuH7DzSurkgHYEdEr3Q5zeBmpl84g+jca74K1GKrF7Xor93CJEIvFdldwmq
         En26Ux164dU7E+aT12PHHdcVIAIvrnsPs17DGqKrKxLJbHi8/eWFI24goDhTUHKiGjmm
         uJr1VWdSaFqAnpl3ZmXcYvoGsODlF/zfcC/FgybwVBvOqVGSOyFep/PP9tb1hDt/wcgX
         ZtyPCD8w+mPd1oiSGTqPEpbwpi4lxpVcmZZ7m6genkJjL6QG8Qx2OhHahDQqhdSOK6jn
         gwqA==
X-Google-Smtp-Source: APXvYqw1+ZJvz+ZxUUyq0eqW43gC2WMrQ8d3BXIt3dl9j88+0wZGDtOHhjZNKsuCANGX8D3bycXuRTYIAelS2XRy3HE=
X-Received: by 2002:aca:e64f:: with SMTP id d76mr5550827oih.105.1556238795714;
 Thu, 25 Apr 2019 17:33:15 -0700 (PDT)
MIME-Version: 1.0
References: <20190402115125.18803-1-aneesh.kumar@linux.ibm.com>
 <CAPcyv4hzRj5yxVJ5-7AZgzzBxEL02xf2xwhDv-U9_osWFm9kiA@mail.gmail.com>
 <20190424173833.GE19031@bombadil.infradead.org> <CAPcyv4gLGUa69svQnwjvruALZ0ChqUJZHQJ1Mt_Cjr1Jh_6vbQ@mail.gmail.com>
 <20190425073149.GA21215@quack2.suse.cz>
In-Reply-To: <20190425073149.GA21215@quack2.suse.cz>
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 25 Apr 2019 17:33:04 -0700
Message-ID: <CAPcyv4iYMP4NWxa08zTdRxtc4UcbFFOCwbMZijB0bc2WcawggQ@mail.gmail.com>
Subject: Re: [PATCH v2] mm: Fix modifying of page protection by insert_pfn_pmd()
To: Jan Kara <jack@suse.cz>
Cc: Matthew Wilcox <willy@infradead.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, 
	Andrew Morton <akpm@linux-foundation.org>, linux-nvdimm <linux-nvdimm@lists.01.org>, 
	Linux MM <linux-mm@kvack.org>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, 
	stable <stable@vger.kernel.org>, Chandan Rajendra <chandan@linux.ibm.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 25, 2019 at 12:32 AM Jan Kara <jack@suse.cz> wrote:
>
> On Wed 24-04-19 11:13:48, Dan Williams wrote:
> > On Wed, Apr 24, 2019 at 10:38 AM Matthew Wilcox <willy@infradead.org> wrote:
> > >
> > > On Wed, Apr 24, 2019 at 10:13:15AM -0700, Dan Williams wrote:
> > > > I think unaligned addresses have always been passed to
> > > > vmf_insert_pfn_pmd(), but nothing cared until this patch. I *think*
> > > > the only change needed is the following, thoughts?
> > > >
> > > > diff --git a/fs/dax.c b/fs/dax.c
> > > > index ca0671d55aa6..82aee9a87efa 100644
> > > > --- a/fs/dax.c
> > > > +++ b/fs/dax.c
> > > > @@ -1560,7 +1560,7 @@ static vm_fault_t dax_iomap_pmd_fault(struct
> > > > vm_fault *vmf, pfn_t *pfnp,
> > > >                 }
> > > >
> > > >                 trace_dax_pmd_insert_mapping(inode, vmf, PMD_SIZE, pfn, entry);
> > > > -               result = vmf_insert_pfn_pmd(vma, vmf->address, vmf->pmd, pfn,
> > > > +               result = vmf_insert_pfn_pmd(vma, pmd_addr, vmf->pmd, pfn,
> > > >                                             write);
> > >
> > > We also call vmf_insert_pfn_pmd() in dax_insert_pfn_mkwrite() -- does
> > > that need to change too?
> >
> > It wasn't clear to me that it was a problem. I think that one already
> > happens to be pmd-aligned.
>
> Why would it need to be? The address is taken from vmf->address and that's
> set up in __handle_mm_fault() like .address = address & PAGE_MASK. So I
> don't see anything forcing PMD alignment of the virtual address...

True. So now I'm wondering if the masking should be done internal to
the routine. Given it's prefixed vmf_ it seems to imply the api is
prepared to take raw 'struct vm_fault' parameters. I think I'll go
that route unless someone sees a reason to require the caller to
handle this responsibility.

