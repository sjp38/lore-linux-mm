Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id B22BA6B0038
	for <linux-mm@kvack.org>; Fri,  1 Dec 2017 11:31:42 -0500 (EST)
Received: by mail-io0-f200.google.com with SMTP id t7so9026179iod.8
        for <linux-mm@kvack.org>; Fri, 01 Dec 2017 08:31:42 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id c5sor790700ith.54.2017.12.01.08.31.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 01 Dec 2017 08:31:41 -0800 (PST)
Date: Fri, 1 Dec 2017 09:31:40 -0700
From: Jason Gunthorpe <jgg@ziepe.ca>
Subject: Re: [PATCH v3 1/4] mm: introduce get_user_pages_longterm
Message-ID: <20171201163140.GJ7754@ziepe.ca>
References: <20171130095323.ovrq2nenb6ztiapy@dhcp22.suse.cz>
 <CAPcyv4giMvMfP=yZr=EDRAdTWyCwWydb4JVhT6YSWP8W0PHgGQ@mail.gmail.com>
 <20171130174201.stbpuye4gu5rxwkm@dhcp22.suse.cz>
 <CAPcyv4h5GUueqB-QhbWbn39SBPDE-rOte6UcmAHSWQdVyrF2Rw@mail.gmail.com>
 <20171130181741.2y5nyflyhqxg6y5p@dhcp22.suse.cz>
 <CAPcyv4hwsGQCUcTdpT7UVJyPN0RJz+CAqGNvTSK9Ka1nsypQjA@mail.gmail.com>
 <20171130190117.GF7754@ziepe.ca>
 <20171201101218.mxjyv4fc4cjwhf2o@dhcp22.suse.cz>
 <20171201160204.GI7754@ziepe.ca>
 <CAPcyv4hvk8rfV_=5EX3QPFLZ=LB4=hWG5h4Z42koNYim9DB3FQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4hvk8rfV_=5EX3QPFLZ=LB4=hWG5h4Z42koNYim9DB3FQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Christoph Hellwig <hch@lst.de>, "stable@vger.kernel.org" <stable@vger.kernel.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, linux-rdma <linux-rdma@vger.kernel.org>

On Fri, Dec 01, 2017 at 08:29:53AM -0800, Dan Williams wrote:
> > And maybe we should think about moving the rlimit accounting into this
> > new function too someday?
> 
> DAX pages are not accounted in any rlimit because they are statically
> allocated reserved memory regions.

I mean, unrelated to DAX, any user of get_user_pages_longterm should
respect the memlock rlimit and that check is shared code.

Jason

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
