Return-Path: <SRS0=bR/Z=QL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_PASS,USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E2370C4151A
	for <linux-mm@archiver.kernel.org>; Mon,  4 Feb 2019 05:21:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 516042147A
	for <linux-mm@archiver.kernel.org>; Mon,  4 Feb 2019 05:21:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="f0pr5qH2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 516042147A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BDEEA8E0031; Mon,  4 Feb 2019 00:21:42 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B65A88E001C; Mon,  4 Feb 2019 00:21:42 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A04388E0031; Mon,  4 Feb 2019 00:21:42 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 50A388E001C
	for <linux-mm@kvack.org>; Mon,  4 Feb 2019 00:21:42 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id 68so11543628pfr.6
        for <linux-mm@kvack.org>; Sun, 03 Feb 2019 21:21:42 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=AAdJiiltZZLOXLdr7jkV/8HdkHy1m1zzMxkGsX6zpJo=;
        b=p6x8bTQUa4XHs3ez8irRUL5LIpgXpjqK93BBjdIXGaWD4ad6s1RsbwVK9vZnEFn82c
         ugx6jVQuVhj18ggSTkp3Xya/UmTnO5XSsFJaalrSapQGfeK1ZTUV5UgnOorQcMoinIZG
         DoAwKAhj1qALpr9YgcTIT+G9WVIPLaz9X+oH7gr9B2GZGWY1b3UFDvFTem2kd3ChKNj1
         AiyFLz8q+hrDeEndYwmTaYIQgOVFQ75KzNOgPIYf9/qFxaN7S3J23NhMWRBWx2vP5c0D
         Sg9iU9AhpTEPcM7pcBkgJXG/SXj0um9056PBa9jIMnDyNAC6fabpMeOhqo/wa856Ohkh
         zTpA==
X-Gm-Message-State: AJcUukdP/YdqOmliH6Zno8NRKqTxgS4GOaW9Xenb+YeUMfMt5hy4a/70
	ZzNi4ssPg7Sqoms70Kv8WVWHkCvFvPI8a3AwL3RKTXaT0vlpj+A/9kMwzkeD61i9k/OEOtyMUkV
	9xFHDUuNHwcoSTbYD2tC+e+sycu8M1ZQNVo2i6gFUtqabjlxUnsJHdiv3YqeCoSKrwk5K7QEz+R
	+q5kkrDKt5hnMwqAOVY1ltlqePsl6kgEMqgpjvqh7NVlVYRphCGT080kt6pvS5G1AZ30KFGW6UG
	phvOiMF2Sg7XwgZ1OaYIgP+sw8QLk04Q5x90S7ULTIrrpQeFh8iChSl6e6Btmk73s8+XdbRYZel
	I6N620cryiwG5Z7b0phr6wHw5Np+alTHRZKeam6U1ZfeVdNthHI2u+Ks8eWWeeDgfJpbiLRkY90
	s
X-Received: by 2002:a17:902:6e0f:: with SMTP id u15mr49441084plk.175.1549257701654;
        Sun, 03 Feb 2019 21:21:41 -0800 (PST)
