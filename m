Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 758D8C282D7
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 00:08:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 170E7217FA
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 00:08:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 170E7217FA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6A52B8E019B; Mon, 11 Feb 2019 19:08:23 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 67A1D8E0186; Mon, 11 Feb 2019 19:08:23 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 568FE8E019B; Mon, 11 Feb 2019 19:08:23 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 147ED8E0186
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 19:08:23 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id f5so605184pgh.14
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 16:08:23 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=YlTDWtdaa025MXisQD85MzdwviN2qwN1NjFiWmBvg0U=;
        b=NEz5BmC5a7t1YJk+uMLz/IJ0uTDOkbIGGlMQmnTuPQ1f5K+RzgryyrYucVdHT2qC0B
         VpAT6OEsD4gd/TWtXG3hgyW8e9zZk932W7I697CHp6hracaje+GGP62aFTrZsHt5LUMI
         ro52urniZ47rVZgcWZBM9MKnvp4dD6wJ6+wLo4gFY0AhiSmlkJibNBSTTzr79A6xHHO7
         h4ii8HeExpyvYNsx5CaFpXzJEFMQ/Y96TFleumlQu/6NTFmID181++WSWt8c5s9HOu4h
         zGou03x19f6N7D9nbOgbQ23hUDKqImurS5mqD6u+zm9GoctT2FLijb/YnEaJnZ73T3Ni
         Df7w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAuZTFluRB4TCSV1sF23na9eXsu0+mMh1GxL/ajD/ZEJpcjzn9lrk
	Htdhxu7W34HDFU1rwat9S7Sm7RevDH9PrA3hyKNSyJTDOm+dxeUFoL36hY4i0nuq02Jvjdy9oGD
	9Gy7g2rtrLGEvaTeH2ZBhFd6gIOZVjINyQeYRXMb8c1ZHAPGjPfDeaFqGrBZpkpr1VA==
X-Received: by 2002:a63:cd11:: with SMTP id i17mr866086pgg.345.1549930102748;
        Mon, 11 Feb 2019 16:08:22 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYyI6wxCWCU1IAp+JVrairVxd3snxuX6o3jFsJEmz8U8bk/uc4sjdFcZrROlmVSpT+zcika
X-Received: by 2002:a63:cd11:: with SMTP id i17mr866033pgg.345.1549930101987;
        Mon, 11 Feb 2019 16:08:21 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549930101; cv=none;
        d=google.com; s=arc-20160816;
        b=s4eRqenb7wGZ73Xf+0N7V9FSI2zhlEiE+s9KBJ6Jn1SHTybAXLsbkUuIMBVrfsSHIS
         PgEPeUQPEPgk7jAG9Yho462QfAT3ggoRrGRXBW3WTSrwQQvrz40l+EEP3fTyF3ZqA3uN
         3+oxTecmEh18YqQmhNgjBwmS4c2OaVJd5RRz/vFumYOJslOfEhbQEymsM7LhExB4aOu4
         wEP0GHeUlRB5sGFNsOdXT/VF36/6+rAvRKI5c66KjoR2Wl++StntLN+1rFVsj8DDJYrQ
         v/F4th4jgFOPYdpoZ+8LSn/+lX9rsbs0qXjRHaDpiWX3FWaBqKYfqIJKjnbS//PKvk2y
         Q3Fw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=YlTDWtdaa025MXisQD85MzdwviN2qwN1NjFiWmBvg0U=;
        b=ktUuBE0yLtxmm1uvYIZebXVtcfTCGvEnh6+jAJaaJrBa7GrEL9h0zHm8yppV7pLZnB
         gxZF0editz2v8c3czfh0q6C5mFIniFQ6c6PPtiybARqZho9tc1d/NRCtEDb8psoNtdVP
         hOBC+jMLrbEEoFBLDhTlWEfo8k8rcEP+zSoDYmtBjWG+lB2TcRTub+ngpWaVubmL1dn2
         Me7oTf7R60vTABFvgvHZfxzKUdFBzpW74ZTPzU9LKNeGly+nI8SjQ/TWfNiZFxEG0MaP
         L1kI3FgZQUATaogIvZzFE7kv6ab1za8IGzUDpo7vE9EKnYpwJNj2fwvS7CDhm6WZ9dOX
         LGqw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id k18si2410637pfj.46.2019.02.11.16.08.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 16:08:21 -0800 (PST)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.100 as permitted sender) client-ip=134.134.136.100;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNSCANNABLE
