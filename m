Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 69A206B0003
	for <linux-mm@kvack.org>; Wed, 31 Jan 2018 20:48:21 -0500 (EST)
Received: by mail-io0-f197.google.com with SMTP id w17so16053161iow.23
        for <linux-mm@kvack.org>; Wed, 31 Jan 2018 17:48:21 -0800 (PST)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id d65si1042140iod.233.2018.01.31.17.48.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jan 2018 17:48:20 -0800 (PST)
Date: Wed, 31 Jan 2018 17:47:49 -0800
From: "Darrick J. Wong" <darrick.wong@oracle.com>
Subject: Re: [LSF/MM TOPIC] Native NVMM file systems
Message-ID: <20180201014749.GF4841@magnolia>
References: <CAOvWMLZVkQ1D=Jn-_O9owewr7U699bN=dmwuBoDnQVLEkkXJ8A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAOvWMLZVkQ1D=Jn-_O9owewr7U699bN=dmwuBoDnQVLEkkXJ8A@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andiry Xu <andiry@gmail.com>
Cc: lsf-pc@lists.linux-foundation.org, Linux FS Devel <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@ml01.01.org>, dan.j.williams@intel.com, david@fromorbit.com, willy@infradead.org, swanson@cs.ucsd.edu, jix024@cs.ucsd.edu

On Wed, Jan 31, 2018 at 04:45:36PM -0800, Andiry Xu wrote:
> PMEM/DAX should allow for significant improvements in file system
> performance and enable new programming models that allow direct,
> efficient access to PMEM from userspace.  Achieving these gains in
> existing file systems built for block devices (e.g., XFS and EXT4a?|)
> presents a range of challenges (e.g.,
> https://lkml.org/lkml/2016/9/11/159) and has been the subject of a lot
> of recent work on ext4 and xfs.
> 
> An alternative is to build a NVMM-aware file system from scratch that
> takes full advantage of the performance that PMEM offers and avoids
> the complexity that block-based file systems include to maximize
> performance on slow storage (e.g., relaxing atomicity constraints on
> many operations).  Of course, it also brings with it the complexity of
> another file system.
>
> We recently sent out a patch set for one-such a??clean slatea?? NVMM-aware
> file system called NOVA.  NOVA is log-structured DAX file system with
> several nice features:

That's the series that was sent out last August, correct?

> * High performance, especially in metadata operations due to efficient
> fine-grained logging
> * High scalability with per-CPU memory pool and per-inode logging
> * Strong metadata and data atomicity guarantees for all operations
> * Full filesystem snapshot support with DAX-mmap
> * Metadata replication/checksums and RAID-4 style data protection
> 
> At the summit, we would like to discuss the trade-offs between
> adapting NVMM features to existing file systems vs. creating/adopting
> a purpose-built file system for NVMM.  NOVA serves as useful starting
> point for that discussion by demonstrating whata??s possible.  It may
> also suggest some features that could be adapted to other file systems
> to improve NVMM performance.
> 
> We welcome people that are interested in file systems and NVM/DAX.
> Particular people that would be useful to have in attendance are Dan
> Williams, Dave Chinner, and Matthew Wilcox.

I wouldn't mind being there too. :)

--D

> 
> Thanks,
> Andiry

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
