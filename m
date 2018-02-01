Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7A8796B0005
	for <linux-mm@kvack.org>; Wed, 31 Jan 2018 20:13:39 -0500 (EST)
Received: by mail-oi0-f72.google.com with SMTP id x9so10538359oie.2
        for <linux-mm@kvack.org>; Wed, 31 Jan 2018 17:13:39 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l81sor1297681oia.274.2018.01.31.17.13.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 31 Jan 2018 17:13:38 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAPcyv4gFePPt7ABOfJitVTEFPh_o838ky0fGjqAHMwnwwkV88Q@mail.gmail.com>
References: <CAOvWMLZVkQ1D=Jn-_O9owewr7U699bN=dmwuBoDnQVLEkkXJ8A@mail.gmail.com>
 <CAPcyv4gFePPt7ABOfJitVTEFPh_o838ky0fGjqAHMwnwwkV88Q@mail.gmail.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 31 Jan 2018 17:13:37 -0800
Message-ID: <CAPcyv4hk6VR3yqhtocZwpyp4VRb59WO3ECfLEJx4pmpYSU_P5Q@mail.gmail.com>
Subject: Re: [LSF/MM TOPIC] Native NVMM file systems
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andiry Xu <andiry@gmail.com>
Cc: lsf-pc@lists.linux-foundation.org, Linux FS Devel <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@ml01.01.org>, david <david@fromorbit.com>, Matthew Wilcox <willy@infradead.org>, swanson@cs.ucsd.edu, jix024@cs.ucsd.edu, Jan Kara <jack@suse.cz>, Ross Zwisler <ross.zwisler@linux.intel.com>

[ adding Jan and Ross ]

On Wed, Jan 31, 2018 at 5:03 PM, Dan Williams <dan.j.williams@intel.com> wr=
ote:
> On Wed, Jan 31, 2018 at 4:45 PM, Andiry Xu <andiry@gmail.com> wrote:
>> PMEM/DAX should allow for significant improvements in file system
>> performance and enable new programming models that allow direct,
>> efficient access to PMEM from userspace.  Achieving these gains in
>> existing file systems built for block devices (e.g., XFS and EXT4=E2=80=
=A6)
>> presents a range of challenges (e.g.,
>> https://lkml.org/lkml/2016/9/11/159) and has been the subject of a lot
>> of recent work on ext4 and xfs.
>>
>> An alternative is to build a NVMM-aware file system from scratch that
>> takes full advantage of the performance that PMEM offers and avoids
>> the complexity that block-based file systems include to maximize
>> performance on slow storage (e.g., relaxing atomicity constraints on
>> many operations).  Of course, it also brings with it the complexity of
>> another file system.
>>
>> We recently sent out a patch set for one-such =E2=80=9Cclean slate=E2=80=
=9D NVMM-aware
>> file system called NOVA.  NOVA is log-structured DAX file system with
>> several nice features:
>>
>> * High performance, especially in metadata operations due to efficient
>> fine-grained logging
>> * High scalability with per-CPU memory pool and per-inode logging
>> * Strong metadata and data atomicity guarantees for all operations
>> * Full filesystem snapshot support with DAX-mmap
>> * Metadata replication/checksums and RAID-4 style data protection
>>
>> At the summit, we would like to discuss the trade-offs between
>> adapting NVMM features to existing file systems vs. creating/adopting
>> a purpose-built file system for NVMM.  NOVA serves as useful starting
>> point for that discussion by demonstrating what=E2=80=99s possible.  It =
may
>> also suggest some features that could be adapted to other file systems
>> to improve NVMM performance.
>>
>> We welcome people that are interested in file systems and NVM/DAX.
>> Particular people that would be useful to have in attendance are Dan
>> Williams, Dave Chinner, and Matthew Wilcox.
>
> The rest of the fs-dax crew would also be useful to have:
>
> Jan Kara
> Ross Zwisler

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