X-Received: by 2002:a17:902:6e0f:: with SMTP id u15mr49441017plk.175.1549257700279;
        Sun, 03 Feb 2019 21:21:40 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549257700; cv=none;
        d=google.com; s=arc-20160816;
        b=OLA7tueZqi80yen05h72dUeOxAd6+I+DzP19dRtqJdDZA3NeH9ZNIi1ursZJ8pDV5f
         55XjIvxD7UHWpVqvy6Upn1mOhut/vSw+FPAsrfVM+HUB3x62ivTy/XE+PTtjJMQIldhS
         0IEvPqFznHsyCcvqlh5nqb0waxwEt+/0cD/lYFQF5uU5OgxH9O0vJGSPe5xcoJzLqD1s
         4D511f1QbEiIEIS6n4jswxE6VVS1gbB6g2c5HPE4lKt8I+DPB+X602X5wLZ85aKaWPxW
         r3sOKr/5yvdAf1Nm5lmafoIjMmp1EFxocf30Hg7bMZ7Qp3C/j8LL8C3FLuzQUZbU8KZY
         6NyA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=AAdJiiltZZLOXLdr7jkV/8HdkHy1m1zzMxkGsX6zpJo=;
        b=EwmMgVgBtCdrYseljojATHzztpDIVyC3L50TsHoJOf94Y5oS2n7pM4OrPrFCd1I1D3
         IkxmeGHm4LFoHpZuxFXTd2XthVnO9/wRjVF9oR1acLGJFSvPHmJyIQJxC47UXkdzxMxB
         dZje3cJPxDfMfXVunEw+4MFet1PlvChNhmKRhuKyG47t716kXsg016DSOsbwEDWTTHgU
         WH/L8MOWq0lmf9VrpgCXvVKJ8Xje4IRv+Np+rZVtYlTNBu0rg6qrDgkyPL6hJ6Q/DbDZ
         PhhAPyfOI2Z+bRCqDEqOqR7D2QID1cE5PUylZ9sJSV/fy5yNr3/V4CrY1hTVZDbjB2Ih
         X46A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=f0pr5qH2;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 67sor24782056pgb.68.2019.02.03.21.21.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 03 Feb 2019 21:21:40 -0800 (PST)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=f0pr5qH2;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=AAdJiiltZZLOXLdr7jkV/8HdkHy1m1zzMxkGsX6zpJo=;
        b=f0pr5qH2ceqYnwy4NzlZqXPFeEsW0dPK7l0auaAXQAV8uFe0YhGxm+xzwobfZ2agWT
         ZUztfqS3yfAzgwjQVZZ4xlpXh/EKWQbgHbCUr+tlfxJR5W2x1UTUYk6Xv+u58+J6KaJE
         JZ4gOj+gK3iCfzWgSuRRlF2pqMrKIFF87H/lP1VCvAayXK0oHuzk7IBV+UL9efl3XgV9
         FMWAiSb/Ysm4PTg0XYQlvGH3jAELPuCG0yqBJEWMwqNy7YaGP3+JPKUVQOzDazzsjZov
         6/Cb/c+BzuQ1aSTEadf4QzLZ7y0oBEGRpTzA9GOE7Anx1MpUiJCIB3CK97lnDuO80L3Z
         4M9A==
X-Google-Smtp-Source: AHgI3IbI1MNtzIl+0rlycvUO9WIozB16OYwShyKnndyz0yGSwO8mjfEjjv3gWsqu+JeOz2ZeP2klfA==
X-Received: by 2002:a65:60c5:: with SMTP id r5mr7411589pgv.427.1549257699491;
        Sun, 03 Feb 2019 21:21:39 -0800 (PST)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id m9sm33428844pgd.32.2019.02.03.21.21.37
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 03 Feb 2019 21:21:38 -0800 (PST)
From: john.hubbard@gmail.com
X-Google-Original-From: jhubbard@nvidia.com
To: Andrew Morton <akpm@linux-foundation.org>,
	linux-mm@kvack.org
Cc: Al Viro <viro@zeniv.linux.org.uk>,
	Christian Benvenuti <benve@cisco.com>,
	Christoph Hellwig <hch@infradead.org>,
	Christopher Lameter <cl@linux.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Dave Chinner <david@fromorbit.com>,
	Dennis Dalessandro <dennis.dalessandro@intel.com>,
	Doug Ledford <dledford@redhat.com>,
	Jan Kara <jack@suse.cz>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	Jerome Glisse <jglisse@redhat.com>,
	Matthew Wilcox <willy@infradead.org>,
	Michal Hocko <mhocko@kernel.org>,
	Mike Rapoport <rppt@linux.ibm.com>,
	Mike Marciniszyn <mike.marciniszyn@intel.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	Tom Talpey <tom@talpey.com>,
	LKML <linux-kernel@vger.kernel.org>,
	linux-fsdevel@vger.kernel.org,
	John Hubbard <jhubbard@nvidia.com>
Subject: [PATCH 0/6] RFC v2: mm: gup/dma tracking
Date: Sun,  3 Feb 2019 21:21:29 -0800
Message-Id: <20190204052135.25784-1-jhubbard@nvidia.com>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
X-NVConfidentiality: public
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: John Hubbard <jhubbard@nvidia.com>

Hi,

