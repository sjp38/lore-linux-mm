Return-Path: <SRS0=qe68=WZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.2 required=3.0
	tests=HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C7850C3A59F
	for <linux-mm@archiver.kernel.org>; Thu, 29 Aug 2019 23:34:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6BED621874
	for <linux-mm@archiver.kernel.org>; Thu, 29 Aug 2019 23:34:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6BED621874
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B26CF6B0003; Thu, 29 Aug 2019 19:34:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AD6BD6B0008; Thu, 29 Aug 2019 19:34:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9EDA46B000C; Thu, 29 Aug 2019 19:34:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0160.hostedemail.com [216.40.44.160])
	by kanga.kvack.org (Postfix) with ESMTP id 7E13F6B0003
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 19:34:12 -0400 (EDT)
Received: from smtpin20.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 2E04E1A4B6
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 23:34:12 +0000 (UTC)
X-FDA: 75877071144.20.unit75_5ec7d3f6f1a60
X-HE-Tag: unit75_5ec7d3f6f1a60
X-Filterd-Recvd-Size: 5501
Received: from mga06.intel.com (mga06.intel.com [134.134.136.31])
	by imf10.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 23:34:11 +0000 (UTC)
X-Amp-Result: UNSCANNABLE
X-Amp-File-Uploaded: False
Received: from orsmga007.jf.intel.com ([10.7.209.58])
  by orsmga104.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 29 Aug 2019 16:34:09 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.64,445,1559545200"; 
   d="scan'208";a="172060373"
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by orsmga007.jf.intel.com with ESMTP; 29 Aug 2019 16:34:08 -0700
Date: Thu, 29 Aug 2019 16:34:08 -0700
From: Ira Weiny <ira.weiny@intel.com>
To: Jeff Layton <jlayton@kernel.org>
Cc: Dave Chinner <david@fromorbit.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	Dan Williams <dan.j.williams@intel.com>,
	Matthew Wilcox <willy@infradead.org>, Jan Kara <jack@suse.cz>,
	Theodore Ts'o <tytso@mit.edu>, John Hubbard <jhubbard@nvidia.com>,
	Michal Hocko <mhocko@suse.com>, linux-xfs@vger.kernel.org,
	linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, linux-nvdimm@lists.01.org,
	linux-ext4@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [RFC PATCH v2 02/19] fs/locks: Add Exclusive flag to user Layout
 lease
Message-ID: <20190829233408.GD18249@iweiny-DESK2.sc.intel.com>
References: <20190809225833.6657-1-ira.weiny@intel.com>
 <20190809225833.6657-3-ira.weiny@intel.com>
 <fde2959db776616008fc5d31df700f5d7d899433.camel@kernel.org>
 <20190814215630.GQ6129@dread.disaster.area>
 <e6f4f619967f4551adb5003d0364770fde2b8110.camel@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <e6f4f619967f4551adb5003d0364770fde2b8110.camel@kernel.org>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Missed this.  sorry.

On Mon, Aug 26, 2019 at 06:41:07AM -0400, Jeff Layton wrote:
> On Thu, 2019-08-15 at 07:56 +1000, Dave Chinner wrote:
> > On Wed, Aug 14, 2019 at 10:15:06AM -0400, Jeff Layton wrote:
> > > On Fri, 2019-08-09 at 15:58 -0700, ira.weiny@intel.com wrote:
> > > > From: Ira Weiny <ira.weiny@intel.com>
> > > > 
> > > > Add an exclusive lease flag which indicates that the layout mechanism
> > > > can not be broken.
> > > > 
> > > > Exclusive layout leases allow the file system to know that pages may be
> > > > GUP pined and that attempts to change the layout, ie truncate, should be
> > > > failed.
> > > > 
> > > > A process which attempts to break it's own exclusive lease gets an
> > > > EDEADLOCK return to help determine that this is likely a programming bug
> > > > vs someone else holding a resource.
> > .....
> > > > diff --git a/include/uapi/asm-generic/fcntl.h b/include/uapi/asm-generic/fcntl.h
> > > > index baddd54f3031..88b175ceccbc 100644
> > > > --- a/include/uapi/asm-generic/fcntl.h
> > > > +++ b/include/uapi/asm-generic/fcntl.h
> > > > @@ -176,6 +176,8 @@ struct f_owner_ex {
> > > >  
> > > >  #define F_LAYOUT	16      /* layout lease to allow longterm pins such as
> > > >  				   RDMA */
> > > > +#define F_EXCLUSIVE	32      /* layout lease is exclusive */
> > > > +				/* FIXME or shoudl this be F_EXLCK??? */
> > > >  
> > > >  /* operations for bsd flock(), also used by the kernel implementation */
> > > >  #define LOCK_SH		1	/* shared lock */
> > > 
> > > This interface just seems weird to me. The existing F_*LCK values aren't
> > > really set up to be flags, but are enumerated values (even if there are
> > > some gaps on some arches). For instance, on parisc and sparc:
> > 
> > I don't think we need to worry about this - the F_WRLCK version of
> > the layout lease should have these exclusive access semantics (i.e
> > other ops fail rather than block waiting for lease recall) and hence
> > the API shouldn't need a new flag to specify them.
> > 
> > i.e. the primary difference between F_RDLCK and F_WRLCK layout
> > leases is that the F_RDLCK is a shared, co-operative lease model
> > where only delays in operations will be seen, while F_WRLCK is a
> > "guarantee exclusive access and I don't care what it breaks"
> > model... :)
> > 
> 
> Not exactly...
> 
> F_WRLCK and F_RDLCK leases can both be broken, and will eventually time
> out if there is conflicting access. The F_EXCLUSIVE flag on the other
> hand is there to prevent any sort of lease break from 

Right EXCLUSIVE will not break for any reason.  It will fail truncate and hole
punch as we discussed back in June.  This is for the use case where the user
has handed this file/pages off to some hardware for which removing the lease
would be impossible.  _And_ we don't anticipate any valid use case that someone
will need to truncate short of killing the process to free up file system
space.

> 
> I'm guessing what Ira really wants with the F_EXCLUSIVE flag is
> something akin to what happens when we set fl_break_time to 0 in the
> nfsd code. nfsd never wants the locks code to time out a lease of any
> sort, since it handles that timeout itself.
> 
> If you're going to add this functionality, it'd be good to also convert
> knfsd to use it as well, so we don't end up with multiple ways to deal
> with that situation.

Could you point me at the source for knfsd?  I looked in 

git://git.linux-nfs.org/projects/steved/nfs-utils.git

but I don't see anywhere leases are used in that source?

Thanks,
Ira


