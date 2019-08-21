Return-Path: <SRS0=I31T=WR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BEDFBC3A59E
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 19:09:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 865A9216F4
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 19:09:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 865A9216F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3B74B6B0296; Wed, 21 Aug 2019 15:09:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3673F6B0297; Wed, 21 Aug 2019 15:09:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 27CEF6B0298; Wed, 21 Aug 2019 15:09:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0100.hostedemail.com [216.40.44.100])
	by kanga.kvack.org (Postfix) with ESMTP id 007246B0296
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 15:09:06 -0400 (EDT)
Received: from smtpin26.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id B71A2180AD801
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 19:09:06 +0000 (UTC)
X-FDA: 75847372692.26.page17_4f7ac4fe44304
X-HE-Tag: page17_4f7ac4fe44304
X-Filterd-Recvd-Size: 3915
Received: from mga01.intel.com (mga01.intel.com [192.55.52.88])
	by imf16.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 19:09:05 +0000 (UTC)
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from fmsmga008.fm.intel.com ([10.253.24.58])
  by fmsmga101.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 21 Aug 2019 12:09:04 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.64,412,1559545200"; 
   d="scan'208";a="178594638"
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by fmsmga008.fm.intel.com with ESMTP; 21 Aug 2019 12:09:04 -0700
Date: Wed, 21 Aug 2019 12:09:04 -0700
From: Ira Weiny <ira.weiny@intel.com>
To: John Hubbard <jhubbard@nvidia.com>
Cc: Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>,
	Andrew Morton <akpm@linux-foundation.org>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	Dan Williams <dan.j.williams@intel.com>,
	Matthew Wilcox <willy@infradead.org>, Theodore Ts'o <tytso@mit.edu>,
	Michal Hocko <mhocko@suse.com>, linux-xfs@vger.kernel.org,
	linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, linux-nvdimm@lists.01.org,
	linux-ext4@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [RFC PATCH v2 00/19] RDMA/FS DAX truncate proposal V1,000,002 ;-)
Message-ID: <20190821190904.GD5965@iweiny-DESK2.sc.intel.com>
References: <20190815130558.GF14313@quack2.suse.cz>
 <20190816190528.GB371@iweiny-DESK2.sc.intel.com>
 <20190817022603.GW6129@dread.disaster.area>
 <20190819063412.GA20455@quack2.suse.cz>
 <20190819092409.GM7777@dread.disaster.area>
 <ae64491b-85f8-eeca-14e8-2f09caf8abd2@nvidia.com>
 <20190820012021.GQ7777@dread.disaster.area>
 <84318b51-bd07-1d9b-d842-e65cac2ff484@nvidia.com>
 <20190820033608.GB1119@dread.disaster.area>
 <29c89d84-d847-0221-70a7-9e5a3d472cda@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <29c89d84-d847-0221-70a7-9e5a3d472cda@nvidia.com>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Aug 21, 2019 at 11:43:30AM -0700, John Hubbard wrote:
> On 8/19/19 8:36 PM, Dave Chinner wrote:
> > On Mon, Aug 19, 2019 at 08:09:33PM -0700, John Hubbard wrote:
> > > On 8/19/19 6:20 PM, Dave Chinner wrote:
> > > > On Mon, Aug 19, 2019 at 05:05:53PM -0700, John Hubbard wrote:
> > > > > On 8/19/19 2:24 AM, Dave Chinner wrote:
> > > > > > On Mon, Aug 19, 2019 at 08:34:12AM +0200, Jan Kara wrote:
> > > > > > > On Sat 17-08-19 12:26:03, Dave Chinner wrote:
> > > > > > > > On Fri, Aug 16, 2019 at 12:05:28PM -0700, Ira Weiny wrote:
> > > > > > > > > On Thu, Aug 15, 2019 at 03:05:58PM +0200, Jan Kara wrote:
> > > > > > > > > > On Wed 14-08-19 11:08:49, Ira Weiny wrote:
> > > > > > > > > > > On Wed, Aug 14, 2019 at 12:17:14PM +0200, Jan Kara wrote:
> > > > > ...
> > AFAIA, there is no struct file here - the memory that has been pinned
> > is just something mapped into the application's address space.
> > 
> > It seems to me that the socket here is equivalent of the RDMA handle
> > that that owns the hardware that pins the pages. Again, that RDMA
> > handle is not aware of waht the mapping represents, hence need to
> > hold a layout lease if it's a file mapping.
> > 
> > SO from the filesystem persepctive, there's no difference between
> > XDP or RDMA - if it's a FSDAX mapping then it is DMAing directly
> > into the filesystem's backing store and that will require use of
> > layout leases to perform safely.
> > 
> 
> OK, got it! Makes perfect sense.

Just to chime in here... Yea from the FS perspective it is the same.

But on the driver side it is more complicated because of how the references to
the pins can be shared among other processes.

See the other branch of this thread

https://lkml.org/lkml/2019/8/21/828

Ira

> 
> thanks,
> -- 
> John Hubbard
> NVIDIA