I'm calling this RFC v2, even though with all the discussion it actually
feels
like about v7 or so. But now that the dust has settled, it's time to show a
surprisingly small, cleaner approach. Jan and Jerome came up with a scheme
(discussed in more detail in "track gup-pinned pages" commit description)
that
does not require any additional struct page fields. This approach has the
additional advantage of being very lightweight and therefore fast, because

    a) it mostly just does atomics,

    b) unlike previous approaches, there is no need to remove and re-add to
       LRUs.

    c) it uses the same lock-free algorithms that get_user_pages already
       relies upon.

This RFC shows the following:

1) A patch to get the call site conversion started:

    mm: introduce put_user_page*(), placeholder versions

2) A sample call site conversion:

    infiniband/mm: convert put_page() to put_user_page*()

  ...NOT shown: all of the other 100+ gup call site conversions. Again,
  those are in various states of progress and disrepair, at [1].

3) Tracking, instrumentation, and documentation patches, once all the call
   sites have been converted.

4) A small refactoring patch that I'm also going to submit separately, for
   the page_cache_add_speculative() routine.

This seems to be working pretty well here.  I've converted enough call sites
(there is git repo [1] with that, which gets rebased madly, but it's there if
you really want to try some early testing) to run things such as fio.

Performance: here is an fio run on an NVMe drive, using this for the fio
configuration file:

    [reader]
    direct=1
    ioengine=libaio
    blocksize=4096
    size=1g
    numjobs=1
    rw=read
    iodepth=64

reader: (g=0): rw=read, bs=(R) 4096B-4096B, (W) 4096B-4096B, (T) 4096B-4096B, ioengine=libaio, iodepth=64
fio-3.3
Starting 1 process
Jobs: 1 (f=1)
reader: (groupid=0, jobs=1): err= 0: pid=7011: Sun Feb  3 20:36:51 2019
   read: IOPS=190k, BW=741MiB/s (778MB/s)(1024MiB/1381msec)
    slat (nsec): min=2716, max=57255, avg=4048.14, stdev=1084.10
    clat (usec): min=20, max=12485, avg=332.63, stdev=191.77
     lat (usec): min=22, max=12498, avg=336.72, stdev=192.07
    clat percentiles (usec):
     |  1.00th=[  322],  5.00th=[  322], 10.00th=[  322], 20.00th=[  326],
     | 30.00th=[  326], 40.00th=[  326], 50.00th=[  326], 60.00th=[  326],
     | 70.00th=[  326], 80.00th=[  330], 90.00th=[  330], 95.00th=[  330],
     | 99.00th=[  478], 99.50th=[  717], 99.90th=[ 1074], 99.95th=[ 1090],
     | 99.99th=[12256]
   bw (  KiB/s): min=730152, max=776512, per=99.22%, avg=753332.00, stdev=32781.47, samples=2
   iops        : min=182538, max=194128, avg=188333.00, stdev=8195.37, samples=2
  lat (usec)   : 50=0.01%, 100=0.01%, 250=0.07%, 500=99.26%, 750=0.38%
  lat (usec)   : 1000=0.02%
  lat (msec)   : 2=0.24%, 20=0.02%
  cpu          : usr=15.07%, sys=84.13%, ctx=10, majf=0, minf=74
  IO depths    : 1=0.1%, 2=0.1%, 4=0.1%, 8=0.1%, 16=0.1%, 32=0.1%, >=64=100.0%
     submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     complete  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.1%, >=64=0.0%
     issued rwts: total=262144,0,0,0 short=0,0,0,0 dropped=0,0,0,0
     latency   : target=0, window=0, percentile=100.00%, depth=64

Run status group 0 (all jobs):
   READ: bw=741MiB/s (778MB/s), 741MiB/s-741MiB/s (778MB/s-778MB/s), io=1024MiB (1074MB), run=1381-1381msec

Disk stats (read/write):
  nvme0n1: ios=216966/0, merge=0/0, ticks=6112/0, in_queue=704, util=91.34%

A write up of the larger problem follows (co-written with Jérôme Glisse):

Overview
========

Some kernel components (file systems, device drivers) need to access
memory that is specified via process virtual address. For a long time, the
API to achieve that was get_user_pages ("GUP") and its variations. However,
GUP has critical limitations that have been overlooked; in particular, GUP
does not interact correctly with filesystems in all situations. That means
that file-backed memory + GUP is a recipe for potential problems, some of
which have already occurred in the field.

