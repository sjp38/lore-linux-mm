Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f199.google.com (mail-ot0-f199.google.com [74.125.82.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7B3966B0253
	for <linux-mm@kvack.org>; Fri,  1 Dec 2017 11:02:10 -0500 (EST)
Received: by mail-ot0-f199.google.com with SMTP id 74so5313050otv.10
        for <linux-mm@kvack.org>; Fri, 01 Dec 2017 08:02:10 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id p69sor3652441ioi.30.2017.12.01.08.02.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 01 Dec 2017 08:02:09 -0800 (PST)
Date: Fri, 1 Dec 2017 09:02:04 -0700
From: Jason Gunthorpe <jgg@ziepe.ca>
Subject: Re: [PATCH v3 1/4] mm: introduce get_user_pages_longterm
Message-ID: <20171201160204.GI7754@ziepe.ca>
References: <151197872943.26211.6551382719053304996.stgit@dwillia2-desk3.amr.corp.intel.com>
 <151197873499.26211.11687422577653326365.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20171130095323.ovrq2nenb6ztiapy@dhcp22.suse.cz>
 <CAPcyv4giMvMfP=yZr=EDRAdTWyCwWydb4JVhT6YSWP8W0PHgGQ@mail.gmail.com>
 <20171130174201.stbpuye4gu5rxwkm@dhcp22.suse.cz>
 <CAPcyv4h5GUueqB-QhbWbn39SBPDE-rOte6UcmAHSWQdVyrF2Rw@mail.gmail.com>
 <20171130181741.2y5nyflyhqxg6y5p@dhcp22.suse.cz>
 <CAPcyv4hwsGQCUcTdpT7UVJyPN0RJz+CAqGNvTSK9Ka1nsypQjA@mail.gmail.com>
 <20171130190117.GF7754@ziepe.ca>
 <20171201101218.mxjyv4fc4cjwhf2o@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171201101218.mxjyv4fc4cjwhf2o@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Dan Williams <dan.j.williams@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Christoph Hellwig <hch@lst.de>, "stable@vger.kernel.org" <stable@vger.kernel.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, linux-rdma <linux-rdma@vger.kernel.org>

On Fri, Dec 01, 2017 at 11:12:18AM +0100, Michal Hocko wrote:
> On Thu 30-11-17 12:01:17, Jason Gunthorpe wrote:
> > On Thu, Nov 30, 2017 at 10:32:42AM -0800, Dan Williams wrote:
> > > > Who and how many LRU pages can pin that way and how do you prevent nasty
> > > > users to DoS systems this way?
> > > 
> > > I assume this is something the RDMA community has had to contend with?
> > > I'm not an RDMA person, I'm just here to fix dax.
> > 
> > The RDMA implementation respects the mlock rlimit
> 
> OK, so then I am kind of lost in why do we need a special g-u-p variant.
> The documentation doesn't say and quite contrary it assumes that the
> caller knows what he is doing. This cannot be the right approach.

I thought it was because get_user_pages_longterm is supposed to fail
on DAX mappings?

And maybe we should think about moving the rlimit accounting into this
new function too someday?

Jason

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
