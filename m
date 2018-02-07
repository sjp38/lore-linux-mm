Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id E8C306B02FC
	for <linux-mm@kvack.org>; Wed,  7 Feb 2018 05:41:29 -0500 (EST)
Received: by mail-pl0-f70.google.com with SMTP id f1so199591plb.7
        for <linux-mm@kvack.org>; Wed, 07 Feb 2018 02:41:29 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a91-v6si908853pld.125.2018.02.07.02.41.28
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 07 Feb 2018 02:41:28 -0800 (PST)
Date: Wed, 7 Feb 2018 11:41:23 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [LSF/MM TOPIC] Native NVMM file systems
Message-ID: <20180207104123.64bjccnfzvnqqor6@quack2.suse.cz>
References: <CAOvWMLZVkQ1D=Jn-_O9owewr7U699bN=dmwuBoDnQVLEkkXJ8A@mail.gmail.com>
 <CAPcyv4gFePPt7ABOfJitVTEFPh_o838ky0fGjqAHMwnwwkV88Q@mail.gmail.com>
 <CAPcyv4hk6VR3yqhtocZwpyp4VRb59WO3ECfLEJx4pmpYSU_P5Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAPcyv4hk6VR3yqhtocZwpyp4VRb59WO3ECfLEJx4pmpYSU_P5Q@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Andiry Xu <andiry@gmail.com>, lsf-pc@lists.linux-foundation.org, Linux FS Devel <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@ml01.01.org>, david <david@fromorbit.com>, Matthew Wilcox <willy@infradead.org>, swanson@cs.ucsd.edu, jix024@cs.ucsd.edu, Jan Kara <jack@suse.cz>, Ross Zwisler <ross.zwisler@linux.intel.com>

On Wed 31-01-18 17:13:37, Dan Williams wrote:
> [ adding Jan and Ross ]
> 
> On Wed, Jan 31, 2018 at 5:03 PM, Dan Williams <dan.j.williams@intel.com> wrote:
> > On Wed, Jan 31, 2018 at 4:45 PM, Andiry Xu <andiry@gmail.com> wrote:
> >> PMEM/DAX should allow for significant improvements in file system
> >> performance and enable new programming models that allow direct,
> >> efficient access to PMEM from userspace.  Achieving these gains in
> >> existing file systems built for block devices (e.g., XFS and EXT4a?|)
> >> presents a range of challenges (e.g.,
> >> https://lkml.org/lkml/2016/9/11/159) and has been the subject of a lot
> >> of recent work on ext4 and xfs.
> >>
> >> An alternative is to build a NVMM-aware file system from scratch that
> >> takes full advantage of the performance that PMEM offers and avoids
> >> the complexity that block-based file systems include to maximize
> >> performance on slow storage (e.g., relaxing atomicity constraints on
> >> many operations).  Of course, it also brings with it the complexity of
> >> another file system.
> >>
> >> We recently sent out a patch set for one-such a??clean slatea?? NVMM-aware
> >> file system called NOVA.  NOVA is log-structured DAX file system with
> >> several nice features:
> >>
> >> * High performance, especially in metadata operations due to efficient
> >> fine-grained logging
> >> * High scalability with per-CPU memory pool and per-inode logging
> >> * Strong metadata and data atomicity guarantees for all operations
> >> * Full filesystem snapshot support with DAX-mmap
> >> * Metadata replication/checksums and RAID-4 style data protection
> >>
> >> At the summit, we would like to discuss the trade-offs between
> >> adapting NVMM features to existing file systems vs. creating/adopting
> >> a purpose-built file system for NVMM.  NOVA serves as useful starting
> >> point for that discussion by demonstrating whata??s possible.  It may
> >> also suggest some features that could be adapted to other file systems
> >> to improve NVMM performance.
> >>
> >> We welcome people that are interested in file systems and NVM/DAX.
> >> Particular people that would be useful to have in attendance are Dan
> >> Williams, Dave Chinner, and Matthew Wilcox.
> >
> > The rest of the fs-dax crew would also be useful to have:
> >
> > Jan Kara
> > Ross Zwisler

Thanks Dan. Yes, I'd be interested in discussions about NOVA. In fact I
guess the biggest obstacle is currently the review bandwidth. New
filesystem is a substantial chunk of code and although it does not have to
be perfect to include it in the kernel it still needs at least some basic
review...

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
