Return-Path: <SRS0=SJ39=PZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 170CAC43387
	for <linux-mm@archiver.kernel.org>; Thu, 17 Jan 2019 16:51:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BF5AF205C9
	for <linux-mm@archiver.kernel.org>; Thu, 17 Jan 2019 16:51:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="XDmMmTRI"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BF5AF205C9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5AA358E0008; Thu, 17 Jan 2019 11:51:10 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 557D78E0002; Thu, 17 Jan 2019 11:51:10 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 45AA58E0008; Thu, 17 Jan 2019 11:51:10 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f200.google.com (mail-oi1-f200.google.com [209.85.167.200])
	by kanga.kvack.org (Postfix) with ESMTP id 167A08E0002
	for <linux-mm@kvack.org>; Thu, 17 Jan 2019 11:51:10 -0500 (EST)
Received: by mail-oi1-f200.google.com with SMTP id d7so3623639oif.5
        for <linux-mm@kvack.org>; Thu, 17 Jan 2019 08:51:10 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=eeqNNNSjGfrb/VOAvSUOR6b42db+Jqg9XHBp+kCWRWk=;
        b=VrOdZnL7IZ2NYf3FQtdQapwE/6V+jRt1AJM/bVuh8Ow4G7bisV5SDAARHlJy+YZOvq
         RaUBJuUT1rAh+NKFKXM7mwNPhBtitS9usLFCw7Y8yIqwMVT6vUxCcOHAKY00Xygx3CYk
         3eeC1Q1FJR8+YrixVqYpVDYKYYhsvYDfEPSBj1xnyYeEoHeQloN9f9d5etZ3uzP+A0nk
         s3B43vUQROt01wOgSGWHQrwUyZ0GwWDNqrNtXb66oPPzAbOsrbkycKrWMZ4RZG4yL0Fq
         sYdsLSCIkUdgdLveCnxqPpfSAAyjVDrIati08Vl5PCHrE5J+NwJWXfnWF7+2QuPCzB0P
         rlYg==
X-Gm-Message-State: AJcUukczwn3isGOfSfNzDyIw8dLnOMQnILSF069FWEWmXGcH1IoEqtZI
	KExeNnPTsymCRIjkrrJd9FvfKZ7piF4bbzSxItuGFqFIUW5f/3Z4hxYkSs5lsBk7wZZ+QSzSA5F
	EITSl6yqVjqU0k7OqnwkwVYTFWioPbzWMV8B3TJTB8XBGCNlHdq1KXJlDfoluKdn8YSv4bMfAJS
	LlGYvB6/myPg233D5RTvUJndNncrSV7AmP7Wr+VBWf1a8Z6a1DuMun3m9iSqYUEy9h5B2OSpTYH
	3el7BcrD0BW0X0G3id5occ4fblhap/q+sW+NGpvJIH2c8K/+xShZpyQR055KW4CapGT8lyc4DvX
	4j1sqBIXOQOGK/IUWsZvQT8cydXc2M7YY5COiYTouFpKK2zVCB0f9i3gJ15t1sQRe5LMwwzy/ry
	r
X-Received: by 2002:a9d:6191:: with SMTP id g17mr9474511otk.56.1547743869617;
        Thu, 17 Jan 2019 08:51:09 -0800 (PST)
