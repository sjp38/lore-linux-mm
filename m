Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id D69CA6B0005
	for <linux-mm@kvack.org>; Thu, 25 Jan 2018 11:47:29 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id i1so5057403pgv.22
        for <linux-mm@kvack.org>; Thu, 25 Jan 2018 08:47:29 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id p184si4832110pfg.371.2018.01.25.08.47.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 25 Jan 2018 08:47:27 -0800 (PST)
Date: Thu, 25 Jan 2018 08:47:23 -0800
From: "hch@infradead.org" <hch@infradead.org>
Subject: Re: [LSF/MM TOPIC] Filesystem-DAX, page-pinning, and RDMA
Message-ID: <20180125164723.GA31752@infradead.org>
References: <CAPcyv4gQNM9RbTbRWKnG6Vby_CW9CJ9EZTARsVNi=9cas7ZR2A@mail.gmail.com>
 <1516852902.3724.4.camel@wdc.com>
 <CAPcyv4iERedTChineSd-9fYR-xOc6E4L-okj7OnCMmoUkMf0tA@mail.gmail.com>
 <20180125160848.GE10706@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180125160848.GE10706@ziepe.ca>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Dan Williams <dan.j.williams@intel.com>, Bart Van Assche <Bart.VanAssche@wdc.com>, "lsf-pc@lists.linux-foundation.org" <lsf-pc@lists.linux-foundation.org>, "hch@infradead.org" <hch@infradead.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "mhocko@kernel.org" <mhocko@kernel.org>, "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>

On Thu, Jan 25, 2018 at 09:08:48AM -0700, Jason Gunthorpe wrote:
> On Wed, Jan 24, 2018 at 11:02:16PM -0800, Dan Williams wrote:
> 
> > No, in 3 dimensions since there is a need to support non-ODP RDMA
> > hardware, hypervisors want to coordinate DMA for guests, and non-RDMA
> > hardware also pins memory indefinitely like V4L2. So it's bigger than
> > RDMA, but that will likely be the first consumer of this 'longterm
> > pin' mechanism.
> 
> BTW, did you look at VFIO? I think it should also have this problem
> right?

VFIO seems to have the same issue.  In practice I don't think people
use file system backed pages for vfio, so it's not as urgent.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
