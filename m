Return-Path: <SRS0=g7KO=WK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 46C9BC433FF
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 21:57:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 135062133F
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 21:57:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 135062133F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fromorbit.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B8A156B0003; Wed, 14 Aug 2019 17:57:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B3AE66B0005; Wed, 14 Aug 2019 17:57:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A51BE6B0007; Wed, 14 Aug 2019 17:57:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0145.hostedemail.com [216.40.44.145])
	by kanga.kvack.org (Postfix) with ESMTP id 841656B0003
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 17:57:43 -0400 (EDT)
Received: from smtpin17.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 2731845B4
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 21:57:43 +0000 (UTC)
X-FDA: 75822396006.17.war00_7d8699872e805
X-HE-Tag: war00_7d8699872e805
X-Filterd-Recvd-Size: 4116
Received: from mail104.syd.optusnet.com.au (mail104.syd.optusnet.com.au [211.29.132.246])
	by imf20.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 21:57:42 +0000 (UTC)
Received: from dread.disaster.area (pa49-195-190-67.pa.nsw.optusnet.com.au [49.195.190.67])
	by mail104.syd.optusnet.com.au (Postfix) with ESMTPS id 800D843DB39;
	Thu, 15 Aug 2019 07:57:37 +1000 (AEST)
Received: from dave by dread.disaster.area with local (Exim 4.92)
	(envelope-from <david@fromorbit.com>)
	id 1hy1Fu-0006Ca-2B; Thu, 15 Aug 2019 07:56:30 +1000
Date: Thu, 15 Aug 2019 07:56:30 +1000
From: Dave Chinner <david@fromorbit.com>
To: Jeff Layton <jlayton@kernel.org>
Cc: ira.weiny@intel.com, Andrew Morton <akpm@linux-foundation.org>,
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
Message-ID: <20190814215630.GQ6129@dread.disaster.area>
References: <20190809225833.6657-1-ira.weiny@intel.com>
 <20190809225833.6657-3-ira.weiny@intel.com>
 <fde2959db776616008fc5d31df700f5d7d899433.camel@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <fde2959db776616008fc5d31df700f5d7d899433.camel@kernel.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Optus-CM-Score: 0
X-Optus-CM-Analysis: v=2.2 cv=FNpr/6gs c=1 sm=1 tr=0
	a=TR82T6zjGmBjdfWdGgpkDw==:117 a=TR82T6zjGmBjdfWdGgpkDw==:17
	a=jpOVt7BSZ2e4Z31A5e1TngXxSK0=:19 a=kj9zAlcOel0A:10 a=FmdZ9Uzk2mMA:10
	a=QyXUC8HyAAAA:8 a=7-415B0cAAAA:8 a=qa3ElbQomqnm_qv8Y-cA:9
	a=CjuIK1q_8ugA:10 a=biEYGPWJfzWAr4FL6Ov7:22
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Aug 14, 2019 at 10:15:06AM -0400, Jeff Layton wrote:
> On Fri, 2019-08-09 at 15:58 -0700, ira.weiny@intel.com wrote:
> > From: Ira Weiny <ira.weiny@intel.com>
> > 
> > Add an exclusive lease flag which indicates that the layout mechanism
> > can not be broken.
> > 
> > Exclusive layout leases allow the file system to know that pages may be
> > GUP pined and that attempts to change the layout, ie truncate, should be
> > failed.
> > 
> > A process which attempts to break it's own exclusive lease gets an
> > EDEADLOCK return to help determine that this is likely a programming bug
> > vs someone else holding a resource.
.....
> > diff --git a/include/uapi/asm-generic/fcntl.h b/include/uapi/asm-generic/fcntl.h
> > index baddd54f3031..88b175ceccbc 100644
> > --- a/include/uapi/asm-generic/fcntl.h
> > +++ b/include/uapi/asm-generic/fcntl.h
> > @@ -176,6 +176,8 @@ struct f_owner_ex {
> >  
> >  #define F_LAYOUT	16      /* layout lease to allow longterm pins such as
> >  				   RDMA */
> > +#define F_EXCLUSIVE	32      /* layout lease is exclusive */
> > +				/* FIXME or shoudl this be F_EXLCK??? */
> >  
> >  /* operations for bsd flock(), also used by the kernel implementation */
> >  #define LOCK_SH		1	/* shared lock */
> 
> This interface just seems weird to me. The existing F_*LCK values aren't
> really set up to be flags, but are enumerated values (even if there are
> some gaps on some arches). For instance, on parisc and sparc:

I don't think we need to worry about this - the F_WRLCK version of
the layout lease should have these exclusive access semantics (i.e
other ops fail rather than block waiting for lease recall) and hence
the API shouldn't need a new flag to specify them.

i.e. the primary difference between F_RDLCK and F_WRLCK layout
leases is that the F_RDLCK is a shared, co-operative lease model
where only delays in operations will be seen, while F_WRLCK is a
"guarantee exclusive access and I don't care what it breaks"
model... :)

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

