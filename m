Return-Path: <SRS0=g7KO=WK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2282DC433FF
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 08:06:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E83822084D
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 08:06:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E83822084D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fromorbit.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8C9BC6B000A; Wed, 14 Aug 2019 04:06:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 853F06B000C; Wed, 14 Aug 2019 04:06:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 742766B026F; Wed, 14 Aug 2019 04:06:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0204.hostedemail.com [216.40.44.204])
	by kanga.kvack.org (Postfix) with ESMTP id 5175C6B000A
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 04:06:57 -0400 (EDT)
Received: from smtpin04.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id EE3DC180AD7C1
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 08:06:56 +0000 (UTC)
X-FDA: 75820302432.04.fear73_25a238ede350
X-HE-Tag: fear73_25a238ede350
X-Filterd-Recvd-Size: 4572
Received: from mail105.syd.optusnet.com.au (mail105.syd.optusnet.com.au [211.29.132.249])
	by imf49.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 08:06:56 +0000 (UTC)
Received: from dread.disaster.area (pa49-195-190-67.pa.nsw.optusnet.com.au [49.195.190.67])
	by mail105.syd.optusnet.com.au (Postfix) with ESMTPS id 044DB2AD83C;
	Wed, 14 Aug 2019 18:06:53 +1000 (AEST)
Received: from dave by dread.disaster.area with local (Exim 4.92)
	(envelope-from <david@fromorbit.com>)
	id 1hxoHz-0000t6-39; Wed, 14 Aug 2019 18:05:47 +1000
Date: Wed, 14 Aug 2019 18:05:47 +1000
From: Dave Chinner <david@fromorbit.com>
To: Ira Weiny <ira.weiny@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	Dan Williams <dan.j.williams@intel.com>,
	Matthew Wilcox <willy@infradead.org>, Jan Kara <jack@suse.cz>,
	Theodore Ts'o <tytso@mit.edu>, John Hubbard <jhubbard@nvidia.com>,
	Michal Hocko <mhocko@suse.com>, linux-xfs@vger.kernel.org,
	linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, linux-nvdimm@lists.01.org,
	linux-ext4@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [RFC PATCH v2 01/19] fs/locks: Export F_LAYOUT lease to user
 space
Message-ID: <20190814080547.GJ6129@dread.disaster.area>
References: <20190809225833.6657-1-ira.weiny@intel.com>
 <20190809225833.6657-2-ira.weiny@intel.com>
 <20190809235231.GC7777@dread.disaster.area>
 <20190812173626.GB19746@iweiny-DESK2.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190812173626.GB19746@iweiny-DESK2.sc.intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Optus-CM-Score: 0
X-Optus-CM-Analysis: v=2.2 cv=FNpr/6gs c=1 sm=1 tr=0
	a=TR82T6zjGmBjdfWdGgpkDw==:117 a=TR82T6zjGmBjdfWdGgpkDw==:17
	a=jpOVt7BSZ2e4Z31A5e1TngXxSK0=:19 a=kj9zAlcOel0A:10 a=FmdZ9Uzk2mMA:10
	a=QyXUC8HyAAAA:8 a=7-415B0cAAAA:8 a=368o0BqEERmTqRvZ4WsA:9
	a=CjuIK1q_8ugA:10 a=biEYGPWJfzWAr4FL6Ov7:22
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Aug 12, 2019 at 10:36:26AM -0700, Ira Weiny wrote:
> On Sat, Aug 10, 2019 at 09:52:31AM +1000, Dave Chinner wrote:
> > On Fri, Aug 09, 2019 at 03:58:15PM -0700, ira.weiny@intel.com wrote:
> > > +	/*
> > > +	 * NOTE on F_LAYOUT lease
> > > +	 *
> > > +	 * LAYOUT lease types are taken on files which the user knows that
> > > +	 * they will be pinning in memory for some indeterminate amount of
> > > +	 * time.
> > 
> > Indeed, layout leases have nothing to do with pinning of memory.
> 
> Yep, Fair enough.  I'll rework the comment.
> 
> > That's something an application taht uses layout leases might do,
> > but it largely irrelevant to the functionality layout leases
> > provide. What needs to be done here is explain what the layout lease
> > API actually guarantees w.r.t. the physical file layout, not what
> > some application is going to do with a lease. e.g.
> > 
> > 	The layout lease F_RDLCK guarantees that the holder will be
> > 	notified that the physical file layout is about to be
> > 	changed, and that it needs to release any resources it has
> > 	over the range of this lease, drop the lease and then
> > 	request it again to wait for the kernel to finish whatever
> > 	it is doing on that range.
> > 
> > 	The layout lease F_RDLCK also allows the holder to modify
> > 	the physical layout of the file. If an operation from the
> > 	lease holder occurs that would modify the layout, that lease
> > 	holder does not get notification that a change will occur,
> > 	but it will block until all other F_RDLCK leases have been
> > 	released by their holders before going ahead.
> > 
> > 	If there is a F_WRLCK lease held on the file, then a F_RDLCK
> > 	holder will fail any operation that may modify the physical
> > 	layout of the file. F_WRLCK provides exclusive physical
> > 	modification access to the holder, guaranteeing nothing else
> > 	will change the layout of the file while it holds the lease.
> > 
> > 	The F_WRLCK holder can change the physical layout of the
> > 	file if it so desires, this will block while F_RDLCK holders
> > 	are notified and release their leases before the
> > 	modification will take place.
> > 
> > We need to define the semantics we expose to userspace first.....
> 
> Agreed.  I believe I have implemented the semantics you describe above.  Do I
> have your permission to use your verbiage as part of reworking the comment and
> commit message?

Of course. :)

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

