Return-Path: <SRS0=BXMS=UN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 60374C31E45
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 02:31:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 04DBF208CA
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 02:31:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="ENiikzv7"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 04DBF208CA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 657688E0003; Thu, 13 Jun 2019 22:31:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 607918E0002; Thu, 13 Jun 2019 22:31:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4CFE68E0003; Thu, 13 Jun 2019 22:31:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 175DF8E0002
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 22:31:18 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id 21so787240pgl.5
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 19:31:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=+7wuYVOL+KJLLZqVsK5P8paT7js/8q2t5FmzFZkLtIs=;
        b=ZcNvbkT/bXG28GOzaxGA1kM791lh+Ccu7iQNqy4jdfA4Ke2K9TiU/LOFYGNrS9yRoQ
         3j8Mkn/N488V+lrJHILdGVL97G3VFpcifAbttaJhI3pfMsMYrB7xGMTeTinnzgghKz1s
         s6O5Fm0xkB8Sy98Y+im9h66cKTrXOs3obgH3onGSGTYEBkgwtX17EqiqgcR233er9ozu
         nOzogzOBMJWNBiQRDtEKTz7s7oYyKogcJ4EmFJbscbWnd3nZeUvIfUVBmZ+/JrgguMAU
         9hRYPCc+4S2+rbxUhBwVc6N/WgP2WmEv6XUXQ/eUvdqPopxOaiCn+m5PtwScvYD089NI
         Z5OQ==
X-Gm-Message-State: APjAAAUrGn+T55zzxLvaDzoSuFC4QiYlvhHua5g33eZzsHwTeUoMNDIa
	Bxse61t7k8U1xDvjJyOtom2bOPLqoDnwVrfQT9hx5YYbqn7uAxB+Od116y+7CKXvES3UjXnOODt
	h/HjAPCL9ct4/wN1+Z3LC7uQUtrj4tUdqClRZTdd0F9Az6KGOejfy89kq1WCReuAs1w==
X-Received: by 2002:a17:90a:bb94:: with SMTP id v20mr8763261pjr.88.1560479477684;
        Thu, 13 Jun 2019 19:31:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwbL2vTJvCsgM6mutAehPkFQnKSNSNOryE4YXCEesFhCatev7RPhNeNoZiKXrXhONnHgAmr
X-Received: by 2002:a17:90a:bb94:: with SMTP id v20mr8763213pjr.88.1560479476703;
        Thu, 13 Jun 2019 19:31:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560479476; cv=none;
        d=google.com; s=arc-20160816;
        b=AmNSZIaElb9x3anWvbIvYsdzky5DH8oqYfI1xhg8iLc1WwFhsaqAvl/LOjd2tD3hq8
         GbDRFTIfrR/CUqPLH9Wc6H+33ttIcazajnPvz/Rx7lRYDmTMIc8Tox/owOee66jSzJkD
         Gwd/sEnGTdWaKIZxN4/tiJwdTxdEFLdhtSeKdEAjhP+1SG8f0INPKhX009ORYba0A3hK
         hHBUdSoo4OzosT7XnBXfLxQTp6nL34Dp+n+drmzOtfAOSeuplFvP3qEhoJNRL7kk7Nc8
         /hoyJ1SKph986fwgurJE56fVq2VSwDRoJANQT//sJ82mZuAamwvwn771oi7/EQ7Qh5VT
         +66A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=+7wuYVOL+KJLLZqVsK5P8paT7js/8q2t5FmzFZkLtIs=;
        b=jV8OHtIWQa3o/nnc2Jtzui0yEc4Vl2dR8Wnw3dMM6YrTaG3XTOzxRUhmqoWUTnzbRT
         sbFoqBPLw6gPkLFS344r5eXmtHFxYwIw0W0hBYzezpFmDfnfZgUUAloq83N4F1DitJrK
         Yli1t+quQzWVS2ERlbwlfQvDoi366DC3FpR7LUcsBbUYtL59cHcQVLRLzakptp/Af9PI
         WzHq633VQk8evWVx9MGYtPDkR5+F47HmBM5rCLjom2O02RNLxf0eL7aB4x5Cs2ssVN87
         x7W1QdGSEmg60azK7hzdyEVJuXfj98lZN0VBvgwMCV/TOg1/Jy+UvtbzXsSRHMPFv8KD
         F17A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=ENiikzv7;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id h7si1019225plr.5.2019.06.13.19.31.16
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 13 Jun 2019 19:31:16 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=ENiikzv7;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=+7wuYVOL+KJLLZqVsK5P8paT7js/8q2t5FmzFZkLtIs=; b=ENiikzv7M66hoOdASWgKZV1A0
	rJK5psvvRbGVSGGyq2u76HQ0+ghuJReMB1GMbXkJHt5z8ePNmyi1/hdZDsjH3mXarUHdhpimSMjoM
	Eo5tLSG9C1Ur4S4+1bNnYwiyPrj97STAqU2aHaIQRwsjw6fM6hLz/kyP8jauG67FXvTUc5TedeNCP
	svVbpzU8jJOYHfoct4Hi43JwxrDsxO3My6EWca+6zLisl3fGYLkB8geveNSrbXx4RVYLLfMrxJvO4
	klnCQks4Kovj2mzLBFnp/hawIDHAWCK32ZvscGHxlSexEz54emMO4w/SU0PsCRVjWghHyNtUJ6dT+
	Gg+QtRtrA==;
