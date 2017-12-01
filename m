Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id AE6B16B025E
	for <linux-mm@kvack.org>; Fri,  1 Dec 2017 05:12:28 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id a22so1876864wme.0
        for <linux-mm@kvack.org>; Fri, 01 Dec 2017 02:12:28 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g32si3054943edd.421.2017.12.01.02.12.20
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 01 Dec 2017 02:12:20 -0800 (PST)
Date: Fri, 1 Dec 2017 11:12:18 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v3 1/4] mm: introduce get_user_pages_longterm
Message-ID: <20171201101218.mxjyv4fc4cjwhf2o@dhcp22.suse.cz>
References: <151197872943.26211.6551382719053304996.stgit@dwillia2-desk3.amr.corp.intel.com>
 <151197873499.26211.11687422577653326365.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20171130095323.ovrq2nenb6ztiapy@dhcp22.suse.cz>
 <CAPcyv4giMvMfP=yZr=EDRAdTWyCwWydb4JVhT6YSWP8W0PHgGQ@mail.gmail.com>
 <20171130174201.stbpuye4gu5rxwkm@dhcp22.suse.cz>
 <CAPcyv4h5GUueqB-QhbWbn39SBPDE-rOte6UcmAHSWQdVyrF2Rw@mail.gmail.com>
 <20171130181741.2y5nyflyhqxg6y5p@dhcp22.suse.cz>
 <CAPcyv4hwsGQCUcTdpT7UVJyPN0RJz+CAqGNvTSK9Ka1nsypQjA@mail.gmail.com>
 <20171130190117.GF7754@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171130190117.GF7754@ziepe.ca>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Jason Gunthorpe <jgg@ziepe.ca>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Christoph Hellwig <hch@lst.de>, "stable@vger.kernel.org" <stable@vger.kernel.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, linux-rdma <linux-rdma@vger.kernel.org>

On Thu 30-11-17 12:01:17, Jason Gunthorpe wrote:
> On Thu, Nov 30, 2017 at 10:32:42AM -0800, Dan Williams wrote:
> > > Who and how many LRU pages can pin that way and how do you prevent nasty
> > > users to DoS systems this way?
> > 
> > I assume this is something the RDMA community has had to contend with?
> > I'm not an RDMA person, I'm just here to fix dax.
> 
> The RDMA implementation respects the mlock rlimit

OK, so then I am kind of lost in why do we need a special g-u-p variant.
The documentation doesn't say and quite contrary it assumes that the
caller knows what he is doing. This cannot be the right approach.

In other words, what does V4L2 does in the same context? Does it account
the pinned memory or it allows user to pin arbitrary amount of memory.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
