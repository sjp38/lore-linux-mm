Return-Path: <SRS0=43/C=RJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 13F62C43381
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 23:55:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9A75E20684
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 23:55:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="RAuZ8i3f"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9A75E20684
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3A4718E0003; Wed,  6 Mar 2019 18:55:01 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 355618E0002; Wed,  6 Mar 2019 18:55:01 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1F7178E0003; Wed,  6 Mar 2019 18:55:01 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id D01E58E0002
	for <linux-mm@kvack.org>; Wed,  6 Mar 2019 18:55:00 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id g197so15431076pfb.15
        for <linux-mm@kvack.org>; Wed, 06 Mar 2019 15:55:00 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=U8OzCzrlqLZ6KobCTgtfavOqwIbWF6/ADR96fWt0LK0=;
        b=Pf5yfh9BUFrH0GS9R3yAiZ6dg9QW3df1Wrqo5WnnLfPZltvu0EO4dXnoJhS28KOBbz
         MXQ0RWlc0JX+Ob5zVoOsKewUekBwK1k//LBhhLBSQ7ZgLbZbstRgcAp5ELeGLS57QZ7+
         fczh7eZsAhvZwQfroqDviFiJ1ISebSc0xPZUoVnNp/u5I9CgJ2PUlfqN2xnqczK00tK3
         1qicSzn4JPQsY7VNmQe+tDvGP7Tm6S/nfJfuGoniBZW9oyfpcQiyIyPYDgfJNze0Ovtt
         pACRZpcLax4HBChRcMeJoU77MLam1wNfrEIsfSb30/mr9rUsaiylAOx+AKVBLYYuT46U
         6qyw==
X-Gm-Message-State: APjAAAVTv2K+hpuBdvIQYDV5jqG7pZ6EEPqNZaXcTf406X4aBjcH1wos
	1WQPAkIHQFzZNKawbwUn6XGOzfRQ6WOXbqTNqorth2+KG4FDc8n+0kdF+wjB+QzSZZJMER28BbA
	LNlUWz0cksLd4kE7LCY/qmZRSPURug9OQ6FWwH0iw+wtBgLQpzCLnlg3YUG80/MmnaL+zFlFGEo
	XTyovQALNxIIi2FlcSY7nq8uk+0dyAFO/JRybsJso8qEUQI3Rzn/V2ebyW/aYGS87t93b9JTwor
	zhBp7nhKcUYDev5XcqozB4i4kWpCXrUD7GRWiN0e06tJ682j39P5E9e6yZDih/gxeTHHik+rVUJ
	V10T5Mfg0CQkUFUq7RQwpvDMn45WXIm6LF1aV+qu8bf15cO3YbMwdrMfolCLy3GgmISHMkVR8Uw
	N
X-Received: by 2002:a62:64d1:: with SMTP id y200mr9838220pfb.161.1551916500445;
        Wed, 06 Mar 2019 15:55:00 -0800 (PST)
X-Received: by 2002:a62:64d1:: with SMTP id y200mr9838156pfb.161.1551916499103;
        Wed, 06 Mar 2019 15:54:59 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551916499; cv=none;
        d=google.com; s=arc-20160816;
        b=HrHlc12sDORKh4SwJxuV4dq9t/RTIf6o9Ozs0t/By8H7T3KXFG8VoJw9WPCjI0zc7U
         6cKFrvjIoCZpGcUft2ObrteOerixWhxTrNCprHdeBMC2zm9icywD2Mn76rV77Xojey/p
         3dzIwiGVeM/N6n7wYiXrHNr6c0U5Xg5DdUhLXyKQ93Lw07+f3KhkH9ea2KFepCUxpyvs
         urmgCwg/dqHwlhfhb/DP8Lgf/3E5CxEP05cu/qJ9+YZ1ZtPD78GZo3HgE3zOVwllENAa
         VgxlENasql2DGxSJrxV80jtuLIPRhL7xffwZVnZcP6G8vgOyMLYP7V8t3pguqob2OxcR
         wxsw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=U8OzCzrlqLZ6KobCTgtfavOqwIbWF6/ADR96fWt0LK0=;
        b=N0HZk+5nMtqrydERnhCc5sMDoZ1kba1jOzPFMY7mCX4rCEfnhGUrrOch276X8YfNv7
         QNwuNmuWg9lfEzfvHaCoV3ojuArHrAdzbxHs5QzcaLQlTbKq7MbNkl/4i09u8j5QSOrN
         PfMsPEyYJnllFWfp7WQ+n7cgQHXRx5aSGrIDNSGcbkFqLzoR48UbkVhMsUnS8Dplsn9A
         u0hhp14pIH+JQXIUSj0RTMiZ/jo/XRNjUg9u9R7rsdTQddLaxkpgueuLzAyeeMXkzFZa
         XIAJ7prhBoSBAR6PIVjo1CF1gAFhpbMioljOI+qpJvi7K4nHI/sakLQ9pk/ZlwflcD2F
         R6mg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=RAuZ8i3f;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u44sor5021447pgn.17.2019.03.06.15.54.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 06 Mar 2019 15:54:59 -0800 (PST)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=RAuZ8i3f;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=U8OzCzrlqLZ6KobCTgtfavOqwIbWF6/ADR96fWt0LK0=;
        b=RAuZ8i3f6niprk+xmlh3uwEEgufWvxEm3yZEwC8R751cjjPsRto5Iwf5LN37Blifko
         dk/q84Pcx1u49eocJRzK3ApMeBP9A/UOdhMVdTFzCCbJrdVUfGPSDvNE+yfaG9p33Df0
         CrxWaigcwgv+SWnF8zeX/UJpHTeyVSec54+8R0jQ2Yszhh+KacnPglvO+pNGrm8uhFrL
         BKVjM79G1cevGBWKArS6coS9s5YE57t9uA+WFSnJG5G3LG0Kc+kpVoVCxcOe7Rh7GIrU
         vy2+OxfF21d8lMs96cma5De3iwNDXt71E+3GwF7vJkLy0O8HjttVuwNh7uogt83VFGnF
         jECA==
X-Google-Smtp-Source: APXvYqxHyPA0yA638BndcUsu91DX/hqt48TwofG1HIqStykj82Z0dyOWsxEwb3neG9vXvR+aAuMsog==
X-Received: by 2002:a63:5fce:: with SMTP id t197mr8566506pgb.415.1551916498643;
        Wed, 06 Mar 2019 15:54:58 -0800 (PST)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id m21sm4955272pfa.14.2019.03.06.15.54.57
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Mar 2019 15:54:57 -0800 (PST)
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
Subject: [PATCH v3 0/1] mm: introduce put_user_page*(), placeholder versions
Date: Wed,  6 Mar 2019 15:54:54 -0800
Message-Id: <20190306235455.26348-1-jhubbard@nvidia.com>
X-Mailer: git-send-email 2.21.0
MIME-Version: 1.0
X-NVConfidentiality: public
Content-Type: text/plain; charset=UTF-8
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
 mm/swap.c          | 82 ++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 106 insertions(+)

-- 
2.21.0