GUP was first introduced for Direct IO (O_DIRECT), allowing filesystem code
to get the struct page behind a virtual address and to let storage hardware
perform a direct copy to or from that page. This is a short-lived access
pattern, and as such, the window for a concurrent writeback of GUP'd page
was small enough that there were not (we think) any reported problems.
Also, userspace was expected to understand and accept that Direct IO was
not synchronized with memory-mapped access to that data, nor with any
process address space changes such as munmap(), mremap(), etc.

Over the years, more GUP uses have appeared (virtualization, device
drivers, RDMA) that can keep the pages they get via GUP for a long period
of time (seconds, minutes, hours, days, ...). This long-term pinning makes
an underlying design problem more obvious.

In fact, there are a number of key problems inherent to GUP:

Interactions with file systems
==============================

File systems expect to be able to write back data, both to reclaim pages,
and for data integrity. Allowing other hardware (NICs, GPUs, etc) to gain
write access to the file memory pages means that such hardware can dirty the
pages, without the filesystem being aware. This can, in some cases
(depending on filesystem, filesystem options, block device, block device
options, and other variables), lead to data corruption, and also to kernel
bugs of the form:

    kernel BUG at /build/linux-fQ94TU/linux-4.4.0/fs/ext4/inode.c:1899!
    backtrace:
        ext4_writepage
        __writepage
        write_cache_pages
        ext4_writepages
        do_writepages
        __writeback_single_inode
        writeback_sb_inodes
        __writeback_inodes_wb
        wb_writeback
        wb_workfn
        process_one_work
        worker_thread
        kthread
        ret_from_fork

...which is due to the file system asserting that there are still buffer
heads attached:

        ({                                                      \
                BUG_ON(!PagePrivate(page));                     \
                ((struct buffer_head *)page_private(page));     \
        })

Dave Chinner's description of this is very clear:

    "The fundamental issue is that ->page_mkwrite must be called on every
    write access to a clean file backed page, not just the first one.
    How long the GUP reference lasts is irrelevant, if the page is clean
    and you need to dirty it, you must call ->page_mkwrite before it is
    marked writeable and dirtied. Every. Time."

This is just one symptom of the larger design problem: filesystems do not
actually support get_user_pages() being called on their pages, and letting
hardware write directly to those pages--even though that pattern has been
going on since about 2005 or so.

Long term GUP
=============

