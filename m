Return-Path: <SRS0=Gu5B=QN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D130DC282CC
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 20:20:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8CEF020823
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 20:20:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="Ab/ZKKur"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8CEF020823
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1B15D8E00F8; Wed,  6 Feb 2019 15:20:27 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 13A3E8E00F3; Wed,  6 Feb 2019 15:20:27 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EF5A38E00F8; Wed,  6 Feb 2019 15:20:26 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id AAF138E00F3
	for <linux-mm@kvack.org>; Wed,  6 Feb 2019 15:20:26 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id t10so5688743plo.13
        for <linux-mm@kvack.org>; Wed, 06 Feb 2019 12:20:26 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=zxiuA+kMki/UhwSsnRN7805PLjtsIi6PGZFOiQ1YwQk=;
        b=NNmrOzt5Fa0BDjylHTSdNyLlAeUNClXajB+uL0ie9le+IcKiDtCemaSEwieQIusghH
         HXvcFUUFdKmW+dxIHcNldw5fTEMIfqFncdMVQWOh1zp5a2xaD2Bbb2dAONPNc9HOtWD9
         R4+KM2Zrr+48Q0sC5yUFZ0Jy3r6AcOHXBX54MwbO24OzUSfu4n7lrj6p4lnb0slllGJa
         MjGVqJCn1uwm+D4fVgSr0nfBZhtqb8NdD3iUafRF34Ptir1hGCMDO13nbptb4p3k7dsD
         lfGcGAmH4Vbu5gnzHxfdLFa4WqpRpXz84Qyqasz+7aOv/I6wGyEDfew+IknYy0y6+b0+
         Ij7w==
X-Gm-Message-State: AHQUAuZ2bUCN+sp90glXH8fDcx5Aobmflk8MP016V90X2F97WUUSUrDe
	NFbUHiIJ+ghNj9J70PfVGsBiMcaCjsyILU1ZY10GcNh7yYgxcHo5o0s9gSSM7Hm+wTKSNwA/Lzz
	X0MdBbBOBsL15ABEkQKawMGqxNOp+cIWgOyApyL2sFf7WWvWVqr/uI1HZIAGtrePRag==
X-Received: by 2002:a17:902:3124:: with SMTP id w33mr12556788plb.241.1549484426356;
        Wed, 06 Feb 2019 12:20:26 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ib0SqxYeSouar8XjUs1ioCXGchhPLm+OAWZu50KD5M24EtGWy1bxchOXlmI5QUeiZnOSlZw
X-Received: by 2002:a17:902:3124:: with SMTP id w33mr12556742plb.241.1549484425692;
        Wed, 06 Feb 2019 12:20:25 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549484425; cv=none;
        d=google.com; s=arc-20160816;
        b=IlNn0DkxLJFyLvuE+V5YTMzYef8mN6IRN+NAdQNyPObTtX65lQRiHBFEGiyKvv5C8T
         YklZljLBDNKJ+qpK0gntD1QM+l36mfWMs967nU9lqJQl3XZgvPWzKGYLG0kj/+JeXW5L
         4durPLxp1lbCsgdZd+pkGFgNc6KXQ6ync/llzwoxMDICeIAdjQ0i1zS2spHe+M3FocT6
         /BFJdf/4NQ4LU0GqSv+YS022y5iN6G93sI/zYgMFaKbeT/PF11Sp9qa3BV8wl1AEkusF
         NHVH7eNOwoMIc8ChYFgaR3XnSOnWJL/KhwYptN4OPmOAONCAGOWahvJ2Xc9onjUA92yt
         lLyA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=zxiuA+kMki/UhwSsnRN7805PLjtsIi6PGZFOiQ1YwQk=;
        b=oI9ANkS5gWVQf+XPjc4+WQovOF4N13pRkw9+InAW93ku22zUkFYgoQXqxTyqObqBz4
         fbKmFutgX6kYjsOTZTGmEjGpT9u7kgkbVag0IRLzPjaGn1oZKVh0rjxraXLSyVGj/a7I
         Le9kF9RWYOTl8/AbwQiGfyfJHjzCYVGhE1TV1HL7Hofau7AdPOMdZoFUrgt1g9k+QD0Y
         xljxhmq4x/XCXLENf5I4K0QHVjw0b7S04yeK5RMteYUzYgWfmixJXKFjgmc5beS8CAd9
         +qgtfsv12k2UJ/Ep7Jg7mvFmX/zK9hvHINtRPL/4NGJKAs6okWSvvnpDqBlaQJDs/KHf
         cQfQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="Ab/ZKKur";
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id l66si6942370pfi.5.2019.02.06.12.20.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 06 Feb 2019 12:20:25 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="Ab/ZKKur";
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=zxiuA+kMki/UhwSsnRN7805PLjtsIi6PGZFOiQ1YwQk=; b=Ab/ZKKurlrlfBf27eXyZXOAoc
	vMRey/USNDaTEnIgHG3mGDD3ZLLM1aisiG7e0shzKeua0xOugZ2EixdhKk8B/pBQs/aw+NSJl72+5
	WMkK95M7MEOG8rcRdlRibITDjzsg7gYTfhH7d/kL6LnJUluCZ+vN+M8uKloKFKAm911wua3K4IyY3
	53oawd2oTBqnpQUtZm7AniaJvkc/6VKZ2z8miEukueTSg6krxGKQwIAjLR9/OjAHNFuYR9jAAjSIv
	YJJS0o8Mt+ikxTAoYusqDbJtLVPBy3+FsI3TMamjD6SZsPHbOoiOqU0ENz7ItusFaSmT4pmdeN7qx
	ME+59Vxyw==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1grTgD-0003Sc-As; Wed, 06 Feb 2019 20:20:21 +0000
Date: Wed, 6 Feb 2019 12:20:21 -0800
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
Message-ID: <20190206202021.GQ21860@bombadil.infradead.org>
References: <20190205175059.GB21617@iweiny-DESK2.sc.intel.com>
 <20190206095000.GA12006@quack2.suse.cz>
 <20190206173114.GB12227@ziepe.ca>
 <20190206175233.GN21860@bombadil.infradead.org>
 <47820c4d696aee41225854071ec73373a273fd4a.camel@redhat.com>
 <01000168c43d594c-7979fcf8-b9c1-4bda-b29a-500efe001d66-000000@email.amazonses.com>
 <20190206194055.GP21860@bombadil.infradead.org>
 <a9df9be75966f34f55f843a3cd7e1ee7d497c7fa.camel@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <a9df9be75966f34f55f843a3cd7e1ee7d497c7fa.camel@redhat.com>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 06, 2019 at 03:16:02PM -0500, Doug Ledford wrote:
> On Wed, 2019-02-06 at 11:40 -0800, Matthew Wilcox wrote:
> > On Wed, Feb 06, 2019 at 07:16:21PM +0000, Christopher Lameter wrote:
> > > 
> > > though? If we only allow this use case then we may not have to worry about
> > > long term GUP because DAX mapped files will stay in the physical location
> > > regardless.
> > 
> > ... except for truncate.  And now that I think about it, there was a
> > desire to support hot-unplug which also needed revoke.
> 
> We already support hot unplug of RDMA devices.  But it is extreme.  How
> does hot unplug deal with a program running from the device (something
> that would have returned ETXTBSY)?

Not hot-unplugging the RDMA device but hot-unplugging an NV-DIMM.

It's straightforward to migrate text pages from one DIMM to another;
you remove the PTEs from the CPU's page tables, copy the data over and
pagefaults put the new PTEs in place.  We don't have a way to do similar
things to an RDMA device, do we?


