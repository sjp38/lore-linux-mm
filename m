Return-Path: <SRS0=ikTF=QP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5D687C169C4
	for <linux-mm@archiver.kernel.org>; Fri,  8 Feb 2019 07:56:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F140C21917
	for <linux-mm@archiver.kernel.org>; Fri,  8 Feb 2019 07:56:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="T/wV6iRQ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F140C21917
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 81D558E0080; Fri,  8 Feb 2019 02:56:55 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7A50B8E0002; Fri,  8 Feb 2019 02:56:55 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 61F2F8E0080; Fri,  8 Feb 2019 02:56:55 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 199998E0002
	for <linux-mm@kvack.org>; Fri,  8 Feb 2019 02:56:55 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id t72so1932106pfi.21
        for <linux-mm@kvack.org>; Thu, 07 Feb 2019 23:56:55 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=pT1WR/BNCsrn3s1zGOcHcZxDWiKW2nJcicbtRI33DmE=;
        b=M3u8TJNyqbUNs4wyjYRQKS0fqn1LpFPauWFHajy1vewk2s5Kybx1vFf8RcVa94Ehz/
         v/PvKSBzrXichYCRl1jD55usqx9ZGPiyD1b4L2P1QicAPtbEDZHa3w+vCEX1UkqtfsBS
         rqe+ydysi3wvkCe0QSTt5XbzkFA7dVcdElDrVsdYi5UMxm44+I8LGVXHEpJicoNOGLk3
         lJzvgw0oelUOgUb6l2XD3wwspnb/xvdnym7Uc8uf2PtTNQXKhR2EenwqQ5rPLHwh5AGX
         M2J6Bbcr6d2gartx4vwriaSCkQnhEhKmCrWAcy4nrnLKCuhicXLCeKwOPjxTZsp1jKaz
         157Q==
X-Gm-Message-State: AHQUAuYy0i8+pl/PzL6OFTWZ2EI0+CFI4RM5iVz4nz8pt5u0mpPnomAp
	Qn52yd99ENw7RoitBF+ueM8Gb2HQKNIOcqPM98kdSTdR3ACE95OsnZ65bFHpPEFgyCWEztD63I5
	kDkfu/iAKzvRHNP0Pgvwph97SKvYJP42GuYbTafGCTXDuxR60BBKgVSyRFFm2k+OtYPdM9a+oPE
	iU8T3iFnNmJMqnslSJO3i9PpcAVNNswuQEGnQIdxIzY23lNac8PFavl8/DHQakco22SVGTMCv45
	mCY/aGYplwcI6pEUZ1WyOWmwxcRRr+HV1heihCZXeGC+yf3k9sOGzaWXGfN3puqXOsGpLuAZiNc
	DrVIkDkBK9omBsKEbTw8eivanDACntdM+WlqE8HFjUETGwOAoPTAhhW05jODcLvFm757FzRxZwv
	V
X-Received: by 2002:a17:902:f20a:: with SMTP id gn10mr5589308plb.105.1549612614631;
        Thu, 07 Feb 2019 23:56:54 -0800 (PST)