X-Received: by 2002:a9d:6191:: with SMTP id g17mr9474481otk.56.1547743868783;
        Thu, 17 Jan 2019 08:51:08 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547743868; cv=none;
        d=google.com; s=arc-20160816;
        b=tuYKd7PFSj1q+jfF5n6pe32f9nkWmGJkT/NIf08wF8yhJlyDXhO1NaFgxtj0m0JOal
         nB3fFLpHbIgbwjUWT3+E2O3+lzELQfSh0mIbvCGDVrjLupTxOGE4gIXPX1xmPBB/+bDi
         wVcoQiXqSYQ33O67sps0teMp1GNOWmzRLhHCqt2lp4VQqjkvZlbkpB2FyAqx/zPREwjG
         YzoXirRmN7i1Lwt5+E92RbdcH37H+uLM6osIMd2SBbtwI3DRPlbpcAXwfe0UoY8x/lBH
         ZLhtZqTstW4He0uW7BlUo2cX79hU5i3mXLNGgsKp4FmTDF5Qrfl43RblV0PrkWPIPEUg
         kT5g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=eeqNNNSjGfrb/VOAvSUOR6b42db+Jqg9XHBp+kCWRWk=;
        b=WO/EzcNQwBYWznT838a1049/XcYVRjZBFm20ZeCJon9cgDtByWwxBTdh86IOCe4Z5r
         eeDZrPaO1oRoZXFN5RWFPzYMS6l1yOesyhJfVu4UC7c+ra/iT/OY5ezXY85VJYyTbYLP
         R+T/nu8MubwJKorw9AD/h79tyYNTctueSYWAQ0k09/slOFU1IUV5RpOuTmvaAM+jSjEh
         bfokUFvafukJpTDEPOmlZmfiHPtgJ+n8yuOJ/auZTYUmbw/zdtQX8Jq/j7TlFoIch3Ts
         qpFP4+6n7WjvCSti2nqnt930JlwAA3RIKcoLI4CeHCbdAAlfnpGkrpH104ssMn/E1+4Z
         lk8g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=XDmMmTRI;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z79sor944928oia.97.2019.01.17.08.51.08
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 17 Jan 2019 08:51:08 -0800 (PST)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=XDmMmTRI;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=eeqNNNSjGfrb/VOAvSUOR6b42db+Jqg9XHBp+kCWRWk=;
        b=XDmMmTRIBB5vKWP6TrUwQCEHemONZ8D/s0D83Xpx/UVBf9cANGrt0DX50SHJ9AGymu
         HGb+gf7w0IPrP41Y1j69q32oQnM1pvz89kwP3E/1/8xqNps7J5ibJPJ1dEso3eGhxQSD
         uZmCIpOfTK8l9dfeWt+Lryevm4UKRmUTz7h97P7SlCQD6vinUE2fUhhgVng/6w739Zfp
         Va3bxvf1ta0DfOAnb/GD6tnWwXaj8JFYUtcalUHgaeUCbhZmoeHYX8O7+zSRPw3lHhY4
         WJXtIfp+GcvstcMA8ht+i0wW4eTQKWaDy3h/WWczw6uMXUP4+iOlnLScTvXwjiM6b/lF
         64ZA==
X-Google-Smtp-Source: ALg8bN5MbqsOaTEFby+rDYnDy2cAuiqqwg7op/akn51pGzRtGj2Cio9wpi3j/48ESGJDtvGyDnPXPzS9B6yq0EDd9sg=
X-Received: by 2002:aca:d905:: with SMTP id q5mr5249519oig.0.1547743868290;
 Thu, 17 Jan 2019 08:51:08 -0800 (PST)
MIME-Version: 1.0
References: <20190116181859.D1504459@viggo.jf.intel.com> <x49sgxr9rjd.fsf@segfault.boston.devel.redhat.com>
In-Reply-To: <x49sgxr9rjd.fsf@segfault.boston.devel.redhat.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 17 Jan 2019 08:50:57 -0800
Message-ID:
 <CAPcyv4je0XXWjej+xM4+gidryQH=p_sevD=eL6w8f-vDQzMm3w@mail.gmail.com>
Subject: Re: [PATCH 0/4] Allow persistent memory to be used like normal RAM
To: Jeff Moyer <jmoyer@redhat.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, Tom Lendacky <thomas.lendacky@amd.com>, 
	Fengguang Wu <fengguang.wu@intel.com>, Dave Hansen <dave@sr71.net>, 
	linux-nvdimm <linux-nvdimm@lists.01.org>, Takashi Iwai <tiwai@suse.de>, 
	Ross Zwisler <zwisler@kernel.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, 
	Michal Hocko <mhocko@suse.com>, Yaowei Bai <baiyaowei@cmss.chinamobile.com>, 
	"Huang, Ying" <ying.huang@intel.com>, Bjorn Helgaas <bhelgaas@google.com>, 
	Andrew Morton <akpm@linux-foundation.org>, Borislav Petkov <bp@suse.de>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190117165057.krLBtRleAucfc0Upgtg04W4MH0eeaE9pCVzREYxy1kQ@z>

On Thu, Jan 17, 2019 at 8:29 AM Jeff Moyer <jmoyer@redhat.com> wrote:
>
> Dave Hansen <dave.hansen@linux.intel.com> writes:
>
> > Persistent memory is cool.  But, currently, you have to rewrite
> > your applications to use it.  Wouldn't it be cool if you could
> > just have it show up in your system like normal RAM and get to
> > it like a slow blob of memory?  Well... have I got the patch
> > series for you!
>
> So, isn't that what memory mode is for?
>   https://itpeernetwork.intel.com/intel-optane-dc-persistent-memory-operating-modes/

That's a hardware cache that privately manages DRAM in front of PMEM.
It benefits from some help from software [1].

> Why do we need this code in the kernel?

This goes further and enables software managed allocation decisions
with the full DRAM + PMEM address space.

[1]: https://lore.kernel.org/lkml/154767945660.1983228.12167020940431682725.stgit@dwillia2-desk3.amr.corp.intel.com/

