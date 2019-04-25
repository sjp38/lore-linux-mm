Return-Path: <SRS0=RcsE=S3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0FFA1C10F03
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 07:32:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A9F02217FA
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 07:32:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A9F02217FA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F26176B0005; Thu, 25 Apr 2019 03:32:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EFC036B0006; Thu, 25 Apr 2019 03:32:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E12196B0007; Thu, 25 Apr 2019 03:32:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8BD136B0005
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 03:32:25 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id j3so11190892edb.14
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 00:32:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=BWy7dkVN1mFmVbP72FdnEMwROG1g6t7h+4pXn95ko0o=;
        b=OY6OJlXe29zwf3PEKi4L36Qpy46wJmj1vPF2C6gJjDoACJRJz8pRSY/nC+PwhB66wC
         XN5EdQ4SSxbfDNMS8rV9IhWR0q8y6xevGWflh4rLboQdO8e7CW9CRvbMUeHUonkHnTIq
         OCtXgv29x1fw/UTUux+rrFGL+WUbhk3LQNBZ5dTSKAoIyA7KfYy4JK2rH/bfMmNW/6HS
         oBay1HjQvyoReLnRIQ38Mu17VS4KpihISGYeQD3Wqyyaj44kv+9K3u6frSmSDKoYESrx
         16JM8A0va//h+chZ3XcThE85Bwzct/hSwN9HHZbr+GpX5MvjkOOOVgvHOlYtx1Tb7PeC
         zfQQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Gm-Message-State: APjAAAXWeeZwjdlxkuw8hQKqAUxfvgGtHhp+FtDnG8ZZRFZbCMN3D4eD
	23ohY+WzcoFKQqp5gjMYpNPcx0OHbmJLU8FtQcAnYmrGCTZYBOPTHBJkTYCmWrahbkKcV0rgDKT
	Ihx8LNKF40pbrWh2k9ypXSi6MtOHNq1soLSz34nF7Ni7IIB7mSyU20N03fLlCNKQN2g==
X-Received: by 2002:a17:906:4ec6:: with SMTP id i6mr16227319ejv.92.1556177514070;
        Thu, 25 Apr 2019 00:31:54 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzjsit7FssbAooKpCcKAf1fYWnKmaTyLTutTHr4RcxxJY8wcSl7+nsjv+m9KSdEQVIHOVnW
X-Received: by 2002:a17:906:4ec6:: with SMTP id i6mr16227283ejv.92.1556177513044;
        Thu, 25 Apr 2019 00:31:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556177513; cv=none;
        d=google.com; s=arc-20160816;
        b=IBMjeJII0CGw0fl/DH/OuGQUBJGBab9eUoj6EYi5aSHxxQH9gKpZcRnCPQ7ZtyNCk+
         1QSAnS0PWs2E6+9ld+pWETzXeuNm0d1xs6F7w92QBlMy+P1GYbe5EoedAo07aOrTeFAy
         txp2KBKla2LvNiq/BG4fIaq0oanb7i5Ei1gqplIQova5ZFDrxRANU693ZeDQ+Eg8d/uT
         0OvlxH2ctaayETqWOPLYbUQhg67K1neBC9Qr668duv9V2EspMjzXOhHpnxDSjZdOkIS1
         /q0IW/FIapyvniaaHdNRhw9c4ZQC52k129Xj1HKsMnpIaiXs4Kk+Lm+1OFVI63r0P6Ej
         kiTw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=BWy7dkVN1mFmVbP72FdnEMwROG1g6t7h+4pXn95ko0o=;
        b=UORf0v6I33T9D71GQGR/FCOJgKCCilKQalrbLx0JrwdcDmaypGDmO6NbOguh8mSiFD
         XR8/dzc3tkFsH9i8dsvzsMrVrTItpaPub4hLPNbCA3rKB2jcJoncgD84w0K+RmrMjDSm
         sqdkboz/7xRUxj4zr+96x6cpNmRvySQa/pIUoxqeMSajEq+uyE59Ed9Wg6MiTbJNx/XV
         ZziUpZ4Sczqoaxl9/IXzL5lSCDG3AELZ7G3EHghEP7c/pU32OkZQjf5gCJCrldui09EI
         44ndgf29eNx/8gqmQAPazAfUJ/9Kjzl4QAgkJ5+NWRJD2WuB1TvRpdqy/zSuCfSL/adi
         ++ww==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k29si1506638edb.395.2019.04.25.00.31.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Apr 2019 00:31:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 1040DAE5A;
	Thu, 25 Apr 2019 07:31:52 +0000 (UTC)
Received: by quack2.suse.cz (Postfix, from userid 1000)
	id EC0681E15BE; Thu, 25 Apr 2019 09:31:49 +0200 (CEST)
Date: Thu, 25 Apr 2019 09:31:49 +0200
From: Jan Kara <jack@suse.cz>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Matthew Wilcox <willy@infradead.org>,
	"Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>,
	Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>,
	linux-nvdimm <linux-nvdimm@lists.01.org>,
	Linux MM <linux-mm@kvack.org>,
	linuxppc-dev <linuxppc-dev@lists.ozlabs.org>,
	stable <stable@vger.kernel.org>,
	Chandan Rajendra <chandan@linux.ibm.com>
Subject: Re: [PATCH v2] mm: Fix modifying of page protection by
 insert_pfn_pmd()
Message-ID: <20190425073149.GA21215@quack2.suse.cz>
References: <20190402115125.18803-1-aneesh.kumar@linux.ibm.com>
 <CAPcyv4hzRj5yxVJ5-7AZgzzBxEL02xf2xwhDv-U9_osWFm9kiA@mail.gmail.com>
 <20190424173833.GE19031@bombadil.infradead.org>
 <CAPcyv4gLGUa69svQnwjvruALZ0ChqUJZHQJ1Mt_Cjr1Jh_6vbQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4gLGUa69svQnwjvruALZ0ChqUJZHQJ1Mt_Cjr1Jh_6vbQ@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 24-04-19 11:13:48, Dan Williams wrote:
> On Wed, Apr 24, 2019 at 10:38 AM Matthew Wilcox <willy@infradead.org> wrote:
> >
> > On Wed, Apr 24, 2019 at 10:13:15AM -0700, Dan Williams wrote:
> > > I think unaligned addresses have always been passed to
> > > vmf_insert_pfn_pmd(), but nothing cared until this patch. I *think*
> > > the only change needed is the following, thoughts?
> > >
> > > diff --git a/fs/dax.c b/fs/dax.c
> > > index ca0671d55aa6..82aee9a87efa 100644
> > > --- a/fs/dax.c
> > > +++ b/fs/dax.c
> > > @@ -1560,7 +1560,7 @@ static vm_fault_t dax_iomap_pmd_fault(struct
> > > vm_fault *vmf, pfn_t *pfnp,
> > >                 }
> > >
> > >                 trace_dax_pmd_insert_mapping(inode, vmf, PMD_SIZE, pfn, entry);
> > > -               result = vmf_insert_pfn_pmd(vma, vmf->address, vmf->pmd, pfn,
> > > +               result = vmf_insert_pfn_pmd(vma, pmd_addr, vmf->pmd, pfn,
> > >                                             write);
> >
> > We also call vmf_insert_pfn_pmd() in dax_insert_pfn_mkwrite() -- does
> > that need to change too?
> 
> It wasn't clear to me that it was a problem. I think that one already
> happens to be pmd-aligned.

Why would it need to be? The address is taken from vmf->address and that's
set up in __handle_mm_fault() like .address = address & PAGE_MASK. So I
don't see anything forcing PMD alignment of the virtual address...

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

