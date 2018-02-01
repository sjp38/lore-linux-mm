Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 06DF36B0003
	for <linux-mm@kvack.org>; Wed, 31 Jan 2018 21:12:22 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id i124so505779ita.0
        for <linux-mm@kvack.org>; Wed, 31 Jan 2018 18:12:22 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a125sor1446952ioa.24.2018.01.31.18.12.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 31 Jan 2018 18:12:20 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20180201014749.GF4841@magnolia>
References: <CAOvWMLZVkQ1D=Jn-_O9owewr7U699bN=dmwuBoDnQVLEkkXJ8A@mail.gmail.com>
 <20180201014749.GF4841@magnolia>
From: Andiry Xu <jix024@eng.ucsd.edu>
Date: Wed, 31 Jan 2018 18:12:19 -0800
Message-ID: <CAD4Szjt8ayQYjCPzkuOnRXkRtLg4CNmBT1R29VAJXBkFh+vymw@mail.gmail.com>
Subject: Re: [LSF/MM TOPIC] Native NVMM file systems
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: Andiry Xu <andiry@gmail.com>, lsf-pc@lists.linux-foundation.org, Linux FS Devel <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@ml01.01.org>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, willy@infradead.org, Steven Swanson <swanson@cs.ucsd.edu>, Andiry Xu <jix024@cs.ucsd.edu>

On Wed, Jan 31, 2018 at 5:47 PM, Darrick J. Wong
<darrick.wong@oracle.com> wrote:
> On Wed, Jan 31, 2018 at 04:45:36PM -0800, Andiry Xu wrote:
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
>
> That's the series that was sent out last August, correct?
>

Yes. We are preparing another round of submission.

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
> I wouldn't mind being there too. :)
>

Welcome:)

Thanks,
Andiry

> --D
>
>>
>> Thanks,
>> Andiry

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