Long term GUP is an issue when FOLL_WRITE is specified to GUP (so, a
writeable mapping is created), and the pages are file-backed. That can lead
to filesystem corruption. What happens is that when a file-backed page is
being written back, it is first mapped read-only in all of the CPU page
tables; the file system then assumes that nobody can write to the page, and
that the page content is therefore stable. Unfortunately, the GUP callers
generally do not monitor changes to the CPU pages tables; they instead
assume that the following pattern is safe (it's not):

    get_user_pages()

    Hardware can keep a reference to those pages for a very long time,
    and write to it at any time. Because "hardware" here means "devices
    that are not a CPU", this activity occurs without any interaction
    with the kernel's file system code.

    for each page
        set_page_dirty
        put_page()

In fact, the GUP documentation even recommends that pattern.

Anyway, the file system assumes that the page is stable (nothing is writing
to the page), and that is a problem: stable page content is necessary for
many filesystem actions during writeback, such as checksum, encryption,
RAID striping, etc. Furthermore, filesystem features like COW (copy on
write) or snapshot also rely on being able to use a new page for as memory
for that memory range inside the file.

Corruption during write back is clearly possible here. To solve that, one
idea is to identify pages that have active GUP, so that we can use a bounce
page to write stable data to the filesystem. The filesystem would work
on the bounce page, while any of the active GUP might write to the
original page. This would avoid the stable page violation problem, but note
that it is only part of the overall solution, because other problems
remain.

Other filesystem features that need to replace the page with a new one can
be inhibited for pages that are GUP-pinned. This will, however, alter and
limit some of those filesystem features. The only fix for that would be to
require GUP users monitor and respond to CPU page table updates. Subsystems
such as ODP and HMM do this, for example. This aspect of the problem is
still under discussion.

Direct IO
=========

Direct IO can cause corruption, if userspace does Direct-IO that writes to
a range of virtual addresses that are mmap'd to a file.  The pages written
to are file-backed pages that can be under write back, while the Direct IO
is taking place.  Here, Direct IO need races with a write back: it calls
GUP before page_mkclean() has replaced the CPU pte with a read-only entry.
The race window is pretty small, which is probably why years have gone by
before we noticed this problem: Direct IO is generally very quick, and
tends to finish up before the filesystem gets around to do anything with
the page contents.  However, it's still a real problem.  The solution is
to never let GUP return pages that are under write back, but instead,
force GUP to take a write fault on those pages.  That way, GUP will
properly synchronize with the active write back.  This does not change the
required GUP behavior, it just avoids that race.

What this patchset does
=======================

This patchset overloads page->_refcount, in order to track GUP-pinned
pages.

This patchset checks if the page is under write back, and if so, it backs
off and forces a page fault (via the GUP slow path). Before this patchset,
GUP might have returned the struct page because page_mkclean() had not yet
updated the CPU page table. After this patch, GUP no longer race with
page_mkclean() and thus any user of GUP properly synchronize on active
write back (this is not only useful to direct-IO, but also to other users
of GUP).

This patchset does not include any of the filesystem changes needed to
fix the issues. That is left as a separate patchset that will use the
new flag.


Changes from earlier versions
=============================

-- Fixed up kerneldoc issues in put_user_page*() functions, in response
   to Mike Rapoport's review.

-- Use overloaded page->_refcount to track gup-pinned pages. This avoids the
   need for an extra page flag, and also avoids the need for an extra counting
   field.

[1] git@github.com:johnhubbard/linux.git (branch: gup_dma_core)
[2] https://lwn.net/Articles/753027/ "The trouble with get_user_pages()"

Suggested-by: Jan Kara <jack@suse.cz>
Suggested-by: Jérôme Glisse <jglisse@redhat.com>

Cc: Christian Benvenuti <benve@cisco.com>
Cc: Christoph Hellwig <hch@infradead.org>
Cc: Christopher Lameter <cl@linux.com>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Dave Chinner <david@fromorbit.com>
Cc: Dennis Dalessandro <dennis.dalessandro@intel.com>
Cc: Doug Ledford <dledford@redhat.com>
Cc: Jan Kara <jack@suse.cz>
Cc: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Jérôme Glisse <jglisse@redhat.com>
Cc: Matthew Wilcox <willy@infradead.org>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Mike Rapoport <rppt@linux.ibm.com>
Cc: Mike Marciniszyn <mike.marciniszyn@intel.com>
Cc: Ralph Campbell <rcampbell@nvidia.com>
Cc: Tom Talpey <tom@talpey.com>


John Hubbard (6):
  mm: introduce put_user_page*(), placeholder versions
  infiniband/mm: convert put_page() to put_user_page*()
  mm: page_cache_add_speculative(): refactoring
  mm/gup: track gup-pinned pages
  mm/gup: /proc/vmstat support for get/put user pages
  mm/gup: Documentation/vm/get_user_pages.rst, MAINTAINERS

 Documentation/vm/get_user_pages.rst         | 197 ++++++++++++++++++++
 Documentation/vm/index.rst                  |   1 +
 MAINTAINERS                                 |  10 +
 drivers/infiniband/core/umem.c              |   7 +-
 drivers/infiniband/core/umem_odp.c          |   2 +-
 drivers/infiniband/hw/hfi1/user_pages.c     |  11 +-
 drivers/infiniband/hw/mthca/mthca_memfree.c |   6 +-
 drivers/infiniband/hw/qib/qib_user_pages.c  |  11 +-
 drivers/infiniband/hw/qib/qib_user_sdma.c   |   6 +-
 drivers/infiniband/hw/usnic/usnic_uiom.c    |   7 +-
 include/linux/mm.h                          |  57 ++++++
 include/linux/mmzone.h                      |   5 +
 include/linux/pagemap.h                     |  36 ++--
 mm/gup.c                                    |  80 ++++++--
 mm/swap.c                                   | 104 +++++++++++
 mm/vmstat.c                                 |   5 +
 16 files changed, 482 insertions(+), 63 deletions(-)
 create mode 100644 Documentation/vm/get_user_pages.rst

-- 
2.20.1

