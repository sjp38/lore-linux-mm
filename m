Return-Path: <SRS0=0yrr=TY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AF602C072B5
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 17:52:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5A98220879
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 17:52:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="VCjAMtvr"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5A98220879
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0AFE56B0281; Fri, 24 May 2019 13:52:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 062006B0282; Fri, 24 May 2019 13:52:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E92FE6B0283; Fri, 24 May 2019 13:52:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ua1-f69.google.com (mail-ua1-f69.google.com [209.85.222.69])
	by kanga.kvack.org (Postfix) with ESMTP id C69766B0281
	for <linux-mm@kvack.org>; Fri, 24 May 2019 13:52:05 -0400 (EDT)
Received: by mail-ua1-f69.google.com with SMTP id y2so2369109ual.15
        for <linux-mm@kvack.org>; Fri, 24 May 2019 10:52:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=c+rg9b6r0Ck12KGDIIHf4Mjd6CCd8h8PIMGpeDnJK64=;
        b=dDJa59oxlNWjCG/MDHyj5PvjqZsDJbW7X/8w/yoY0yYqT0RxvZGfG4fmvRCss8kixZ
         +WmZTrTHJPgE/UTlyImNER55N1schNNcjELzh5HEDMuEaGzMQHVo2D2kv6kITuSrASe5
         Ir7Yze/rrabYcGdE7OyELcGWY7Z3Vu6xaZ3UWKzW7xM7g7NQnzyYnbMqc+5MXLJ0g73F
         jzpddCmRl9R75Y1tCTUkw/dcjaktJJB/Zeg0ZWBugH/ToqrpcAEdSEU/Lzffgu1n2c9b
         LBEAcctLT00iGSRVi7j71Awdpl0j/+3EqnxaIftfQ0a7+Ipi9p7esUP42GoZ7IPVJjA1
         eoyQ==
X-Gm-Message-State: APjAAAUwKaIVF+EEz2dAYRxyWv+cmsRoIsxVgK4+HKoqTJQJsTYnAceK
	e33LTLm61m8Bfe6dAJ6/S+tmMby869U6fBx3peczAWiTe04SKruFUh2hQ1onQjb3suvyksvTWtV
	HnXzqdl9TsUuvQ7S/dVIp4J/pliZ02YrcfpZ1/PGfetQ9dWFRNT9dnamBz8h0ZgyxUA==
X-Received: by 2002:ab0:3058:: with SMTP id x24mr14779040ual.95.1558720325515;
        Fri, 24 May 2019 10:52:05 -0700 (PDT)
X-Received: by 2002:ab0:3058:: with SMTP id x24mr14778969ual.95.1558720324858;
        Fri, 24 May 2019 10:52:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558720324; cv=none;
        d=google.com; s=arc-20160816;
        b=qLxUQ62ehJSP6QodnlALV+vyFEr66jLgLpiEaFKe5gSI3XFwFq4q1g3xunZnH8/npt
         tfbU9c4yIe9qcfIeksgGDICdKm9vgDJVM0aJQ3kvNGuQ1LoaGbe1rdbLjbtAtY23PzNa
         s3SCZeyOBhUGHCb7+PPoUVq2Nv8o87c3nHb4QSD51+GVBLenX5LVmk+8KHXEdCc6kd3H
         Mw9ZN7WBwmbHNfQbG1ettMtuvMimbsdjKDNX4dy+XzpZMwpvcNoPk3B2BFhRXJT67whm
         Z4LLLiTasjtUp3q3R6ugppQv7opSIO+DIE16FR1gpbWpaFEB5f1Sq9YTwODxPMwL2s3K
         ddEA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=c+rg9b6r0Ck12KGDIIHf4Mjd6CCd8h8PIMGpeDnJK64=;
        b=ITOyjfiWY5uHgZs4xVr8UkVJCJVHRM6LL4gIJnJLAPBDxz6x4Q29KGgnJIxqvgiIyM
         2hLPcYLlKnFNb1Cn77mp4P2IKhiJbEqbnsBnA7i2Tg5kB/r4CIF3fsXasMjjt0G2ckgp
         TE868KYpYRgLA7D+Qt3k2qE4rOgNm1Ou5J7nXsKAp9itjBUVV90tbQtW/tfVhj5WmKxC
         FLnIE6vwYEUJLzJGKVzkVgOBUIoGFslgZRCFSzT0QRMVc5e8vNTWhhrCGo6pp4f3PO1b
         dVbDLm2IU3BUGgOd3f869IrnP5WCAFt/aErHQOliHcHzJMeJjcR9HrvMk/7WJKmPalND
         jeSA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=VCjAMtvr;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s12sor812652vkf.53.2019.05.24.10.52.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 24 May 2019 10:52:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=VCjAMtvr;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=c+rg9b6r0Ck12KGDIIHf4Mjd6CCd8h8PIMGpeDnJK64=;
        b=VCjAMtvrb+TKSVvfjv/E5qoiSgGpnMPZG3YnUFjIkSTBAWtqQ/ovAahyHASG1biPB1
         8PWpUm1LOHNvc510wWJoI2pq5trdF+7ufxXoUcA4EKPBmCBd+MYTt9FrKRhE0fqaT7bR
         k3jfL6PvxnvESSxl7A/yNdmTyAaYePpuXmc1ArqiP3d+vgxUw35RoVEvZL0QNByBuVDf
         vPW454PtGcprZxs/J+5IXcTvmG4M08BnZ5hEBIrPlXC3TXOJF/XZtAgjJ0MEv5Q6hrz9
         Hw2NrQdkiVFib+YxWloX7LjQ/VLJPO7tfS5z0Q390+7cGnOn1tqsQoQxibD3GbGu5O6o
         wMYg==
