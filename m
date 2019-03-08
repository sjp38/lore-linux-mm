Return-Path: <SRS0=92PK=RL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C0982C43381
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 21:36:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 629A220652
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 21:36:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="QNTO0WU8"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 629A220652
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 00A898E0004; Fri,  8 Mar 2019 16:36:46 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EFCE98E0002; Fri,  8 Mar 2019 16:36:45 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DEB168E0004; Fri,  8 Mar 2019 16:36:45 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 99BF18E0002
	for <linux-mm@kvack.org>; Fri,  8 Mar 2019 16:36:45 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id 73so21643367pga.18
        for <linux-mm@kvack.org>; Fri, 08 Mar 2019 13:36:45 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=R8pjqCJyuCOC9qIxLWExhAZb4xVkg5yY/1ua3SMhyTU=;
        b=kDTW7sgHX5Q2JiJKtpUcdq9fB6pl7aIyv2Y4ObKHEhEzSN3mdeVWwaRFFhsLsBTkKs
         OghAMLhg4UtLAxpX9mqfyFMuDCO4388bKme8ild4kz9dnKsM4HuB1vzWREol4Ddxo9yY
         WP4ms9LB2+VuyIfg5BXE9I/wiWjiNa5XKth8TM1h1+ajZcqspEySJ3HnFPZ/oTQgGk+8
         q0v2aPEIsgc8PgmxhfZgR9zEoggkNVY9dYKUAlDtk9X7AfOmGdPLioDS4rCqr5LMEsOI
         rsTxZ3ejxvyK3q6miydXeY7Z9AXFjJaLp/5ovQfp0AkUDuxoUKGk5UFrBX/yyWfc4+eT
         umkg==
X-Gm-Message-State: APjAAAXA3uhPEMZtuPmGmQFZyze4BauUbty3PxYchvsOyJrBPpm19kb/
	1dBqQ3hfpm3EMHr2dHN5mBvqCLv8+0soHFD5mu+8hUWh7NekeWzIOolWgf1+cdUc+0zzyTb5+l0
	z3CcY+bOf0p9JIhnSR+wM7giB0oAjUSoF7G85lJh2Qc/Jv9pqC+MdSFiyH168jCfZzx/n0qjIU1
	lBQkM1PHQzK4489dfRqE3UFHz1mhTDrWHUNbCRMeLWPfXryeH9VVVm9orJG76cYK9zTQa6qn93S
	czOS4CBZ2MJ+MbaEuL0ePzOt2gpw58DduwICRD1ceKfnPOHLT9+r9Tk/c4txHGkAJrE/pv/wHW7
	h5r4OCP+pwTIwHUmHZVYrJAGxKHqPWLlQ5iUMlNvDcUDdo5vleEcXMqX4O8oUWvyS3Vj7UokxlC
	a
X-Received: by 2002:a62:1c43:: with SMTP id c64mr20558774pfc.259.1552081005201;
        Fri, 08 Mar 2019 13:36:45 -0800 (PST)
