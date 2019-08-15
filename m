Return-Path: <SRS0=30+Z=WL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 04C82C3A589
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 14:51:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B380920656
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 14:51:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="dU2EhV+6"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B380920656
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 620EA6B0298; Thu, 15 Aug 2019 10:51:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5D18C6B029A; Thu, 15 Aug 2019 10:51:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4C0996B029B; Thu, 15 Aug 2019 10:51:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0117.hostedemail.com [216.40.44.117])
	by kanga.kvack.org (Postfix) with ESMTP id 2A2096B0298
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 10:51:05 -0400 (EDT)
Received: from smtpin23.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 5F3E48248AAB
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 14:51:04 +0000 (UTC)
X-FDA: 75824949648.23.soda65_60a104cd0594f
X-HE-Tag: soda65_60a104cd0594f
X-Filterd-Recvd-Size: 4655
Received: from mail-qk1-f194.google.com (mail-qk1-f194.google.com [209.85.222.194])
	by imf37.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 14:51:03 +0000 (UTC)
Received: by mail-qk1-f194.google.com with SMTP id m10so2095064qkk.1
        for <linux-mm@kvack.org>; Thu, 15 Aug 2019 07:51:03 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=z90nPpYO8UuUUSb9IN8rKS3L0KsgC8zXmObZdfo6ctQ=;
        b=dU2EhV+6EWSs1MNrZJWfU76DaiGX5NQgWL4uohTv/GZxgH6FeggKTIKZ+d/6xxWmB5
         Uq7EirJG422MX6svb2pK3O0rmVD5upXZhrC0obDyAVUsClwMUccie10LZ+VusUXs6G5t
         Cfxm7G3duJErwOwTzL6wlTMWxPvhXqi0t55/HXZYJ0ksP5CllSxCeRSJEwA3qeLb3Mw+
         H9tQF6/hs2KVjejIpKYI3tuEWzOasQMSO5OrPdyS6Tf6gZNSrPhr0d7BWVqY895GeZU7
         3vhMlzFvKziDCq6pld4ycFVFRE1zOEJ/X+8kNMBCMNIgJ/nYLqTQqzhkO3QmO9Oxi/p7
         z4xQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to:user-agent;
        bh=z90nPpYO8UuUUSb9IN8rKS3L0KsgC8zXmObZdfo6ctQ=;
        b=JBlIR1uSp5bS6+RNMVB2hpAxNWQNtdvh6/742jBbzp1tvKOTFsLQ48ITN08HBsXnT6
         ki6DjMLzVR6Olwe6L2AVLpX0KWg7/A31I1Lxdw2WcjRDcO+AhbDwtL6af6K6v58p2uKC
         7hBIeRO+JJzpr2QI5KlqRveT9zw7qbgvmrzFM6fBsAMzUQjG3x4U0GQNKuPL/xxLU6pu
         zj9M8kYZfvSKwaRuveDtzSOBAyRd158ayxL9J9YsHIHPng8XXjdK/+QCOZhMYySDfcLb
         queaP1W58iVJlelNOiwrXJ+DJyIm5/lXIv1Tk3D/vw5TuZG4PB1KY6jO8fALoj0kDXfc
         72bw==
X-Gm-Message-State: APjAAAVDTY4A2iZyKY9WPq4rpYgUZwxgCvMwOlmEddvlj4enXHYzDdkB
	KUZ99LXaYzybj9c27GUMJxF6xSaAJxY=
X-Google-Smtp-Source: APXvYqyMHfwmFKSYVNb8WeeauLH7Hep/WJZ+jheCJjAwrLvMcjUnfX6gEreyk5eeamBSEzYzpviglQ==
X-Received: by 2002:a05:620a:71a:: with SMTP id 26mr4357407qkc.374.1565880663323;
        Thu, 15 Aug 2019 07:51:03 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id e15sm805595qtr.51.2019.08.15.07.51.02
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 15 Aug 2019 07:51:02 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hyH5i-0005L9-BH; Thu, 15 Aug 2019 11:51:02 -0300
Date: Thu, 15 Aug 2019 11:51:02 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Jan Kara <jack@suse.cz>
Cc: John Hubbard <jhubbard@nvidia.com>, Ira Weiny <ira.weiny@intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Christoph Hellwig <hch@infradead.org>,
	Dan Williams <dan.j.williams@intel.com>,
	Dave Chinner <david@fromorbit.com>,
	=?utf-8?B?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>,
	LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org, linux-rdma@vger.kernel.org
Subject: Re: [RFC PATCH 2/2] mm/gup: introduce vaddr_pin_pages_remote()
Message-ID: <20190815145102.GH21596@ziepe.ca>
References: <20190812234950.GA6455@iweiny-DESK2.sc.intel.com>
 <38d2ff2f-4a69-e8bd-8f7c-41f1dbd80fae@nvidia.com>
 <20190813210857.GB12695@iweiny-DESK2.sc.intel.com>
 <a1044a0d-059c-f347-bd68-38be8478bf20@nvidia.com>
 <90e5cd11-fb34-6913-351b-a5cc6e24d85d@nvidia.com>
 <20190814234959.GA463@iweiny-DESK2.sc.intel.com>
 <2cbdf599-2226-99ae-b4d5-8909a0a1eadf@nvidia.com>
 <ac834ac6-39bd-6df9-fca4-70b9520b6c34@nvidia.com>
 <20190815132622.GG14313@quack2.suse.cz>
 <20190815133510.GA21302@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190815133510.GA21302@quack2.suse.cz>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 15, 2019 at 03:35:10PM +0200, Jan Kara wrote:

> > 3) ODP case - GUP references to pages serving as DMA buffers, MMU notifiers
> >    used to synchronize with page_mkclean() and munmap() => normal page
> >    references are fine.
> 
> I want to add that I'd like to convert users in cases 1) and 2) from using
> GUP to using differently named function. Users in case 3) can stay as they
> are for now although ultimately I'd like to denote such use cases in a
> special way as well...

3) users also want a special function and path, right now it is called
hmm_range_fault() but perhaps it would be good to harmonize it more
with the GUP infrastructure?

I'm not quite sure what the best plan for that is yet.

Jason