X-Google-Smtp-Source: APXvYqwMCPgTCNq3GF7Ypgkdwg24jSDdOVt2u6iTnBQLRZ6zlSxp9CQmNF2rPsG9xY7T4Hw/AaYJhA==
X-Received: by 2002:a1f:b44b:: with SMTP id d72mr6596646vkf.29.1558720324467;
        Fri, 24 May 2019 10:52:04 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-49-251.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.49.251])
        by smtp.gmail.com with ESMTPSA id 142sm2125089vkp.56.2019.05.24.10.52.03
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 24 May 2019 10:52:04 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hUEMN-0000yB-HG; Fri, 24 May 2019 14:52:03 -0300
Date: Fri, 24 May 2019 14:52:03 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Jerome Glisse <jglisse@redhat.com>
Cc: linux-rdma@vger.kernel.org, linux-mm@kvack.org,
	Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>
Subject: Re: [RFC PATCH 00/11] mm/hmm: Various revisions from a locking/code
 review
Message-ID: <20190524175203.GG16845@ziepe.ca>
References: <20190523153436.19102-1-jgg@ziepe.ca>
 <20190524143649.GA14258@ziepe.ca>
 <20190524164902.GA3346@redhat.com>
 <20190524165931.GF16845@ziepe.ca>
 <20190524170148.GB3346@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190524170148.GB3346@redhat.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, May 24, 2019 at 01:01:49PM -0400, Jerome Glisse wrote:
> On Fri, May 24, 2019 at 01:59:31PM -0300, Jason Gunthorpe wrote:
> > On Fri, May 24, 2019 at 12:49:02PM -0400, Jerome Glisse wrote:
> > > On Fri, May 24, 2019 at 11:36:49AM -0300, Jason Gunthorpe wrote:
> > > > On Thu, May 23, 2019 at 12:34:25PM -0300, Jason Gunthorpe wrote:
> > > > > From: Jason Gunthorpe <jgg@mellanox.com>
> > > > > 
> > > > > This patch series arised out of discussions with Jerome when looking at the
> > > > > ODP changes, particularly informed by use after free races we have already
> > > > > found and fixed in the ODP code (thanks to syzkaller) working with mmu
> > > > > notifiers, and the discussion with Ralph on how to resolve the lifetime model.
> > > > 
> > > > So the last big difference with ODP's flow is how 'range->valid'
> > > > works.
> > > > 
> > > > In ODP this was done using the rwsem umem->umem_rwsem which is
> > > > obtained for read in invalidate_start and released in invalidate_end.
> > > > 
> > > > Then any other threads that wish to only work on a umem which is not
> > > > undergoing invalidation will obtain the write side of the lock, and
> > > > within that lock's critical section the virtual address range is known
> > > > to not be invalidating.
> > > > 
> > > > I cannot understand how hmm gets to the same approach. It has
> > > > range->valid, but it is not locked by anything that I can see, so when
> > > > we test it in places like hmm_range_fault it seems useless..
> > > > 
> > > > Jerome, how does this work?
> > > > 
> > > > I have a feeling we should copy the approach from ODP and use an
> > > > actual lock here.
> > > 
> > > range->valid is use as bail early if invalidation is happening in
> > > hmm_range_fault() to avoid doing useless work. The synchronization
> > > is explained in the documentation:
> > 
> > That just says the hmm APIs handle locking. I asked how the apis
> > implement that locking internally.
> > 
> > Are you trying to say that if I do this, hmm will still work completely
> > correctly?
> 
> Yes it will keep working correctly. You would just be doing potentialy
> useless work.

I don't see how it works correctly.

Apply the comment out patch I showed and this trivially happens:

      CPU0                                               CPU1
  hmm_invalidate_start()
    ops->sync_cpu_device_pagetables()
      device_lock()
       // Wipe out page tables in device, enable faulting
      device_unlock()

						     DEVICE PAGE FAULT
						       device_lock()
						       hmm_range_register()
                                                       hmm_range_dma_map()
						       device_unlock()
  hmm_invalidate_end()

The mmu notifier spec says:

 	 * Invalidation of multiple concurrent ranges may be
	 * optionally permitted by the driver. Either way the
	 * establishment of sptes is forbidden in the range passed to
	 * invalidate_range_begin/end for the whole duration of the
	 * invalidate_range_begin/end critical section.

And I understand "establishment of sptes is forbidden" means
"hmm_range_dmap_map() must fail with EAGAIN". 

This is why ODP uses an actual lock held across the critical region
which completely prohibits reading the CPU pages tables, or
establishing new mappings.

So, I still think we need a true lock, not a 'maybe valid' flag.

Jason

