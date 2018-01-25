Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id EAE996B0008
	for <linux-mm@kvack.org>; Thu, 25 Jan 2018 11:08:53 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id 33so4843404wrs.3
        for <linux-mm@kvack.org>; Thu, 25 Jan 2018 08:08:53 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 11sor424329wmr.46.2018.01.25.08.08.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 25 Jan 2018 08:08:52 -0800 (PST)
Date: Thu, 25 Jan 2018 09:08:48 -0700
From: Jason Gunthorpe <jgg@ziepe.ca>
Subject: Re: [LSF/MM TOPIC] Filesystem-DAX, page-pinning, and RDMA
Message-ID: <20180125160848.GE10706@ziepe.ca>
References: <CAPcyv4gQNM9RbTbRWKnG6Vby_CW9CJ9EZTARsVNi=9cas7ZR2A@mail.gmail.com>
 <1516852902.3724.4.camel@wdc.com>
 <CAPcyv4iERedTChineSd-9fYR-xOc6E4L-okj7OnCMmoUkMf0tA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4iERedTChineSd-9fYR-xOc6E4L-okj7OnCMmoUkMf0tA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Bart Van Assche <Bart.VanAssche@wdc.com>, "lsf-pc@lists.linux-foundation.org" <lsf-pc@lists.linux-foundation.org>, "hch@infradead.org" <hch@infradead.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "mhocko@kernel.org" <mhocko@kernel.org>, "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>

On Wed, Jan 24, 2018 at 11:02:16PM -0800, Dan Williams wrote:

> No, in 3 dimensions since there is a need to support non-ODP RDMA
> hardware, hypervisors want to coordinate DMA for guests, and non-RDMA
> hardware also pins memory indefinitely like V4L2. So it's bigger than
> RDMA, but that will likely be the first consumer of this 'longterm
> pin' mechanism.

BTW, did you look at VFIO? I think it should also have this problem
right?

Jason

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