Received: from willy by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1hbbzf-0001q2-Se; Fri, 14 Jun 2019 02:31:07 +0000
Date: Thu, 13 Jun 2019 19:31:07 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Jason Gunthorpe <jgg@ziepe.ca>, Ira Weiny <ira.weiny@intel.com>,
	Jan Kara <jack@suse.cz>, Dan Williams <dan.j.williams@intel.com>,
	Theodore Ts'o <tytso@mit.edu>, Jeff Layton <jlayton@kernel.org>,
	linux-xfs@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	John Hubbard <jhubbard@nvidia.com>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-nvdimm@lists.01.org, linux-ext4@vger.kernel.org,
	linux-mm@kvack.org, linux-rdma@vger.kernel.org
Subject: Re: [PATCH RFC 00/10] RDMA/FS DAX truncate proposal
Message-ID: <20190614023107.GK32656@bombadil.infradead.org>
References: <20190606220329.GA11698@iweiny-DESK2.sc.intel.com>
 <20190607110426.GB12765@quack2.suse.cz>
 <20190607182534.GC14559@iweiny-DESK2.sc.intel.com>
 <20190608001036.GF14308@dread.disaster.area>
 <20190612123751.GD32656@bombadil.infradead.org>
 <20190613002555.GH14363@dread.disaster.area>
 <20190613152755.GI32656@bombadil.infradead.org>
 <20190613211321.GC32404@iweiny-DESK2.sc.intel.com>
 <20190613234530.GK22901@ziepe.ca>
 <20190614020921.GM14363@dread.disaster.area>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190614020921.GM14363@dread.disaster.area>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 14, 2019 at 12:09:21PM +1000, Dave Chinner wrote:
> On Thu, Jun 13, 2019 at 08:45:30PM -0300, Jason Gunthorpe wrote:
> > On Thu, Jun 13, 2019 at 02:13:21PM -0700, Ira Weiny wrote:
> > > On Thu, Jun 13, 2019 at 08:27:55AM -0700, Matthew Wilcox wrote:
> > > > On Thu, Jun 13, 2019 at 10:25:55AM +1000, Dave Chinner wrote:
> > > > > e.g. Process A has an exclusive layout lease on file F. It does an
> > > > > IO to file F. The filesystem IO path checks that Process A owns the
> > > > > lease on the file and so skips straight through layout breaking
> > > > > because it owns the lease and is allowed to modify the layout. It
> > > > > then takes the inode metadata locks to allocate new space and write
> > > > > new data.
> > > > > 
> > > > > Process B now tries to write to file F. The FS checks whether
> > > > > Process B owns a layout lease on file F. It doesn't, so then it
> > > > > tries to break the layout lease so the IO can proceed. The layout
> > > > > breaking code sees that process A has an exclusive layout lease
> > > > > granted, and so returns -ETXTBSY to process B - it is not allowed to
> > > > > break the lease and so the IO fails with -ETXTBSY.
> > > > 
> > > > This description doesn't match the behaviour that RDMA wants either.
> > > > Even if Process A has a lease on the file, an IO from Process A which
> > > > results in blocks being freed from the file is going to result in the
> > > > RDMA device being able to write to blocks which are now freed (and
> > > > potentially reallocated to another file).
> > > 
> > > I don't understand why this would not work for RDMA?  As long as the layout
> > > does not change the page pins can remain in place.
> > 
> > Because process A had a layout lease (and presumably a MR) and the
> > layout was still modified in way that invalidates the RDMA MR.
> 
> The lease holder is allowed to modify the mapping it has a lease
> over. That's necessary so lease holders can write data into
> unallocated space in the file. The lease is there to prevent third
> parties from modifying the layout without the lease holder being
> informed and taking appropriate action to allow that 3rd party
> modification to occur.
> 
> If the lease holder modifies the mapping in a way that causes it's
> own internal state to screw up, then that's a bug in the lease
> holder application.

Sounds like the lease semantics aren't the right ones for the longterm
GUP users then.  The point of the longterm GUP is so the pages can be
written to, and if the filesystem is going to move the pages around when
they're written to, that just won't work.

