Return-Path: <SRS0=jH+M=QO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 39B0BC282CC
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 17:24:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E9C162084D
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 17:24:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="uFjpHN01"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E9C162084D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8AE7E8E0052; Thu,  7 Feb 2019 12:24:11 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 810D88E0002; Thu,  7 Feb 2019 12:24:11 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6A80F8E0052; Thu,  7 Feb 2019 12:24:11 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 231358E0002
	for <linux-mm@kvack.org>; Thu,  7 Feb 2019 12:24:11 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id q63so373337pfi.19
        for <linux-mm@kvack.org>; Thu, 07 Feb 2019 09:24:11 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=KaCACouyWcP3AHn7c7rvYHXFAgfIP9iLxHVqu/otoeA=;
        b=RXWUhNjQbTVCwU9wuafHNvVvncLPvmTmtQMRPhsjOCkTIUUbzFs3jxLzGWDAhvsT6+
         uLM8otQQX7liqJHracM5XqjnZuZVBciERjrGbl3BYRe1GBFoxfD1eSrGwfzEyruvviA0
         sYzKvEdrZXgaN7oWKQXvabdTVOuegdxZ+sARLeMes452DWN65D9kRXf4FEh71jGlbnSi
         8w2Zkuh3OwWDTzawZLYLPDuNATHMRBmmKnWKrhkEZtP8IaW7+kBmdTCvxB8NhxmKzVNS
         l3KdcEBWAh7SgWRi988gyOVoIdjETII7y83ifjL7RuZq1lC4IMJf/UbnXmaDhgvVP0JA
         SBAQ==
X-Gm-Message-State: AHQUAubSTvUnh+dZgDFh9MzvDngC5i2E4XJR5lztqW8DkxfXttg+zbdv
	7gEIMjqdoGbjhldRha/ZiTJX2VHdJtysm7USozNCGX9MBvmbZ4GLsUj7e9Ws5wAEKcdO9sEaTrw
	eU+NJoH3aLsAsOQkYzFrCSLnYmdYPEiA4Gc3wREQ7hDGRFPqnSvhm8OZf/VNcwBgYxA==
X-Received: by 2002:a63:b105:: with SMTP id r5mr15875976pgf.442.1549560250754;
        Thu, 07 Feb 2019 09:24:10 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbCgPVqVtGg9zgvdvn306w/EIyjfjAYKPADpCUrAkKz5RDrBygt1MhJAOc0mtJ6I341gjIL
X-Received: by 2002:a63:b105:: with SMTP id r5mr15875922pgf.442.1549560249905;
        Thu, 07 Feb 2019 09:24:09 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549560249; cv=none;
        d=google.com; s=arc-20160816;
        b=vpdK6Sa9X9GRjrJmqBzfoq7xcDqgwg82QbFbdd8XVEUASbZZ6l3gEUJnKmUz3ogcWR
         PJ+lndiGO7Dc2V2aotGjej6Ag/ceFqfJxsJzGz38sNCRJZFZm3lTcioySwpSXvvSOkjA
         bJaDgECgjbuMNwczvmVIq4ciKn1aYmhNOB544b+BJrrjhnepqoA75oRtey9e3N2E+Ea3
         FbozNb7Q6xGUUQod0LJfYGPx1rQHEPqpdZmRjg6KZqGvbxUUyfHbd/fpfxfrz1xjkJFr
         CYsyGZRA9LVE5I2e+X9xL/3ZcwPaQnD3jVRm76Bdn1xIDDhBM3cPHy7s2A7YWbSzPd8F
         eDPg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=KaCACouyWcP3AHn7c7rvYHXFAgfIP9iLxHVqu/otoeA=;
        b=psyiK2jo34I8BDC9IdaVl9UzaKgeJ/TzOrHM/ieZU5MJV2KqbFIUrzxo11mckvTl5X
         6rFRlssh4oNSYLCeAfZ1q6aOCkJS+ZGVofAMcP9iPldvVBme4aQDcUhkHGfg2p5SMosm
         asw45izFViRsPRykyvWb6ozoVomf6KtlzmdImLcPNtUdTXke1FyxKatISRKJh7Ug21vE
         q1QZ06PD66JZ0PweyGdqrnVxGMbJD5XwYPKi6PC2X4bdm/BEkG7RmPhBcBZV0VGzf2Te
         zeMLM2clHTuEfoePkQDZvlNrne1nltghOe4yX5p5dSSdriY18EK3aYW8fbHiUJj+shNG
         lMUg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=uFjpHN01;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id r8si1521937plo.203.2019.02.07.09.24.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 07 Feb 2019 09:24:09 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=uFjpHN01;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=KaCACouyWcP3AHn7c7rvYHXFAgfIP9iLxHVqu/otoeA=; b=uFjpHN01utFKoX5XohZKeYMVc
	dy3QXKNe+IGOmuHAt7tMQhY29FNWyN1wCCP7aB09vF7xxiK+W/3f5jDFt/TsnOx5hrOEVHD79bqJg
	oRpfGDj14NXeY2ZFeJ8HUn/Le2lCmWCMfiOB+ISwJKuv2+cexAax5pwwGsn61TQe7bWf9fzmdNFji
	0116U/IZY1pvA6mg2+Y2jvBLyeoBdBphTe3n4cEYzwMC9/mR4UmV+EXC0bKMpys+HvtvcgKLSbCJ4
	xdwbOotNdPfbXC7joW4xQCquZpeRBXTVD/AXGacSx54m6M/ncB7wKq0yMenS9s9hm7yw/iFCeCTEd
	l6r802ZNw==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1grnPC-0001CL-1M; Thu, 07 Feb 2019 17:24:06 +0000