X-Received: by 2002:a62:1c43:: with SMTP id c64mr20558678pfc.259.1552081003792;
        Fri, 08 Mar 2019 13:36:43 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1552081003; cv=none;
        d=google.com; s=arc-20160816;
        b=hZfT1ZHL2YoUjGg+9PZ+08+2D16iV2IlgnAKGgYvEEYHyEWawZbaz88LgohkEH5S6c
         2Fji4v5/nrwtrjIwKPBQCbS+8UPjxxs/BohwFLO888pA4W2rSk8B/QD3CL0nYeVN5czj
         cA5HRWKu25whP/famcqr74XLozE6j1wvAJAUGqt+54RClHzxj7kLFv7T7mTCwVeXuBzp
         30bYaVqB/2S5k/uX7T3rbI93kXM9Oef4pbZ2jD5Qjlv7Y6+8pUbunCzA5cBIee0k9M3b
         1r/4gXW2km31l8TEuVSFGFXRurIHPMZste8rKlrc2MTTkt5+sxqlGFRfcYzj6Opd7LkP
         i0uw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=R8pjqCJyuCOC9qIxLWExhAZb4xVkg5yY/1ua3SMhyTU=;
        b=ESsEh68lIpa/CWMFSaaEulbEDAsgF8sKQThdwhoeo6d7E557q6bZui2ut6KVvdBB9t
         uQZENmuaD3xtbOt86YpllQ/gWujK6xz5anynE5WOwz1uE+zIcRyXfU8e4iGVTAoiIDJF
         LpEP8vcqWterD4uznwAuNpLqirZZ6ww5pB+oInnJ5+yodIBJcuAetd9/MyCUzgay6IuD
         afC32JKeZqe8mW4vjLfpF5duTscsjR7hPPBclf9R6W/zhzSf77gyEPjYCpWoQdzEduFz
         GSgGLuRf8jByUzfRZrR4jBcuf3nMYKAHrP0IWaLOwmeUgF0B6LyDHyHgLU8uD3vUhQ3M
         bUYA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=QNTO0WU8;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 62sor14432952ple.72.2019.03.08.13.36.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 08 Mar 2019 13:36:43 -0800 (PST)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=QNTO0WU8;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=R8pjqCJyuCOC9qIxLWExhAZb4xVkg5yY/1ua3SMhyTU=;
        b=QNTO0WU8+ixmJ22Rnrjz68AdSVgpgICB9uk7ItHCy9HTrpdvbgClWSo8fVtxDvOtGn
         axjt1l9RTOdJFZV+RzhemigSw43NH/5Nr2uhlmOBOclDiyqdV6JS4P7SSRgL+5RFVMSd
         DQ21zVOp615X2qwmjG4iKPvUULTRVFUNHdpoy0+BnK49ZKfyUEd+/xdb2PbsJx+etXyl
         3onxKw4hX5E3naz8Jwg+rdj7ckCw1jwM72aCeR/7sOO35c1M4Am5iSE10SWwc2FpAMBV
         feRUfk1hfuIfRIuEL+ywjmemSRxQD2bkijC7wYN2HJDWg2FVcfF3019BlJJeEgA1qtyD
         gxlg==
X-Google-Smtp-Source: APXvYqzBK+M1uDC+BRaBhjDUHnMAXagND1pk9LFJymgS/dyF4dszKAnpEKz5FsA83W5cHrsesI57Zw==
X-Received: by 2002:a17:902:765:: with SMTP id 92mr20505285pli.95.1552081003342;
        Fri, 08 Mar 2019 13:36:43 -0800 (PST)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id c2sm11803665pfd.159.2019.03.08.13.36.41
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Mar 2019 13:36:42 -0800 (PST)
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
	Ira Weiny <ira.weiny@intel.com>,
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
Subject: [PATCH v4 0/1] mm: introduce put_user_page*(), placeholder versions
Date: Fri,  8 Mar 2019 13:36:32 -0800
Message-Id: <20190308213633.28978-1-jhubbard@nvidia.com>
X-Mailer: git-send-email 2.21.0
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

Hi Andrew and all,

Can we please apply this (destined for 5.2) once the time is right?
(I see that -mm just got merged into the main tree today.)

We seem to have pretty solid consensus on the concept and details of the
put_user_pages() approach. Or at least, if we don't, someone please speak
up now. Christopher Lameter, especially, since you had some concerns
recently.

Therefore, here is the first patch--only. This allows us to begin
converting the get_user_pages() call sites to use put_user_page(), instead
of put_page(). This is in order to implement tracking of get_user_page()
pages.

Normally I'd include a user of this code, but in this case, I think we have
examples of how it will work in the RFC and related discussions [1]. What
matters more at this point is unblocking the ability to start fixing up
various subsystems, through git trees other than linux-mm. For example, the
Infiniband example conversion now needs to pick up some prerequisite
patches via the RDMA tree. It seems likely that other call sites may need
similar attention, and so having put_user_pages() available would really
make this go more quickly.

Previous cover letter follows:
==============================

A discussion of the overall problem is below.

