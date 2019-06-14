Return-Path: <SRS0=BXMS=UN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5DB42C31E45
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 02:10:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 13BDC20866
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 02:10:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 13BDC20866
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fromorbit.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A5E686B000D; Thu, 13 Jun 2019 22:10:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9E91B6B000E; Thu, 13 Jun 2019 22:10:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 889C46B0266; Thu, 13 Jun 2019 22:10:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4EDCA6B000D
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 22:10:25 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id s22so677820plp.5
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 19:10:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=0tXLkaCzSLVqIRJBBy/+3qJ537JyS734Ml26tc3myCY=;
        b=JTKd3yicPaqseK8TPS1XdzMncgvJtQPfDuy/UNQpddJobBfQFNcmBmzcxnS3PbKUh+
         M7okTeI19zoEte/lfOlH5lqeexG6VwctYDyWI6buf79CA0B58yb0eD2rISfuoE+kjPmj
         DMAHeCmGi/fi9eN2VGfCAPjI9W6lzGnpqmyj1GEJhTRsUDbvK0m3/yJrZh94CdvAjhj1
         Yg/YJ/Ca9g3dwvg4FeVMcwkN8/n3Gce0LMA3zhLAjc8kDJ/C4aOI5pYSfb52olOMAjyl
         aWzZSPAxs7YX21UJoCdpqLpiaUyrYUCp9meM8GAwstcq0d9r/eE9NrNgwqEdZI9r5vm7
         tTzg==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 211.29.132.42 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
X-Gm-Message-State: APjAAAXvZpDr8CJ+eumFtTOEPu+k+cNrW4SzCVg8iNzHIJ2L/ZyihxFS
	MHt6HzKGDsto1ckZvZmR2qIsC+YkVEPrN3jAtlKAWjPdA6qOIzxpbzF/NOayz+B9lqQziu2uncd
	H3YyZ/nUx0b3T3D/YrAv5bxdWzY2Yetz4kYLe0Ge6JlylXrrg+caHpuetTaylcBg=
X-Received: by 2002:a65:63c3:: with SMTP id n3mr13252767pgv.139.1560478224724;
        Thu, 13 Jun 2019 19:10:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyYisjueb83d9NiApKwR+/wSTId5q1dFHH1+Tjncb6G+ZYXJFkOSiRhwC+pZDsUzmigONgZ
X-Received: by 2002:a65:63c3:: with SMTP id n3mr13252710pgv.139.1560478223614;
        Thu, 13 Jun 2019 19:10:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560478223; cv=none;
        d=google.com; s=arc-20160816;
        b=WkFzvDYztkqint++py7fqgj3TWc+uVGxsZEDqTO+3wDjuBHUtYTC/t7ymuAIqoTl8y
         L/n3cprFEEnt9mRPvxMtXTNz8k7KUzJTI5a/E/X8aGyGNy4OIfgvogExdfYrLuSvpePB
         hRUL9WYrugt+3yuvYjt57QlcGEUzOkE1tugGEMDzN1ihkbX2wjTBN6ljqspfC8vRM2k5
         SDd7PR9pFpYtKeviaKyLYeXK2S5zO30ibXjRwyDUeLdistnT7NRX0Fp/T6XnHj8VQqiE
         0Ym8vhJagbPZXpklLAblwI5UwvFtqplDJF7oBOS1cczJaSkXmLpkgK49YVbcSU5wqu0N
         ei2Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=0tXLkaCzSLVqIRJBBy/+3qJ537JyS734Ml26tc3myCY=;
        b=xJIm9FfpFXFmkMTvwQWCiGToEdu3evlTXUUV8RGRB/dyaJgOgl/YQNQLd8Ds3DGIYH
         cGYgwUab0p+Yk04nMvdk+iKMmWYeCmDrhVT9HBss1iMroHMaXfT4V4DKuH5y65Kj97IE
         zTcbJLZ3/FeC6Ionu+0cYQ0xqsE4qpUmmRjluwGBWZjnG8OmFtHvbTAtANObiU89p9tY
         iE6JwGbsx4Zq5DEqpXQKkFILq04JOLWJJGeszMPhyTVcftemwa85+ypHdDHCCbY+HJbO
         YZ1NkqwP/VMIzfq2Pa8WJ9R2aTzIUZswMmMsEz1Fba2+jIO/WWEQMeklgkds+pTsYAZb
         UoPQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 211.29.132.42 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from mail106.syd.optusnet.com.au (mail106.syd.optusnet.com.au. [211.29.132.42])
        by mx.google.com with ESMTP id t25si1160718pgk.442.2019.06.13.19.10.23
        for <linux-mm@kvack.org>;
        Thu, 13 Jun 2019 19:10:23 -0700 (PDT)
