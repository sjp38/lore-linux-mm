Return-Path: <SRS0=aN9C=WJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 67EB1C32757
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 11:47:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2CBBA2067D
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 11:47:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="QCZ4PvH+"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2CBBA2067D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B73406B0005; Tue, 13 Aug 2019 07:47:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B249A6B0006; Tue, 13 Aug 2019 07:47:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A11426B0007; Tue, 13 Aug 2019 07:47:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0152.hostedemail.com [216.40.44.152])
	by kanga.kvack.org (Postfix) with ESMTP id 7B8A16B0005
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 07:47:09 -0400 (EDT)
Received: from smtpin01.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 143DD8248AA1
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 11:47:09 +0000 (UTC)
X-FDA: 75817228578.01.scale82_78902c41d7a4e
X-HE-Tag: scale82_78902c41d7a4e
X-Filterd-Recvd-Size: 5342
Received: from mail-qt1-f195.google.com (mail-qt1-f195.google.com [209.85.160.195])
	by imf46.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 11:47:08 +0000 (UTC)
Received: by mail-qt1-f195.google.com with SMTP id l9so105906201qtu.6
        for <linux-mm@kvack.org>; Tue, 13 Aug 2019 04:47:08 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=A5jSIc/RY/hZ7f+bEkMhOVRTEXKJZMsh3LcoJICOYZA=;
        b=QCZ4PvH+HERINAIC/rIX57CfHFpykExOSCWoiRBdSClOqTC5WAYKVE/wNtLd1ZCdXb
         KZp5v/22WAqZ0EMeHD9gQcL9jjBHQrauhwB1tY41cMyXOMQcHirf3q33hSp3+J4vow0U
         GPXzEq3gqF2wrMV1Rw/sgqnEqIShtnXpz04NN7ACpnW2Kb2z/8KWS7MN/hESlyb75tlS
         YMQH3uuf6z8f1q/jLKcYyFLyOZd7D+SDwoKD8lO4RahnM5opPz9OKgrwrp/X5BI8wvMd
         OzyT60/eIe57jrf+8q2zyLqpHM8YRV9JQevqDnSiRM5+NRuM8rm/DiPdBJOWMMsLftQz
         b4GQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to:user-agent;
        bh=A5jSIc/RY/hZ7f+bEkMhOVRTEXKJZMsh3LcoJICOYZA=;
        b=fn34xxC2b96NpDQLk/o7mVgVOmmPEsfZk6jrcIguWDVuU3sRv4pk88eqwZ2A+wJwE2
         ndVrzsV1++g19sUYT1DwK2bPUfzvZ1L/IBUZE3+GjFxitdY3tKkedoR5hMHGLu+bRji3
         v9WV5K9h1rLMXPYRL7+G0/0s2b1WmJV0LzMKArUcvTlCX9A/5N7OQt6RhcuXYW95BCz2
         3GGwT6Pmbzk2sXleU5N2HIALScn+YhWTmXZJ2PQlAPMMwUOIh2lD4OJ7EfKL0ph2JvPM
         Ra4ygwaREqhwZ+YvqLkU0K9JnUIhvZ3sIkicP3LuN1Tx/TIcG/GW4agQirRKo1Lf1+ZA
         4RYg==
X-Gm-Message-State: APjAAAUI9wdFgN90TPjAvDjV74VxSD9j/zsAHvHSbb3UnOHbxzPZAmxh
	rNZ16IijUpH9N29t22OjI/Jcug==
X-Google-Smtp-Source: APXvYqxNaQQNPStukKuBzbe7ho0VUZGNKPG9lP34sc9j+nxvDvhp77mkTMuiRQNU50cP5mt/nBqv4g==
X-Received: by 2002:ac8:3f86:: with SMTP id d6mr30794575qtk.346.1565696827682;
        Tue, 13 Aug 2019 04:47:07 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id 67sm47417797qkh.108.2019.08.13.04.47.06
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 13 Aug 2019 04:47:07 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hxVGc-0007jx-3A; Tue, 13 Aug 2019 08:47:06 -0300
Date: Tue, 13 Aug 2019 08:47:06 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Ira Weiny <ira.weiny@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Dan Williams <dan.j.williams@intel.com>,
	Matthew Wilcox <willy@infradead.org>, Jan Kara <jack@suse.cz>,
	Theodore Ts'o <tytso@mit.edu>, John Hubbard <jhubbard@nvidia.com>,
	Michal Hocko <mhocko@suse.com>, Dave Chinner <david@fromorbit.com>,
	linux-xfs@vger.kernel.org, linux-rdma@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	linux-nvdimm@lists.01.org, linux-ext4@vger.kernel.org,
	linux-mm@kvack.org
Subject: Re: [RFC PATCH v2 15/19] mm/gup: Introduce vaddr_pin_pages()
Message-ID: <20190813114706.GA29508@ziepe.ca>
References: <20190809225833.6657-1-ira.weiny@intel.com>
 <20190809225833.6657-16-ira.weiny@intel.com>
 <20190812122814.GC24457@ziepe.ca>
 <20190812214854.GF20634@iweiny-DESK2.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190812214854.GF20634@iweiny-DESK2.sc.intel.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Aug 12, 2019 at 02:48:55PM -0700, Ira Weiny wrote:
> On Mon, Aug 12, 2019 at 09:28:14AM -0300, Jason Gunthorpe wrote:
> > On Fri, Aug 09, 2019 at 03:58:29PM -0700, ira.weiny@intel.com wrote:
> > > From: Ira Weiny <ira.weiny@intel.com>
> > > 
> > > The addition of FOLL_LONGTERM has taken on additional meaning for CMA
> > > pages.
> > > 
> > > In addition subsystems such as RDMA require new information to be passed
> > > to the GUP interface to track file owning information.  As such a simple
> > > FOLL_LONGTERM flag is no longer sufficient for these users to pin pages.
> > > 
> > > Introduce a new GUP like call which takes the newly introduced vaddr_pin
> > > information.  Failure to pass the vaddr_pin object back to a vaddr_put*
> > > call will result in a failure if pins were created on files during the
> > > pin operation.
> > 
> > Is this a 'vaddr' in the traditional sense, ie does it work with
> > something returned by valloc?
> 
> ...or malloc in user space, yes.  I think the idea is that it is a user virtual
> address.

valloc is a kernel call

> So I'm open to suggestions.  Jan gave me this one, so I figured it was safer to
> suggest it...

Should have the word user in it, imho

> > I also wish GUP like functions took in a 'void __user *' instead of
> > the unsigned long to make this clear :\
> 
> Not a bad idea.  But I only see a couple of call sites who actually use a 'void
> __user *' to pass into GUP...  :-/
> 
> For RDMA the address is _never_ a 'void __user *' AFAICS.

That is actually a bug, converting from u64 to a 'user VA' needs to go
through u64_to_user_ptr().

Jason

