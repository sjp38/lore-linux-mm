Return-Path: <SRS0=Gu5B=QN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B93A1C282CC
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 20:41:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 577ED21902
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 20:41:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="lGhu39iF"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 577ED21902
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C4F1D8E00D0; Wed,  6 Feb 2019 15:41:34 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BFC998E00CE; Wed,  6 Feb 2019 15:41:34 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AECC38E00D0; Wed,  6 Feb 2019 15:41:34 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6E4418E00CE
	for <linux-mm@kvack.org>; Wed,  6 Feb 2019 15:41:34 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id v16so2804058plo.17
        for <linux-mm@kvack.org>; Wed, 06 Feb 2019 12:41:34 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=sWEKy5aicFMji7dfB83+mOjLcp3oFlOpybyajD/WoZQ=;
        b=rntay3owDPDcMJ1hjjSmpQ6Npl69C31A642cBvTLV3IjK5PlaDtRF6W8fEkqaQwt3Z
         RHc8eVVWoJULqLK4Ql064EEeWJ4UBL2o++1V4O57an4bKtc9Yj0ZWqUxLIIRunKDg+tm
         A5YSY70pA/fFt8x5FLp2Nl86CAwklY6MVk8ccbmJspgMclOs+c48L0uFO1FvcV4+s2KA
         5qoMuWz6vETZpQ1k+Hn2pNXcz8bDuukuFugatiqAd5M8lQJgN03SekPb9SY1WPqsn9tY
         Savuns5B+tjBzSGqrpxnxIfkLOJMEVFhYtVz5sY2sem54U29YRT49Q7tOjIDEw/c1p0X
         +/Rg==
X-Gm-Message-State: AHQUAubSoX/rAwtv2KAozgGUka/73+hSzWx/FhvWDIybK8/f4Mya+N0s
	InyMBH/DJ6IP39uExb6r+Kahdf7j/isjBbXYYVE6gwUpacN51kodfe3IlnzcIITL76GSC/G6rFm
	s/OYSPqCH2vJfKcHbtn2LsJIi20CT1MnNlUnd9Beq5ULdgWMyhbkfS+7ItFZq4IbpOw==
X-Received: by 2002:a63:3c58:: with SMTP id i24mr11554179pgn.284.1549485694059;
        Wed, 06 Feb 2019 12:41:34 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ia5oVp1g2J3HVZuB9mrDzcw/knxAZmpVQWMr86IzR+dkJTzgw+8i4k6XiHAhNF8d7E6Yjn1
X-Received: by 2002:a63:3c58:: with SMTP id i24mr11554133pgn.284.1549485693380;
        Wed, 06 Feb 2019 12:41:33 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549485693; cv=none;
        d=google.com; s=arc-20160816;
        b=DK25dvFFekTKjHMZOJlD6x70rB5hPAiwhBf30wWHv8sw2plbz2TSiYIbtajTVG3Ozi
         18BYkEwJIJihfcCsfj/GwUntibuV3cVZjFBh25OVmfpc9nfqdqiD76crqvlHuCIYBMWj
         u73+RCLDYtdBgcEZz3RdX85arr0FtNljyayAbKPSwsPbihVZcu4rVz56sU99dkCP2e55
         AAeDu+X3FnacZRlCBSTL8BpQjGFPO+STGO0ZXQ/rKsFfm9hG5F0DizFRPUT1Nt9T4DG7
         +bb7TQqX1dIAZpPiJE/E3zw/aFYOHScEzMtn6c7/27BgB8cQ1S78215VNI0bz+Pgd4cx
         t4kQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=sWEKy5aicFMji7dfB83+mOjLcp3oFlOpybyajD/WoZQ=;
        b=tMUx54ras1Phs823EFe7L/EWp+NRiJriZ5CdnjmnILM8Gt3PGEC5cTBksx6uFAD7X2
         OZ5U7WhDyoQtqCYul6SIFyuo8msgJIXqo6BsKCVNbxGyuXXpZh+hecqrBINOkd4RleGh
         0pVo92MmLBsBTS7k+TO08pJwVPr/61htRbv8hqa51fv5WRAtTSh+xtdccYk8jF/J8fqV
         4UKs/SOYDodokyH5AhwIIsOie+x2CxCRIBk1oASmoIYvaKuFaJ/1Nsfqy0IHMqBSgJI/
         aXH+6ouuIjgYPbTDM47z/M1vgBbXot2YQH8jtXpuqno8lQXJzPcC0dkEUJGYm5sE4pHk
         iL2A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=lGhu39iF;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id h17si6746361pgd.538.2019.02.06.12.41.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 06 Feb 2019 12:41:33 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=lGhu39iF;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=sWEKy5aicFMji7dfB83+mOjLcp3oFlOpybyajD/WoZQ=; b=lGhu39iFHGWpvbRYczilWLR4r
	7fQM8YFJAZN8allzduj9Eody3bio+zBsadPFUnEagmSHYZVKNGx8DeHmVlJf5g04b9INUcxffjwRw
	chp0xai/x6avJiMiMNSWnltw+JWwe2rOvPKh6EG7f8BYYhWgNWWRztUWVLRZIuAIqb0M28gvV87QG
	kqinj6dE6kMmbuH1toWRNc026lLLmmUsYpu0pK2vhNbFdZ+MRRXMoDwOkgK0xm9YtBVTkG1Eb9WQz
	m0yL5r/pbWigkgHqlRfTSgy6arFOxnWWo/QmTSUMLcX5qBP8oYd3Y3KFQtpQuPzl+bMEBuwHlRMtY
	G2IgR77Iw==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1grU0e-0006kC-HG; Wed, 06 Feb 2019 20:41:28 +0000
