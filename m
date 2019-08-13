Return-Path: <SRS0=aN9C=WJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 796EDC32750
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 17:41:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 44BFD205C9
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 17:41:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 44BFD205C9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D00C06B0005; Tue, 13 Aug 2019 13:41:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C8A666B0006; Tue, 13 Aug 2019 13:41:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B52216B0007; Tue, 13 Aug 2019 13:41:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0149.hostedemail.com [216.40.44.149])
	by kanga.kvack.org (Postfix) with ESMTP id 8CDA26B0005
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 13:41:46 -0400 (EDT)
Received: from smtpin11.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 328EE181AC9B4
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 17:41:46 +0000 (UTC)
X-FDA: 75818122212.11.star38_f379d4c39c5e
X-HE-Tag: star38_f379d4c39c5e
X-Filterd-Recvd-Size: 5674
Received: from mga11.intel.com (mga11.intel.com [192.55.52.93])
	by imf37.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 17:41:44 +0000 (UTC)
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from fmsmga006.fm.intel.com ([10.253.24.20])
  by fmsmga102.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 13 Aug 2019 10:41:42 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.64,382,1559545200"; 
   d="scan'208";a="376374540"
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by fmsmga006.fm.intel.com with ESMTP; 13 Aug 2019 10:41:42 -0700
Date: Tue, 13 Aug 2019 10:41:42 -0700
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
Message-ID: <20190813174142.GB11882@iweiny-DESK2.sc.intel.com>
References: <20190809225833.6657-1-ira.weiny@intel.com>
 <20190809225833.6657-17-ira.weiny@intel.com>
 <20190812130039.GD24457@ziepe.ca>
 <20190812172826.GA19746@iweiny-DESK2.sc.intel.com>
 <20190812175615.GI24457@ziepe.ca>
 <20190812211537.GE20634@iweiny-DESK2.sc.intel.com>
 <20190813114842.GB29508@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190813114842.GB29508@ziepe.ca>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 13, 2019 at 08:48:42AM -0300, Jason Gunthorpe wrote:
> On Mon, Aug 12, 2019 at 02:15:37PM -0700, Ira Weiny wrote:
> > On Mon, Aug 12, 2019 at 02:56:15PM -0300, Jason Gunthorpe wrote:
> > > On Mon, Aug 12, 2019 at 10:28:27AM -0700, Ira Weiny wrote:
> > > > On Mon, Aug 12, 2019 at 10:00:40AM -0300, Jason Gunthorpe wrote:
> > > > > On Fri, Aug 09, 2019 at 03:58:30PM -0700, ira.weiny@intel.com wrote:
> > > > > > From: Ira Weiny <ira.weiny@intel.com>
> > > > > > 
> > > > > > In order for MRs to be tracked against the open verbs context the ufile
> > > > > > needs to have a pointer to hand to the GUP code.
> > > > > > 
> > > > > > No references need to be taken as this should be valid for the lifetime
> > > > > > of the context.
> > > > > > 
> > > > > > Signed-off-by: Ira Weiny <ira.weiny@intel.com>
> > > > > >  drivers/infiniband/core/uverbs.h      | 1 +
> > > > > >  drivers/infiniband/core/uverbs_main.c | 1 +
> > > > > >  2 files changed, 2 insertions(+)
> > > > > > 
> > > > > > diff --git a/drivers/infiniband/core/uverbs.h b/drivers/infiniband/core/uverbs.h
> > > > > > index 1e5aeb39f774..e802ba8c67d6 100644
> > > > > > +++ b/drivers/infiniband/core/uverbs.h
> > > > > > @@ -163,6 +163,7 @@ struct ib_uverbs_file {
> > > > > >  	struct page *disassociate_page;
> > > > > >  
> > > > > >  	struct xarray		idr;
> > > > > > +	struct file             *sys_file; /* backpointer to system file object */
> > > > > >  };
> > > > > 
> > > > > The 'struct file' has a lifetime strictly shorter than the
> > > > > ib_uverbs_file, which is kref'd on its own lifetime. Having a back
> > > > > pointer like this is confouding as it will be invalid for some of the
> > > > > lifetime of the struct.
> > > > 
> > > > Ah...  ok.  I really thought it was the other way around.
> > > > 
> > > > __fput() should not call ib_uverbs_close() until the last reference on struct
> > > > file is released...  What holds references to struct ib_uverbs_file past that?
> > > 
> > > Child fds hold onto the internal ib_uverbs_file until they are closed
> > 
> > The FDs hold the struct file, don't they?
> 
> Only dups, there are other 'child' FDs we can create
> 
> > > Now this has unlocked updates to that data.. you'd need some lock and
> > > get not zero pattern
> > 
> > You can't call "get" here because I'm 99% sure we only get here when struct
> > file has no references left...
> 
> Nope, like I said the other FDs hold the uverbs_file independent of
> the struct file it is related too. 

<sigh>

We don't allow memory registrations to be created with those other FDs...

And I was pretty sure uverbs_destroy_ufile_hw() would take care of (or ensure
that some other thread is) destroying all the MR's we have associated with this
FD.

I'll have to think on this more since uverbs_destroy_ufile_hw() does not
block...  Which means there is a window here within the GUP code...  :-/

> 
> This is why having a back pointer like this is so ugly, it creates a
> reference counting cycle

Yep...  I worked through this...  and it was giving me fits...

Anyway, the struct file is the only object in the core which was reasonable to
store this information in since that is what is passed around to other
processes...

Another idea I explored was to create a callback into the driver from the core
which put the responsibility of printing the pin information on the driver.

But that started to be (and is likely going to be) a pretty complicated "dance"
between the core and the drivers so I went this way...

I also thought about holding some other reference on struct file which would
allow release to be called while keeping struct file around.  But that seemed
crazy...

Ira


