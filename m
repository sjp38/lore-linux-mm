Return-Path: <SRS0=Gu5B=QN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9254CC282CC
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 19:41:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 31DE62080D
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 19:41:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="IR+FJ01H"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 31DE62080D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 811B88E00F0; Wed,  6 Feb 2019 14:41:02 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7C3A98E00EE; Wed,  6 Feb 2019 14:41:02 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6B2B08E00F0; Wed,  6 Feb 2019 14:41:02 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2A7468E00EE
	for <linux-mm@kvack.org>; Wed,  6 Feb 2019 14:41:02 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id s71so5947779pfi.22
        for <linux-mm@kvack.org>; Wed, 06 Feb 2019 11:41:02 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=BA5++3mOup44EpHAKD9LlVzSGzF+bJ0yAEAwHsLicYk=;
        b=qPva8h8UXZfM26onwFldETy64nrjs1y6rWVGB0DthNqtC8f9vwqNAcLs1wIv6kE4Cb
         HSQzqFZR7eQdPE1gcKteqF9ECDZUY+Dv6fupbEb1kQqBSHONaKnF4peU9G26PHxz6njB
         Q1Vbpae7QgVU1vxdXxdigWpbUEfIHCQX0MdNEIYM/eAugMuqDb2HzAa91BllVx4zAGjU
         ConIW9pxNq+YJlrupX11crFNzjAkWn24LDQWUKX1MDTRRt8qt5nLGZXE9XZ0eDxS83+O
         YbPU5bxdiUXQRUVBMudZEhkaabellCNOSDb/ggRM+KO2dwoJNnDtmkpAyVyAsnYeLvfc
         dzIA==
X-Gm-Message-State: AHQUAubWwdgIh45qaSffcBI76XZjTyuolNYV+d0+9XIlYrseDCvLVlQ4
	HIk/ynGRXcsDyjy/MW4A3KfkGQECbKGmKSFwLGsShYHlJEiZiuUeoBUhQWvqOkD6YH32c8xUZK1
	Vxn/UmysOnqjDXR6u016b5+t7SBCNRn5k6AHcHVPTY9nQbSCJvptPrYlad1JNT1kg/g==
X-Received: by 2002:a62:8add:: with SMTP id o90mr12041516pfk.210.1549482061830;
        Wed, 06 Feb 2019 11:41:01 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZIZ4aBPoBRpr301bE4IF0zdNdARSx2y2EoE/ZGzGR39HCSQ/2dNUOKk5+f/rzTTYOiu1Jj
X-Received: by 2002:a62:8add:: with SMTP id o90mr12041460pfk.210.1549482060876;
        Wed, 06 Feb 2019 11:41:00 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549482060; cv=none;
        d=google.com; s=arc-20160816;
        b=sjYeoOP5hpMcCSiI3cxPn6uOQB2XPatgZuNJmVGH9edHqtVKujJya8sqp4bO3gCZfD
         qBaeCNBOt04csCcwyfOufxegI5V9J61kORVVvGolr7adxDbaQkLQMU0aYZkmJydPVryy
         PdP+xvPe+oaDpfhx2Kh3CIOkSuiqMBvT+tgi7IWx5XBr53e7srrdmCQ7vqPwsDtSscMm
         3LYysMAkGoGL6YYu8sUn7UazIzmasOZfw61wScBLruRSiS8W7Q+8nFX3NeSikAWS+tBs
         KKl7UdP5WfYvY5clQfG3SesnsXeYj2OvPdVnxSNLJgPQxMsI1GTlv+4lL0vzFpjaqZ4B
         AcGQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=BA5++3mOup44EpHAKD9LlVzSGzF+bJ0yAEAwHsLicYk=;
        b=Dp3PN5NvEUKb6HcVVyCZoBtUCfMaFf/Yq40zruDmsF5m2LRnJ7iMfQDVU1g+v20K3n
         kavLaNAuQdSKle39TIyFjUg/he2BNPEUlxok2n5iijpDMZ7+hSzFCwyezGay8OGRMC6t
         Ao0t1WHh+ro9vQMfxpPFROWJLDyDSB4lPUii8Zv0rcLChxcwDWglnBZkl860M4BYK/uq
         TBaU/M9k3CsD5Emvp3VCZOb0jaygYn7aHNTuFcaoYq2B+2AxX5YCn79rVVJLenEy1tcr
         jp/6rrt15aEp7hlTd2GLS7LqGdGCL4yb6w/+e5NXbNZ46k9CDqsp68mf8sz2WUPsaW8D
         pOew==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=IR+FJ01H;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id c7si2752477plr.157.2019.02.06.11.41.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 06 Feb 2019 11:41:00 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=IR+FJ01H;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=BA5++3mOup44EpHAKD9LlVzSGzF+bJ0yAEAwHsLicYk=; b=IR+FJ01HHpgI1v1qYcrRIcwSq
	p+PzmPljmi8oQ98xngZngx9W35YyiG8qjpKyhMfZnksx3r8yquFY0trX527LSLDvjZ7S58x3Zfj5N
	qLEubpDEEv3qwOVpQf0a/KECbvV0Ta0FTKcuLXQfviNZRrozFNalIZnd24z0/9SOkjGE8+VIC9BO7
	L/IV2dwCJGR2MPCJrlw80XyYeW5kctr2H4MZo9QA1OCaUnIdnUvxbwoliwcSYhdZaLIxytgWBkQXM
	+KPe4kGqFIq/rQXVElXdJROrj+JobFt1k00IQ7K0WSTCNq8HT3nIzxpysqmpDnOTZvzStVh4CpNBv
	QCCiUnYDA==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1grT43-00032j-M5; Wed, 06 Feb 2019 19:40:55 +0000