As mentioned in patch 0001, the steps are to fix the problem are:

1) Provide put_user_page*() routines, intended to be used
   for releasing pages that were pinned via get_user_pages*().

2) Convert all of the call sites for get_user_pages*(), to
   invoke put_user_page*(), instead of put_page(). This involves dozens of
   call sites, and will take some time.

3) After (2) is complete, use get_user_pages*() and put_user_page*() to
   implement tracking of these pages. This tracking will be separate from
   the existing struct page refcounting.

4) Use the tracking and identification of these pages, to implement
   special handling (especially in writeback paths) when the pages are
   backed by a filesystem.

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
write access to the file memory pages means that such hardware can dirty
the pages, without the filesystem being aware. This can, in some cases
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

This is just one symptom of the larger design problem: real filesystems
that actually write to a backing device, do not actually support
get_user_pages() being called on their pages, and letting hardware write
directly to those pages--even though that pattern has been going on since
about 2005 or so.


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
require GUP users to monitor and respond to CPU page table updates.
Subsystems such as ODP and HMM do this, for example. This aspect of the
problem is still under discussion.

Direct IO
=========

Direct IO can cause corruption, if userspace does Direct-IO that writes to
a range of virtual addresses that are mmap'd to a file.  The pages written
to are file-backed pages that can be under write back, while the Direct IO
is taking place.  Here, Direct IO races with a write back: it calls
GUP before page_mkclean() has replaced the CPU pte with a read-only entry.
The race window is pretty small, which is probably why years have gone by
before we noticed this problem: Direct IO is generally very quick, and
tends to finish up before the filesystem gets around to do anything with
the page contents.  However, it's still a real problem.  The solution is
to never let GUP return pages that are under write back, but instead,
force GUP to take a write fault on those pages.  That way, GUP will
properly synchronize with the active write back.  This does not change the
required GUP behavior, it just avoids that race.

Changes since v3:

 * Moved put_user_page*() implementation from swap.c to gup.c, as per
   Jerome's review recommendation.

 * Updated wording in patch #1 (and in this cover letter) to refer to real
   filesystems with a backing store, as per Christopher Lameter's feedback.

 * Rebased to latest linux.git: commit 3601fe43e816 ("Merge tag
   'gpio-v5.1-1' of git://git.kernel.org/pub/scm/linux/kernel/git/linusw/linux-gpio")

Changes since v2:

 * Reduced down to just one patch, in order to avoid dependencies between
   subsystem git repos.

 * Rebased to latest linux.git: commit afe6fe7036c6 ("Merge tag
   'armsoc-late' of git://git.kernel.org/pub/scm/linux/kernel/git/soc/soc")

 * Added Ira's review tag, based on
   https://lore.kernel.org/lkml/20190215002312.GC7512@iweiny-DESK2.sc.intel.com/


[1] https://lore.kernel.org/r/20190208075649.3025-3-jhubbard@nvidia.com
    (RFC v2: mm: gup/dma tracking)

Cc: Christian Benvenuti <benve@cisco.com>
Cc: Christoph Hellwig <hch@infradead.org>
Cc: Christopher Lameter <cl@linux.com>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Dave Chinner <david@fromorbit.com>
Cc: Dennis Dalessandro <dennis.dalessandro@intel.com>
Cc: Doug Ledford <dledford@redhat.com>
Cc: Ira Weiny <ira.weiny@intel.com>
Cc: Jan Kara <jack@suse.cz>
Cc: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Jérôme Glisse <jglisse@redhat.com>
Cc: Matthew Wilcox <willy@infradead.org>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Mike Rapoport <rppt@linux.ibm.com>
Cc: Mike Marciniszyn <mike.marciniszyn@intel.com>
Cc: Ralph Campbell <rcampbell@nvidia.com>
Cc: Tom Talpey <tom@talpey.com>

John Hubbard (1):
  mm: introduce put_user_page*(), placeholder versions

 include/linux/mm.h | 24 ++++++++++++++
 mm/gup.c           | 82 ++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 106 insertions(+)

-- 
2.21.0

