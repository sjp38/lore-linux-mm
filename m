Return-Path: <SRS0=g7KO=WK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8B5B2C32753
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 11:21:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 529BB208C2
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 11:21:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="GoyIEeuy"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 529BB208C2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D8EDE6B0005; Wed, 14 Aug 2019 07:21:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D3FA26B0006; Wed, 14 Aug 2019 07:21:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C2DAF6B0007; Wed, 14 Aug 2019 07:21:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0186.hostedemail.com [216.40.44.186])
	by kanga.kvack.org (Postfix) with ESMTP id A05AD6B0005
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 07:21:39 -0400 (EDT)
Received: from smtpin14.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 497E41EF3
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 11:21:39 +0000 (UTC)
X-FDA: 75820793118.14.tree12_65b0f2877f22d
X-HE-Tag: tree12_65b0f2877f22d
X-Filterd-Recvd-Size: 5574
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by imf42.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 11:21:38 +0000 (UTC)
Received: from tleilax.poochiereds.net (68-20-15-154.lightspeed.rlghnc.sbcglobal.net [68.20.15.154])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id EBA7C2083B;
	Wed, 14 Aug 2019 11:21:35 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1565781697;
	bh=lKWyQhJZrTeR2mP8gMp1Sv43C4kaU0ItcD8UjHsGR64=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References:From;
	b=GoyIEeuy2aBMsczZxEjc418vIh6+C2Y2j1zEoa7vlM8xwuZ9K4Lx8mUTo+P3ENh3z
	 i4MieExVH35FpkJHKYrGnkalqrRJH19Pu0e79zbx70z//5lRJAjmuuStGEMPll9gj8
	 tcxu2X2I5qV6B/uj35CVsKOn4wUIaS2xvX5qVcac=
Message-ID: <1ba29bfa22f82e6d880ab31c3835047f3353f05a.camel@kernel.org>
Subject: Re: [RFC PATCH v2 01/19] fs/locks: Export F_LAYOUT lease to user
 space
From: Jeff Layton <jlayton@kernel.org>
To: Dave Chinner <david@fromorbit.com>, Ira Weiny <ira.weiny@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jason Gunthorpe
 <jgg@ziepe.ca>,  Dan Williams <dan.j.williams@intel.com>, Matthew Wilcox
 <willy@infradead.org>, Jan Kara <jack@suse.cz>,  Theodore Ts'o
 <tytso@mit.edu>, John Hubbard <jhubbard@nvidia.com>, Michal Hocko
 <mhocko@suse.com>, linux-xfs@vger.kernel.org, linux-rdma@vger.kernel.org, 
 linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, 
 linux-nvdimm@lists.01.org, linux-ext4@vger.kernel.org, linux-mm@kvack.org
Date: Wed, 14 Aug 2019 07:21:34 -0400
In-Reply-To: <20190814080547.GJ6129@dread.disaster.area>
References: <20190809225833.6657-1-ira.weiny@intel.com>
	 <20190809225833.6657-2-ira.weiny@intel.com>
	 <20190809235231.GC7777@dread.disaster.area>
	 <20190812173626.GB19746@iweiny-DESK2.sc.intel.com>
	 <20190814080547.GJ6129@dread.disaster.area>
Content-Type: text/plain; charset="UTF-8"
User-Agent: Evolution 3.32.4 (3.32.4-1.fc30) 
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2019-08-14 at 18:05 +1000, Dave Chinner wrote:
> On Mon, Aug 12, 2019 at 10:36:26AM -0700, Ira Weiny wrote:
> > On Sat, Aug 10, 2019 at 09:52:31AM +1000, Dave Chinner wrote:
> > > On Fri, Aug 09, 2019 at 03:58:15PM -0700, ira.weiny@intel.com wrote:
> > > > +	/*
> > > > +	 * NOTE on F_LAYOUT lease
> > > > +	 *
> > > > +	 * LAYOUT lease types are taken on files which the user knows that
> > > > +	 * they will be pinning in memory for some indeterminate amount of
> > > > +	 * time.
> > > 
> > > Indeed, layout leases have nothing to do with pinning of memory.
> > 
> > Yep, Fair enough.  I'll rework the comment.
> > 
> > > That's something an application taht uses layout leases might do,
> > > but it largely irrelevant to the functionality layout leases
> > > provide. What needs to be done here is explain what the layout lease
> > > API actually guarantees w.r.t. the physical file layout, not what
> > > some application is going to do with a lease. e.g.
> > > 
> > > 	The layout lease F_RDLCK guarantees that the holder will be
> > > 	notified that the physical file layout is about to be
> > > 	changed, and that it needs to release any resources it has
> > > 	over the range of this lease, drop the lease and then
> > > 	request it again to wait for the kernel to finish whatever
> > > 	it is doing on that range.
> > > 
> > > 	The layout lease F_RDLCK also allows the holder to modify
> > > 	the physical layout of the file. If an operation from the
> > > 	lease holder occurs that would modify the layout, that lease
> > > 	holder does not get notification that a change will occur,
> > > 	but it will block until all other F_RDLCK leases have been
> > > 	released by their holders before going ahead.
> > > 
> > > 	If there is a F_WRLCK lease held on the file, then a F_RDLCK
> > > 	holder will fail any operation that may modify the physical
> > > 	layout of the file. F_WRLCK provides exclusive physical
> > > 	modification access to the holder, guaranteeing nothing else
> > > 	will change the layout of the file while it holds the lease.
> > > 
> > > 	The F_WRLCK holder can change the physical layout of the
> > > 	file if it so desires, this will block while F_RDLCK holders
> > > 	are notified and release their leases before the
> > > 	modification will take place.
> > > 
> > > We need to define the semantics we expose to userspace first.....

Absolutely.

> > 
> > Agreed.  I believe I have implemented the semantics you describe above.  Do I
> > have your permission to use your verbiage as part of reworking the comment and
> > commit message?
> 
> Of course. :)
> 
> Cheers,
> 

I'll review this in more detail soon, but subsequent postings of the set
should probably also go to linux-api mailing list. This is a significant
API change. It might not also hurt to get the glibc folks involved here
too since you'll probably want to add the constants to the headers there
as well.

Finally, consider going ahead and drafting a patch to the fcntl(2)
manpage if you think you have the API mostly nailed down. This API is a
little counterintuitive (i.e. you can change the layout with an F_RDLCK
lease), so it will need to be very clearly documented. I've also found
that when creating a new API, documenting it tends to help highlight its
warts and areas where the behavior is not clearly defined.

-- 
Jeff Layton <jlayton@kernel.org>