Date: Thu, 7 Feb 2019 09:24:05 -0800
From: Matthew Wilcox <willy@infradead.org>
To: Doug Ledford <dledford@redhat.com>
Cc: Dan Williams <dan.j.williams@intel.com>, Jason Gunthorpe <jgg@ziepe.ca>,
	Dave Chinner <david@fromorbit.com>,
	Christopher Lameter <cl@linux.com>, Jan Kara <jack@suse.cz>,
	Ira Weiny <ira.weiny@intel.com>, lsf-pc@lists.linux-foundation.org,
	linux-rdma <linux-rdma@vger.kernel.org>,
	Linux MM <linux-mm@kvack.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	John Hubbard <jhubbard@nvidia.com>,
	Jerome Glisse <jglisse@redhat.com>,
	Michal Hocko <mhocko@kernel.org>
Subject: Re: [LSF/MM TOPIC] Discuss least bad options for resolving
 longterm-GUP usage by RDMA
Message-ID: <20190207172405.GY21860@bombadil.infradead.org>
References: <20190206095000.GA12006@quack2.suse.cz>
 <20190206173114.GB12227@ziepe.ca>
 <20190206175233.GN21860@bombadil.infradead.org>
 <47820c4d696aee41225854071ec73373a273fd4a.camel@redhat.com>
 <01000168c43d594c-7979fcf8-b9c1-4bda-b29a-500efe001d66-000000@email.amazonses.com>
 <20190206210356.GZ6173@dastard>
 <20190206220828.GJ12227@ziepe.ca>
 <0c868bc615a60c44d618fb0183fcbe0c418c7c83.camel@redhat.com>
 <CAPcyv4hqya1iKCfHJRXQJRD4qXZa3VjkoKGw6tEvtWNkKVbP+A@mail.gmail.com>
 <bfe0fdd5400d41d223d8d30142f56a9c8efc033d.camel@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <bfe0fdd5400d41d223d8d30142f56a9c8efc033d.camel@redhat.com>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Feb 07, 2019 at 11:25:35AM -0500, Doug Ledford wrote:
> * Really though, as I said in my email to Tom Talpey, this entire
> situation is simply screaming that we are doing DAX networking wrong. 
> We shouldn't be writing the networking code once in every single
> application that wants to do this.  If we had a memory segment that we
> shared from server to client(s), and in that memory segment we
> implemented a clustered filesystem, then applications would simply mmap
> local files and be done with it.  If the file needed to move, the kernel
> would update the mmap in the application, done.  If you ask me, it is
> the attempt to do this the wrong way that is resulting in all this
> heartache.  That said, for today, my recommendation would be to require
> ODP hardware for XFS filesystem with the DAX option, but allow ext2
> filesystems to mount DAX filesystems on non-ODP hardware, and go in and
> modify the ext2 filesystem so that on DAX mounts, it disables hole punch
> and ftrunctate any time they would result in the forced removal of an
> established mmap.

I agree that something's wrong, but I think the fundamental problem is
that there's no concept in RDMA of having an STag for storage rather
than for memory.

Imagine if we could associate an STag with a file descriptor on the
server.  The client could then perform an RDMA to that STag.  On the
server, we'd need lots of smarts in the card and in the OS to know how
to treat that packet on arrival -- depending on what the file descriptor
referred to, it might only have to write into the page cache, or it
might set up an NVMe DMA, or it might resolve the underlying physical
address and DMA directly to an NV-DIMM.