Date: Wed, 6 Feb 2019 11:40:55 -0800
From: Matthew Wilcox <willy@infradead.org>
To: Christopher Lameter <cl@linux.com>
Cc: Doug Ledford <dledford@redhat.com>, Jason Gunthorpe <jgg@ziepe.ca>,
	Jan Kara <jack@suse.cz>, Ira Weiny <ira.weiny@intel.com>,
	lsf-pc@lists.linux-foundation.org, linux-rdma@vger.kernel.org,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	John Hubbard <jhubbard@nvidia.com>,
	Jerome Glisse <jglisse@redhat.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Dave Chinner <david@fromorbit.com>,
	Michal Hocko <mhocko@kernel.org>
Subject: Re: [LSF/MM TOPIC] Discuss least bad options for resolving
 longterm-GUP usage by RDMA
Message-ID: <20190206194055.GP21860@bombadil.infradead.org>
References: <20190205175059.GB21617@iweiny-DESK2.sc.intel.com>
 <20190206095000.GA12006@quack2.suse.cz>
 <20190206173114.GB12227@ziepe.ca>
 <20190206175233.GN21860@bombadil.infradead.org>
 <47820c4d696aee41225854071ec73373a273fd4a.camel@redhat.com>
 <01000168c43d594c-7979fcf8-b9c1-4bda-b29a-500efe001d66-000000@email.amazonses.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <01000168c43d594c-7979fcf8-b9c1-4bda-b29a-500efe001d66-000000@email.amazonses.com>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 06, 2019 at 07:16:21PM +0000, Christopher Lameter wrote:
> On Wed, 6 Feb 2019, Doug Ledford wrote:
> > > Most of the cases we want revoke for are things like truncate().
> > > Shouldn't happen with a sane system, but we're trying to avoid users
> > > doing awful things like being able to DMA to pages that are now part of
> > > a different file.
> >
> > Why is the solution revoke then?  Is there something besides truncate
> > that we have to worry about?  I ask because EBUSY is not currently
> > listed as a return value of truncate, so extending the API to include
> > EBUSY to mean "this file has pinned pages that can not be freed" is not
> > (or should not be) totally out of the question.
> >
> > Admittedly, I'm coming in late to this conversation, but did I miss the
> > portion where that alternative was ruled out?
> 
> Coming in late here too but isnt the only DAX case that we are concerned
> about where there was an mmap with the O_DAX option to do direct write

There is no O_DAX option.  There's mount -o dax, but there's nothing that
a program does to say "Use DAX".

> though? If we only allow this use case then we may not have to worry about
> long term GUP because DAX mapped files will stay in the physical location
> regardless.

... except for truncate.  And now that I think about it, there was a
desire to support hot-unplug which also needed revoke.

> Maybe we can solve the long term GUP problem through the requirement that
> user space acquires some sort of means to pin the pages? In the DAX case
> this is given by the filesystem and the hardware will basically take care
> of writeback.

It's not given by the filesystem.

> In case of anonymous memory this can be guaranteed otherwise and is less
> critical since these pages are not part of the pagecache and are not
> subject to writeback.

but are subject to being swapped out?

