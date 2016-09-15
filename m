Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2C70A6B0038
	for <linux-mm@kvack.org>; Thu, 15 Sep 2016 13:10:07 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id x203so6260754oia.3
        for <linux-mm@kvack.org>; Thu, 15 Sep 2016 10:10:07 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id n4si4812379itg.125.2016.09.15.10.09.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Sep 2016 10:09:48 -0700 (PDT)
Date: Thu, 15 Sep 2016 10:09:42 -0700
From: "Darrick J. Wong" <darrick.wong@oracle.com>
Subject: Re: [PATCH v2 2/3] mm, dax: add VM_DAX flag for DAX VMAs
Message-ID: <20160915170942.GJ9314@birch.djwong.org>
References: <147392246509.9873.17750323049785100997.stgit@dwillia2-desk3.amr.corp.intel.com>
 <147392247875.9873.4205533916442000884.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20160915082615.GA9772@lst.de>
 <CAPcyv4jTw3cXpmmJRh7t16Xy2uYofDe+fJ+X_jnz+Q=o0uGneg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4jTw3cXpmmJRh7t16Xy2uYofDe+fJ+X_jnz+Q=o0uGneg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Christoph Hellwig <hch@lst.de>, "linux-nvdimm@lists.01.org" <linux-nvdimm@ml01.01.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Nicholas Piggin <npiggin@gmail.com>, XFS Developers <xfs@oss.sgi.com>, Linux MM <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>

On Thu, Sep 15, 2016 at 10:01:03AM -0700, Dan Williams wrote:
> On Thu, Sep 15, 2016 at 1:26 AM, Christoph Hellwig <hch@lst.de> wrote:
> > On Wed, Sep 14, 2016 at 11:54:38PM -0700, Dan Williams wrote:
> >> The DAX property, page cache bypass, of a VMA is only detectable via the
> >> vma_is_dax() helper to check the S_DAX inode flag.  However, this is
> >> only available internal to the kernel and is a property that userspace
> >> applications would like to interrogate.
> >
> > They have absolutely no business knowing such an implementation detail.
> 
> Hasn't that train already left the station with FS_XFLAG_DAX?

Seeing as FS_IOC_FSGETXATTR is a "generic" ioctl now, why not just
implement it for all the DAX fses and block devices?  Aside from xflags,
the other fields are probably all zero for non-xfs (aside from project
quota id I guess).

(Yeah, sort of awkward, I know...)

--D

> The other problem with hiding the DAX property is that it turns out to
> not be a transparent acceleration feature.  See xfs/086 xfs/088
> xfs/089 xfs/091 which fail with DAX and, as far as I understand, it is
> due to the fact that DAX disallows delayed allocation behavior.
> 
> If behavior changes I think we should indicate that to userspace and
> VM_DAX is certainly more useful to userspace than some of the other vm
> internals we already export in those flags.
> 
> _______________________________________________
> xfs mailing list
> xfs@oss.sgi.com
> http://oss.sgi.com/mailman/listinfo/xfs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