X-Received: by 2002:a17:902:f20a:: with SMTP id gn10mr5589239plb.105.1549612613430;
        Thu, 07 Feb 2019 23:56:53 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549612613; cv=none;
        d=google.com; s=arc-20160816;
        b=hH6NMr5do5/jO5r6EWUESRqqqEFNCzHR2uLGj7XpwCL0HJWSMQLo4RoCQphvZEdEmg
         9HlMZjQ1hw6peAn9OEO8KNs/IYOKviG488OCeH0DCBEOhyMALWHJCGQlEUXW+z9S4K3A
         9JmNsyh95JPKSDsrd6MtWxx50qZe8JodU+w7Z6KUb25IchBThdZB9meUu+F+H/DGmy/L
         w5DAlsXgo4CuIrUiZQstpzoaV5+ZvEWj1UfGCRt6hnA3aFijO3RLDgUgejikUiBASNRn
         84efgxwP7kZYHEFbCcog81wG9lWPWiZV5ZQAR3//zlWpzYow1vW44Gqk7tlueFJv9LqX
         4FiQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=pT1WR/BNCsrn3s1zGOcHcZxDWiKW2nJcicbtRI33DmE=;
        b=mxsg2D3Cj7uG/WYpNcKy8m/vFkFfv3fSZSrJ+mYlno2tJd08mqIW+I5mHO9DeHnMoc
         LJmEkz56BL/NTRlPMKI2DydP+20Tzadz15TeTr2DClegh083yNAgXkpk4MeMsub2h9n7
         vi8UcDv6kuaE1Xlw4xJhlg5fXZr1RuQv5MKn2MHBhNoPMiPCBT4JjlYAsu3F1BQmIYHm
         Wy4wDVAEd5JL5a8fU9N8tMwM8bi4wu1f93k3EXZO0nDg/pLPywnOpcjwhRUiC6mxwwwq
         t3Iazff1l+JxlrbHb0E3B0TJbsexBDBMUNt3cHMsabn8sJC5U2w9aI37r6DeiJMcZKfP
         8Csg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="T/wV6iRQ";
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 24sor1662460pgq.13.2019.02.07.23.56.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 07 Feb 2019 23:56:53 -0800 (PST)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="T/wV6iRQ";
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=pT1WR/BNCsrn3s1zGOcHcZxDWiKW2nJcicbtRI33DmE=;
        b=T/wV6iRQr7x7NIcIDG0RCKUaxAf2cgP0IrBpw4EJvYfPGjQ/z4v70BwgC6cZqt2Vsm
         PTMZ3iNCtuqPOv97h0qSrBTe6dPczibIOtGH3aH9J+LFt0796K+5BY3MIwxqiClXUrtG
         zfEZ8UpZoj0GK53dVXEPVSCj3t80zjVu96b78fkI5/5zMzcg+g0f96nSe8F4Qr7v9m0c
         PfYcLgUT7HU2NsCbdySHhXlNgpONEbnKWD1M6Vx+WcEJDSePG/ra/5ZIqfeRgYJ+gF/d
         5WpZwicQgyAhIzy+hBSKR2UozlhLwkumeLjYKCu9ghA9xUcB7rM9vfP74a8tR8iRbKeK
         K7xQ==
X-Google-Smtp-Source: AHgI3IZz4fuyZl6IUy2+nVC8BROChMdiWSpD48h7UNHTUAFkBcmyi1gcJkeIVce5Yg1cAekMTPJpgw==
X-Received: by 2002:a63:ce0e:: with SMTP id y14mr19350314pgf.145.1549612612922;
        Thu, 07 Feb 2019 23:56:52 -0800 (PST)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id h64sm2642610pfc.142.2019.02.07.23.56.50
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Feb 2019 23:56:52 -0800 (PST)
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
Subject: [PATCH 0/2] mm: put_user_page() call site conversion first
Date: Thu,  7 Feb 2019 23:56:47 -0800
Message-Id: <20190208075649.3025-1-jhubbard@nvidia.com>
X-Mailer: git-send-email 2.20.1
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

Hi,

It seems about time to post these initial patches: I think we have pretty
good consensus on the concept and details of the put_user_pages() approach.
Therefore, here are the first two patches, to get started on converting the
get_user_pages() call sites to use put_user_page(), instead of put_page().
This is in order to implement tracking of get_user_page() pages.

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

This write up is lifted from the RFC v2 patchset cover letter [1]:

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


[1] https://lkml.kernel.org/r/20190204052135.25784-1-jhubbard@nvidia.com

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

John Hubbard (2):
  mm: introduce put_user_page*(), placeholder versions
  infiniband/mm: convert put_page() to put_user_page*()

 drivers/infiniband/core/umem.c              |  7 +-
 drivers/infiniband/core/umem_odp.c          |  2 +-
 drivers/infiniband/hw/hfi1/user_pages.c     | 11 +--
 drivers/infiniband/hw/mthca/mthca_memfree.c |  6 +-
 drivers/infiniband/hw/qib/qib_user_pages.c  | 11 +--
 drivers/infiniband/hw/qib/qib_user_sdma.c   |  6 +-
 drivers/infiniband/hw/usnic/usnic_uiom.c    |  7 +-
 include/linux/mm.h                          | 24 ++++++
 mm/swap.c                                   | 82 +++++++++++++++++++++
 9 files changed, 129 insertions(+), 27 deletions(-)

-- 
2.20.1

