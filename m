Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 79BB6C46477
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 23:58:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 454FE207E0
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 23:58:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 454FE207E0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DCF6F6B000E; Thu, 13 Jun 2019 19:58:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D81C26B0266; Thu, 13 Jun 2019 19:58:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C95536B026A; Thu, 13 Jun 2019 19:58:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 94BB86B000E
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 19:58:52 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id z1so410815pfb.7
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 16:58:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=fHCZCkYS3xfgL7YswiEhaH5vXkW2o8h20LOkbgBn1RU=;
        b=oHPu/Z7vCAmyf1OxsIdYyhXicm8kbef8w5YfTkAaiWLmnXuZjj+C4ARvXcNdwGDSA0
         hqozA+iiJcGIpgkt7JaDDzIWoKI/Y9BeEBICC/pklfk2AQXgHu+xUdRar6IMWeFDDIvs
         9RFJJzdy5wUckkIA7bIFK9dB/r/YkPasglgP2o5odgMjv6x4DOIn8dNwagzpmwoP/5f6
         Z5ItjvoBY0DsMV7sK15YUta5J10XMXwej3yPI8oJb6Y26QYLeZoqu0mmtWu1R0ekRULs
         vb9CVZExHF7ycW3u8++ib5F3ZeO3IFg7frvoKJi61dK1oZnfcwGx3zlJNUq7X/6fmoDz
         UHNg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVx0UIxiCsprLZdSFDM86jDtF3HagzvZ4x1SqCEyrdnT389i0Ui
	+r8ToWgSHUrvVH+PVCcolJI4GywsdVn2kl5r4DS7slbbFvG1Sp6aO6eNsARHT/PoVi3RuogJLj4
	uWotkJnY9o6aLOapDEhijm7cTQSTQB75nHOuRqyexbgQNUJ10J6ZFAcifG/zDi/m/Yg==
X-Received: by 2002:a63:6948:: with SMTP id e69mr22184255pgc.441.1560470332177;
        Thu, 13 Jun 2019 16:58:52 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz/2aV6k2Tk9BxzRxLlV7pHo1HAnNCK4YVZrAuygH3Wlyak3jvBIl1eoj9zA1AvtHFHarSV
X-Received: by 2002:a63:6948:: with SMTP id e69mr22184207pgc.441.1560470331259;
        Thu, 13 Jun 2019 16:58:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560470331; cv=none;
        d=google.com; s=arc-20160816;
        b=E+0Ae9CaqhysFNVYxUD6HrLgKo6lhASmzuEpqtfP3yg6s0QUUo5oLkK4PQ3NnmiEla
         2OqKfO2A7KWWeVFK3TeKYIrHzYoKdDPZ7hbvs7MkEES69d7IC9TpMBA0naDSS+n3ardz
         z6TtxvRGPXBsyw+bLcpsFBIoNRBNpwKRLqLDqcpnxB7/+bWwO+wSC+MJXE7AeR9wTT16
         oXrNs+98wObqZ2vpkEt7apc4AW+1UyglUM/kijbgexNuPBktyGhO3aXpr/op4sz1j3eC
         QylabXNXtKyhRcaKHeG9hCkuFgE4RYFJxoBEh0rIrUwR7ngXlQHCJFydKLUsvftrxnhX
         hg6w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=fHCZCkYS3xfgL7YswiEhaH5vXkW2o8h20LOkbgBn1RU=;
        b=TAsvJepyJSpx3ibMzkAcfvU6hUvXGf0uFFqPuOD6/pombMShuSaUP446Jy7OSFbzRD
         lJP8ZxO56/ylRB0kK/trn6Kb9fKqiHSBjc5HolQwnnQQrdGC93PWnH4V0Sg0hArStKcz
         FomWWV5rYNpn0PEOt/NnBMa0kdCLfc/BbbbNc7r4D89um3Q6ya47/dAz9GHnEqreoIFI
         g+HLfjTjUmyEqqzQJMkFnEp51QsozYx/VLVNrQuO5EzOhpW/BPbwo1CXbnKNufR2ZuQj
         9SUZe3eO5lpLMbkFq4MDxo9+PEVKLRZobT7nOIG0F+Z4ARljDkqgzxWmr4yxM/27kovC
         rqSw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id k137si954209pga.59.2019.06.13.16.58.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Jun 2019 16:58:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.43 as permitted sender) client-ip=192.55.52.43;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from fmsmga007.fm.intel.com ([10.253.24.52])
  by fmsmga105.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 13 Jun 2019 16:58:50 -0700
X-ExtLoop1: 1
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by fmsmga007.fm.intel.com with ESMTP; 13 Jun 2019 16:58:49 -0700
Date: Thu, 13 Jun 2019 17:00:11 -0700
From: Ira Weiny <ira.weiny@intel.com>
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Matthew Wilcox <willy@infradead.org>,
	Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>,
	Dan Williams <dan.j.williams@intel.com>,
	Theodore Ts'o <tytso@mit.edu>, Jeff Layton <jlayton@kernel.org>,
	linux-xfs@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	John Hubbard <jhubbard@nvidia.com>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-nvdimm@lists.01.org, linux-ext4@vger.kernel.org,
	linux-mm@kvack.org, linux-rdma@vger.kernel.org
Subject: Re: [PATCH RFC 00/10] RDMA/FS DAX truncate proposal
Message-ID: <20190614000010.GA783@iweiny-DESK2.sc.intel.com>
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
User-Agent: Mutt/1.11.1 (2018-12-01)
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

Oh sorry I miss read the above...  (got Process A and  B mixed up...)

Right, but Process A still can't free those blocks because the gup pin exists
on them...  So yea it can't _just_ be a layout lease which controls this on the
"file fd".

Ira