Received-SPF: neutral (google.com: 211.29.132.42 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) client-ip=211.29.132.42;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 211.29.132.42 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from dread.disaster.area (pa49-195-189-25.pa.nsw.optusnet.com.au [49.195.189.25])
	by mail106.syd.optusnet.com.au (Postfix) with ESMTPS id 6E77A3DCE8B;
	Fri, 14 Jun 2019 12:10:19 +1000 (AEST)
Received: from dave by dread.disaster.area with local (Exim 4.92)
	(envelope-from <david@fromorbit.com>)
	id 1hbbeb-0005G5-AA; Fri, 14 Jun 2019 12:09:21 +1000
Date: Fri, 14 Jun 2019 12:09:21 +1000
From: Dave Chinner <david@fromorbit.com>
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Ira Weiny <ira.weiny@intel.com>, Matthew Wilcox <willy@infradead.org>,
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
Message-ID: <20190614020921.GM14363@dread.disaster.area>
References: <20190606104203.GF7433@quack2.suse.cz>
 <20190606220329.GA11698@iweiny-DESK2.sc.intel.com>
 <20190607110426.GB12765@quack2.suse.cz>
 <20190607182534.GC14559@iweiny-DESK2.sc.intel.com>
 <20190608001036.GF14308@dread.disaster.area>
 <20190612123751.GD32656@bombadil.infradead.org>
 <20190613002555.GH14363@dread.disaster.area>
 <20190613152755.GI32656@bombadil.infradead.org>
 <20190613211321.GC32404@iweiny-DESK2.sc.intel.com>
 <20190613234530.GK22901@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190613234530.GK22901@ziepe.ca>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Optus-CM-Score: 0
X-Optus-CM-Analysis: v=2.2 cv=D+Q3ErZj c=1 sm=1 tr=0 cx=a_idp_d
	a=K5LJ/TdJMXINHCwnwvH1bQ==:117 a=K5LJ/TdJMXINHCwnwvH1bQ==:17
	a=jpOVt7BSZ2e4Z31A5e1TngXxSK0=:19 a=kj9zAlcOel0A:10 a=dq6fvYVFJ5YA:10
	a=7-415B0cAAAA:8 a=MIoJepgKeDxvTzH8FPQA:9 a=CjuIK1q_8ugA:10
	a=biEYGPWJfzWAr4FL6Ov7:22
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 13, 2019 at 08:45:30PM -0300, Jason Gunthorpe wrote:
> On Thu, Jun 13, 2019 at 02:13:21PM -0700, Ira Weiny wrote:
> > On Thu, Jun 13, 2019 at 08:27:55AM -0700, Matthew Wilcox wrote:
> > > On Thu, Jun 13, 2019 at 10:25:55AM +1000, Dave Chinner wrote:
> > > > e.g. Process A has an exclusive layout lease on file F. It does an
> > > > IO to file F. The filesystem IO path checks that Process A owns the
> > > > lease on the file and so skips straight through layout breaking
> > > > because it owns the lease and is allowed to modify the layout. It
> > > > then takes the inode metadata locks to allocate new space and write
> > > > new data.
> > > > 
> > > > Process B now tries to write to file F. The FS checks whether
> > > > Process B owns a layout lease on file F. It doesn't, so then it
> > > > tries to break the layout lease so the IO can proceed. The layout
> > > > breaking code sees that process A has an exclusive layout lease
> > > > granted, and so returns -ETXTBSY to process B - it is not allowed to
> > > > break the lease and so the IO fails with -ETXTBSY.
> > > 
> > > This description doesn't match the behaviour that RDMA wants either.
> > > Even if Process A has a lease on the file, an IO from Process A which
> > > results in blocks being freed from the file is going to result in the
> > > RDMA device being able to write to blocks which are now freed (and
> > > potentially reallocated to another file).
> > 
> > I don't understand why this would not work for RDMA?  As long as the layout
> > does not change the page pins can remain in place.
> 
> Because process A had a layout lease (and presumably a MR) and the
> layout was still modified in way that invalidates the RDMA MR.

The lease holder is allowed to modify the mapping it has a lease
over. That's necessary so lease holders can write data into
unallocated space in the file. The lease is there to prevent third
parties from modifying the layout without the lease holder being
informed and taking appropriate action to allow that 3rd party
modification to occur.

If the lease holder modifies the mapping in a way that causes it's
own internal state to screw up, then that's a bug in the lease
holder application.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