Date: Wed, 6 Feb 2019 12:41:28 -0800
From: Matthew Wilcox <willy@infradead.org>
To: Doug Ledford <dledford@redhat.com>
Cc: Christopher Lameter <cl@linux.com>, Jason Gunthorpe <jgg@ziepe.ca>,
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
Message-ID: <20190206204128.GR21860@bombadil.infradead.org>
References: <20190205175059.GB21617@iweiny-DESK2.sc.intel.com>
 <20190206095000.GA12006@quack2.suse.cz>
 <20190206173114.GB12227@ziepe.ca>
 <20190206175233.GN21860@bombadil.infradead.org>
 <47820c4d696aee41225854071ec73373a273fd4a.camel@redhat.com>
 <01000168c43d594c-7979fcf8-b9c1-4bda-b29a-500efe001d66-000000@email.amazonses.com>
 <20190206194055.GP21860@bombadil.infradead.org>
 <a9df9be75966f34f55f843a3cd7e1ee7d497c7fa.camel@redhat.com>
 <20190206202021.GQ21860@bombadil.infradead.org>
 <a8dc27e81182060b3480127332c77ac624abcb22.camel@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <a8dc27e81182060b3480127332c77ac624abcb22.camel@redhat.com>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 06, 2019 at 03:28:35PM -0500, Doug Ledford wrote:
> On Wed, 2019-02-06 at 12:20 -0800, Matthew Wilcox wrote:
> > On Wed, Feb 06, 2019 at 03:16:02PM -0500, Doug Ledford wrote:
> > > On Wed, 2019-02-06 at 11:40 -0800, Matthew Wilcox wrote:
> > > > On Wed, Feb 06, 2019 at 07:16:21PM +0000, Christopher Lameter wrote:
> > > > > though? If we only allow this use case then we may not have to worry about
> > > > > long term GUP because DAX mapped files will stay in the physical location
> > > > > regardless.
> > > > 
> > > > ... except for truncate.  And now that I think about it, there was a
> > > > desire to support hot-unplug which also needed revoke.
> > > 
> > > We already support hot unplug of RDMA devices.  But it is extreme.  How
> > > does hot unplug deal with a program running from the device (something
> > > that would have returned ETXTBSY)?
> > 
> > Not hot-unplugging the RDMA device but hot-unplugging an NV-DIMM.
> > 
> > It's straightforward to migrate text pages from one DIMM to another;
> > you remove the PTEs from the CPU's page tables, copy the data over and
> > pagefaults put the new PTEs in place.  We don't have a way to do similar
> > things to an RDMA device, do we?
> 
> We don't have a means of migration except in the narrowly scoped sense
> of queue pair migration as defined by the IBTA and implemented on some
> dual port IB cards.  This narrowly scoped migration even still involves
> notification of the app.
> 
> Since there's no guarantee that any other port can connect to the same
> machine as any port that's going away, it would always be a
> disconnect/reconnect sequence in the app to support this, not an under
> the covers migration.

I don't understand you.  We're not talking about migrating from one IB
card to another, we're talking about changing the addresses that an STag
refers to.

