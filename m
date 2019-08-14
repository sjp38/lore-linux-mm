Return-Path: <SRS0=g7KO=WK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7BBE2C433FF
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 17:50:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4B725216F4
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 17:50:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4B725216F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DCAA26B0003; Wed, 14 Aug 2019 13:50:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D54546B0005; Wed, 14 Aug 2019 13:50:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C1AE46B0007; Wed, 14 Aug 2019 13:50:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0003.hostedemail.com [216.40.44.3])
	by kanga.kvack.org (Postfix) with ESMTP id 9EF916B0003
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 13:50:49 -0400 (EDT)
Received: from smtpin08.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 5D3B3180AD7C1
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 17:50:49 +0000 (UTC)
X-FDA: 75821773818.08.lock45_7071411d9948
X-HE-Tag: lock45_7071411d9948
X-Filterd-Recvd-Size: 6686
Received: from mga07.intel.com (mga07.intel.com [134.134.136.100])
	by imf28.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 17:50:48 +0000 (UTC)
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from orsmga006.jf.intel.com ([10.7.209.51])
  by orsmga105.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 14 Aug 2019 10:50:46 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.64,386,1559545200"; 
   d="scan'208";a="181636379"
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by orsmga006.jf.intel.com with ESMTP; 14 Aug 2019 10:50:45 -0700
Date: Wed, 14 Aug 2019 10:50:45 -0700
From: Ira Weiny <ira.weiny@intel.com>
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Dan Williams <dan.j.williams@intel.com>,
	Matthew Wilcox <willy@infradead.org>, Jan Kara <jack@suse.cz>,
	Theodore Ts'o <tytso@mit.edu>, John Hubbard <jhubbard@nvidia.com>,
	Michal Hocko <mhocko@suse.com>, Dave Chinner <david@fromorbit.com>,
	linux-xfs@vger.kernel.org, linux-rdma@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	linux-nvdimm@lists.01.org, linux-ext4@vger.kernel.org,
	linux-mm@kvack.org
Subject: Re: [RFC PATCH v2 16/19] RDMA/uverbs: Add back pointer to system
 file object
Message-ID: <20190814175045.GA31490@iweiny-DESK2.sc.intel.com>
References: <20190809225833.6657-17-ira.weiny@intel.com>
 <20190812130039.GD24457@ziepe.ca>
 <20190812172826.GA19746@iweiny-DESK2.sc.intel.com>
 <20190812175615.GI24457@ziepe.ca>
 <20190812211537.GE20634@iweiny-DESK2.sc.intel.com>
 <20190813114842.GB29508@ziepe.ca>
 <20190813174142.GB11882@iweiny-DESK2.sc.intel.com>
 <20190813180022.GF29508@ziepe.ca>
 <20190813203858.GA12695@iweiny-DESK2.sc.intel.com>
 <20190814122308.GB13770@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190814122308.GB13770@ziepe.ca>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Aug 14, 2019 at 09:23:08AM -0300, Jason Gunthorpe wrote:
> On Tue, Aug 13, 2019 at 01:38:59PM -0700, Ira Weiny wrote:
> > On Tue, Aug 13, 2019 at 03:00:22PM -0300, Jason Gunthorpe wrote:
> > > On Tue, Aug 13, 2019 at 10:41:42AM -0700, Ira Weiny wrote:
> > > 
> > > > And I was pretty sure uverbs_destroy_ufile_hw() would take care of (or ensure
> > > > that some other thread is) destroying all the MR's we have associated with this
> > > > FD.
> > > 
> > > fd's can't be revoked, so destroy_ufile_hw() can't touch them. It
> > > deletes any underlying HW resources, but the FD persists.
> > 
> > I misspoke.  I should have said associated with this "context".  And of course
> > uverbs_destroy_ufile_hw() does not touch the FD.  What I mean is that the
> > struct file which had file_pins hanging off of it would be getting its file
> > pins destroyed by uverbs_destroy_ufile_hw().  Therefore we don't need the FD
> > after uverbs_destroy_ufile_hw() is done.
> > 
> > But since it does not block it may be that the struct file is gone before the
> > MR is actually destroyed.  Which means I think the GUP code would blow up in
> > that case...  :-(
> 
> Oh, yes, that is true, you also can't rely on the struct file living
> longer than the HW objects either, that isn't how the lifetime model
> works.
> 
> If GUP consumes the struct file it must allow the struct file to be
> deleted before the GUP pin is released.

I may have to think about this a bit.  But I'm starting to lean toward my
callback method as a solution...

> 
> > The drivers could provide some generic object (in RDMA this could be the
> > uverbs_attr_bundle) which represents their "context".
> 
> For RDMA the obvious context is the struct ib_mr *

Not really, but maybe.  See below regarding tracking this across processes.

> 
> > But for the procfs interface, that context then needs to be associated with any
> > file which points to it...  For RDMA, or any other "FD based pin mechanism", it
> > would be up to the driver to "install" a procfs handler into any struct file
> > which _may_ point to this context.  (before _or_ after memory pins).
> 
> Is this all just for debugging? Seems like a lot of complication just
> to print a string

No, this is a requirement to allow an admin to determine why their truncates
may be failing.  As per our discussion here:

https://lkml.org/lkml/2019/6/7/982

Looking back at the thread apparently no one confirmed my question (assertion).
But no one objected to it either!  :-D  From that post:

	"... if we can keep track of who has the pins in lsof can we agree no
	process needs to be SIGKILL'ed?  Admins can do this on their own
	"killing" if they really need to stop the use of these files, right?"

This is what I am trying to do here is ensure that no matter what the user
does.  Fork, munmap, SCM_RIGHTS, close (on any FD), the underlying pin is
associated to any process which has access to those pins and is holding
references to those pages.  Then any user of the system who gets a failing
truncate can figure out which processes are holding this up.

> 
> Generally, I think you'd be better to associate things with the
> mm_struct not some struct file... The whole design is simpler as GUP
> already has the mm_struct.

I wish I _could_ do that...  And for some simple users I do that.  This is why
rdma_pin has the option to track against mm_struct _OR_ struct file.

At first it seemed like carrying over the mm_struct info during fork would
work...  but then there is SCM_RIGHTS where one can share the RDMA context with
any "random" process...  AFAICS struct file has no concept of mm_struct (nor
should it) so the dup for SCM_RIGHTS processing would not be able to do this.
A further complication was that when the RDMA FD is dup'ed the RDMA subsystem
does not know about it...  So it was not straight forward to have the RDMA
subsystem do this either.  Not to mention that would be yet another
complication the drivers would have to deal with...  I think you had similar
issues which lead to the use of an "owning_mm" in the umem object.  So while
_some_ mm_struct is held it may not be visible to the user since that mm_struct
may belong to a process which is gone... Or even if not gone, killing it would not
fully remove the pin...

So keeping this tracked against struct file works (and seemed straight forward)
no matter where/how the RDMA FD is shared...  Even with the complication above
I still think it is easier to do this way.

If I am missing something WRT the mm_struct "I'm all ears".

Ira