X-Amp-File-Uploaded: False
Received: from fmsmga008.fm.intel.com ([10.253.24.58])
  by orsmga105.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 11 Feb 2019 16:08:21 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,360,1544515200"; 
   d="scan'208";a="123724719"
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by fmsmga008.fm.intel.com with ESMTP; 11 Feb 2019 16:08:21 -0800
Date: Mon, 11 Feb 2019 16:08:10 -0800
From: Ira Weiny <ira.weiny@intel.com>
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Dan Williams <dan.j.williams@intel.com>,
	John Hubbard <jhubbard@nvidia.com>,
	linux-rdma <linux-rdma@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Linux MM <linux-mm@kvack.org>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Davidlohr Bueso <dave@stgolabs.net>,
	Netdev <netdev@vger.kernel.org>,
	Mike Marciniszyn <mike.marciniszyn@intel.com>,
	Dennis Dalessandro <dennis.dalessandro@intel.com>,
	Doug Ledford <dledford@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCH 2/3] mm/gup: Introduce get_user_pages_fast_longterm()
Message-ID: <20190212000810.GA24207@iweiny-DESK2.sc.intel.com>
References: <20190211201643.7599-1-ira.weiny@intel.com>
 <20190211201643.7599-3-ira.weiny@intel.com>
 <20190211203916.GA2771@ziepe.ca>
 <bcc03ee1-4c42-48c3-bc67-942c0f04875e@nvidia.com>
 <20190211212652.GA7790@iweiny-DESK2.sc.intel.com>
 <fc9c880b-24f8-7063-6094-00175bc27f7d@nvidia.com>
 <20190211215238.GA23825@iweiny-DESK2.sc.intel.com>
 <20190211220658.GH24692@ziepe.ca>
 <CAPcyv4htDHmH7PVm_=HOWwRKtpcKTPSjrHPLqhwp2vhBUWL4-w@mail.gmail.com>
 <20190211232510.GP24692@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190211232510.GP24692@ziepe.ca>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 11, 2019 at 04:25:10PM -0700, Jason Gunthorpe wrote:
> On Mon, Feb 11, 2019 at 02:55:10PM -0800, Dan Williams wrote:
> 
> > > I also wonder if someone should think about making fast into a flag
> > > too..
> > >
> > > But I'm not sure when fast should be used vs when it shouldn't :(
> > 
> > Effectively fast should always be used just in case the user cares
> > about performance. It's just that it may fail and need to fall back to
> > requiring the vma.
> 
> But the fall back / slow path is hidden inside the API, so when should
> the caller care? 
> 
> ie when should the caller care to use gup_fast vs gup_unlocked? (the
> comments say they are the same, but this seems to be a mistake)
> 
> Based on some of the comments in the code it looks like this API is
> trying to convert itself into:
> 
> long get_user_pages_locked(struct task_struct *tsk, struct mm_struct *mm,
>                            unsigned long start, unsigned long nr_pages,
> 			   unsigned int gup_flags, struct page **pages,
> 			   struct vm_area_struct **vmas, bool *locked)
> 
> long get_user_pages_unlocked(struct task_struct *tsk, struct mm_struct *mm,
>                              unsigned long start, unsigned long nr_pages,
> 			     unsigned int gup_flags, struct page **pages)
> 
> (and maybe a FOLL_FAST if there is some reason we have _fast and
> _unlocked)
> 
> The reason I ask, is that if there is no reason for fast vs unlocked
> then maybe Ira should convert HFI to use gup_unlocked and move the
> 'fast' code into unlocked?
> 
> ie move incrementally closer to the desired end-state here.

If the pages are not in the page tables then fast is probably going to be
slightly slower because it will have to fall back after walking the tables and
finding something missing.

For PSM2 (MPI) applications are performance improvement was probably because
the memory in question was in the page tables and very much in use.

Ira

> 
> Jason

