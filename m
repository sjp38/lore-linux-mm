Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 60F99C433FF
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 22:58:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E1E9F208C4
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 22:58:43 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E1E9F208C4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 23CF66B0005; Fri,  9 Aug 2019 18:58:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1EDFA6B0006; Fri,  9 Aug 2019 18:58:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0DCCA6B0007; Fri,  9 Aug 2019 18:58:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id C95FB6B0005
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 18:58:42 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id x19so60559617pgx.1
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 15:58:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=jTRo8QfgTd8PLIQ++dzDDZgWSba3TS2gw86o3ePFfEw=;
        b=tJKrR162FW8lu37Ug8u8htxLq99Yyp85rPFHssYc/aKQjOmCffKFWGIcSVWarTlgJv
         kZbDjnMkUduXtEfYrySLJqYNmsWf6mg/v/uz4YXyMxyYSWeDpX053nP8H53HCmzKo4ES
         TrI4eXEL/16/xPC6/ejYHwyvuIxMcvQuQzSk2cv9DnUvrmZHpRgKEA2hBC8dBIbUT6St
         7mkG/sdgnJlCuy074r4V7k02j7UivzOKE75pWU/8djgEo6TyVFNnXhRR051qtk9DCMQ2
         SKt9RyKQi5k9+z9tcHag/ChiWDQTG8ceIAhphGzJhA0N+9gayeRIfk9xzJm/sCJqy181
         xFIQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAWFWPJtGcIy45l8z88t5Oy7OydP3d6vpLlRDA6lS8NHySUA8XLD
	24uqYGWx3+oAMpGWP5zKU/TCXhE+6vHtY4sqrv9iDXu0wrd8pJbm0PkWoKiJPnomUhhGZsLdYKj
	cIFd66oBzpRGEFFOGMudymQd0agxBTF8KygKeEAiS1GJog/dk27VfaOO2ctrkLFabNw==
X-Received: by 2002:a63:7d05:: with SMTP id y5mr19800789pgc.425.1565391522345;
        Fri, 09 Aug 2019 15:58:42 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwb6e2pK74+ScH/83iY47IqwzqQKqIBQFqPjZmo9WfSfe8RpWWmwsb/Na8cwdrBCdhjUZcQ
X-Received: by 2002:a63:7d05:: with SMTP id y5mr19800725pgc.425.1565391521077;
        Fri, 09 Aug 2019 15:58:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565391521; cv=none;
        d=google.com; s=arc-20160816;
        b=dMB6odUB3/bepzgdv8SESQlAFymGOnhhosYeHDalJ7A+W6ahEaJooQXxF38QdE9D8B
         O+LPxERgisyA6ZJU8f/7t3L6Wnkphs/k1/GXQ0z/l5u6zhf5LJnKjggd+Nbx6eLoPkq/
         m7IvEFmfBdYy09GDgt/8zb5H3q176VuDwhPwXxn/qyZDR9+a/4ne5ppjc8GzORd+5xst
         W9DWquwl5DLNRyllHHh2eYvyImIbyToQ09INjHnuyfaqmrAMnFq0Pdmg+jfEYJChE9lX
         SX5XgVaw+JYfiN4pBjl+/hd0fwbF9m+4g+61F2u+svihYmA9B7W2S9QCSmml10hqDiZD
         wAAg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=jTRo8QfgTd8PLIQ++dzDDZgWSba3TS2gw86o3ePFfEw=;
        b=lH7XMPcpKU7mreYKdrrgeEWpnQUB1iD46dtaWwlm4MdqeFVnN/OLJko0RNWyjTMaBu
         W5YDnOilwWZyWsLeDTLgknVIzfwzwMaqVw77NdrrCGgkDTIA43G9namYk3Qlb3R2bj1C
         IQQtcY8TPx2YqOMLU02N/XtOe41wHhZdZCaad38KaaOkGLqtfcAI1arOICl9R7Px1ZUh
         FdoohkwHUHbh2K/FUmg8g8gdDUxUqEThBbZdNRgehpd50Gskx5YwCzFPNDhA3Ly6yppN
         jCTUHb8OiCYGDg9OA7f1dfqyc0y6aB9qhUhq1bcKVtrrdLYk26dM8GR13lAyU7fbKQ/x
         wPJQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id k22si25962862pfi.289.2019.08.09.15.58.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Aug 2019 15:58:41 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.120 as permitted sender) client-ip=192.55.52.120;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga006.fm.intel.com ([10.253.24.20])
  by fmsmga104.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 09 Aug 2019 15:58:40 -0700
X-IronPort-AV: E=Sophos;i="5.64,367,1559545200"; 
   d="scan'208";a="375343471"
Received: from iweiny-desk2.sc.intel.com (HELO localhost) ([10.3.52.157])
  by fmsmga006-auth.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 09 Aug 2019 15:58:39 -0700
From: ira.weiny@intel.com
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jason Gunthorpe <jgg@ziepe.ca>,
	Dan Williams <dan.j.williams@intel.com>,
	Matthew Wilcox <willy@infradead.org>,
	Jan Kara <jack@suse.cz>,
	"Theodore Ts'o" <tytso@mit.edu>,
	John Hubbard <jhubbard@nvidia.com>,
	Michal Hocko <mhocko@suse.com>,
	Dave Chinner <david@fromorbit.com>,
	linux-xfs@vger.kernel.org,
	linux-rdma@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	linux-fsdevel@vger.kernel.org,
	linux-nvdimm@lists.01.org,
	linux-ext4@vger.kernel.org,
	linux-mm@kvack.org,
	Ira Weiny <ira.weiny@intel.com>
Subject: [RFC PATCH v2 00/19] RDMA/FS DAX truncate proposal V1,000,002   ;-)
Date: Fri,  9 Aug 2019 15:58:14 -0700
Message-Id: <20190809225833.6657-1-ira.weiny@intel.com>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Ira Weiny <ira.weiny@intel.com>

Pre-requisites
==============
	Based on mmotm tree.

Based on the feedback from LSFmm, the LWN article, the RFC series since
then, and a ton of scenarios I've worked in my mind and/or tested...[1]

Solution summary
================

The real issue is that there is no use case for a user to have RDMA pinn'ed
memory which is then truncated.  So really any solution we present which:

A) Prevents file system corruption or data leaks
...and...
B) Informs the user that they did something wrong

Should be an acceptable solution.

Because this is slightly new behavior.  And because this is going to be
specific to DAX (because of the lack of a page cache) we have made the user
"opt in" to this behavior.

The following patches implement the following solution.

0) Registrations to Device DAX char devs are not affected

1) The user has to opt in to allowing page pins on a file with an exclusive
   layout lease.  Both exclusive and layout lease flags are user visible now.

2) page pins will fail if the lease is not active when the file back page is
   encountered.

3) Any truncate or hole punch operation on a pinned DAX page will fail.

4) The user has the option of holding the lease or releasing it.  If they
   release it no other pin calls will work on the file.

5) Closing the file is ok.

6) Unmapping the file is ok

7) Pins against the files are tracked back to an owning file or an owning mm
   depending on the internal subsystem needs.  With RDMA there is an owning
   file which is related to the pined file.

8) Only RDMA is currently supported

9) Truncation of pages which are not actively pinned nor covered by a lease
   will succeed.


Reporting of pinned files in procfs
===================================

A number of alternatives were explored for how to report the file pins within
procfs.  The following incorporates ideas from Jan Kara, Jason Gunthorpe, Dave
Chinner, Dan Williams and myself.

A new entry is added to procfs

/proc/<pid>/file_pins

For processes which have pinned DAX file memory file_pins reference come in 2
flavors.  Those which are attached to another open file descriptor (For example
what is done in the RDMA subsytem) and those which are attached to a process
mm.

For those which are attached to another open file descriptor (such as RDMA)
the file pin references go through the 'struct file' associated with that pin.
In RDMA this is the RDMA context struct file.

The resulting output from proc fs is something like.

$ cat /proc/<pid>/file_pins
3: /dev/infiniband/uverbs0
	/mnt/pmem/foo

Where '3' is the file descriptor (and file path) of the rdma context within the
process.  The paths of the files pinned using that context are then listed.

RDMA contexts may have multiple MR each of which may have multiple files pinned
within them.  So an output like the following is possible.

$ cat /proc/<pid>/file_pins
4: /dev/infiniband/uverbs0
	/mnt/pmem/foo
	/mnt/pmem/bar
	/mnt/pmem/another
	/mnt/pmem/one

The actual memory regions associated with the file pins are not reported.

For processes which are pinning memory which is not associated with a specific
file descriptor memory pins are reported directly as paths to the file.

$ cat /proc/<pid>/file_pins
/mnt/pmem/foo

Putting the above together if a process was using RDMA and another subsystem
the output could be something like:


$ cat /proc/<pid>/file_pins
4: /dev/infiniband/uverbs0
	/mnt/pmem/foo
	/mnt/pmem/bar
	/mnt/pmem/another
	/mnt/pmem/one
/mnt/pmem/foo
/mnt/pmem/another
/mnt/pmem/mm_mapped_file


[1] https://lkml.org/lkml/2019/6/5/1046


Background
==========

It should be noted that one solution for this problem is to use RDMA's On
Demand Paging (ODP).  There are 2 big reasons this may not work.

	1) The hardware being used for RDMA may not support ODP
	2) ODP may be detrimental to the over all network (cluster or cloud)
	   performance

Therefore, in order to support RDMA to File system pages without On Demand
Paging (ODP) a number of things need to be done.

1) "longterm" GUP users need to inform other subsystems that they have taken a
   pin on a page which may remain pinned for a very "long time".  The
   definition of long time is debatable but it has been established that RDMAs
   use of pages for, minutes, hours, or even days after the pin is the extreme
   case which makes this problem most severe.

2) Any page which is "controlled" by a file system needs to have special
   handling.  The details of the handling depends on if the page is page cache
   fronted or not.

   2a) A page cache fronted page which has been pinned by GUP long term can use a
   bounce buffer to allow the file system to write back snap shots of the page.
   This is handled by the FS recognizing the GUP long term pin and making a copy
   of the page to be written back.
	NOTE: this patch set does not address this path.

   2b) A FS "controlled" page which is not page cache fronted is either easier
   to deal with or harder depending on the operation the filesystem is trying
   to do.

	2ba) [Hard case] If the FS operation _is_ a truncate or hole punch the
	FS can no longer use the pages in question until the pin has been
	removed.  This patch set presents a solution to this by introducing
	some reasonable restrictions on user space applications.

	2bb) [Easy case] If the FS operation is _not_ a truncate or hole punch
	then there is nothing which need be done.  Data is Read or Written
	directly to the page.  This is an easy case which would currently work
	if not for GUP long term pins being disabled.  Therefore this patch set
	need not change access to the file data but does allow for GUP pins
	after 2ba above is dealt with.


This patch series and presents a solution for problem 2ba)

Ira Weiny (19):
  fs/locks: Export F_LAYOUT lease to user space
  fs/locks: Add Exclusive flag to user Layout lease
  mm/gup: Pass flags down to __gup_device_huge* calls
  mm/gup: Ensure F_LAYOUT lease is held prior to GUP'ing pages
  fs/ext4: Teach ext4 to break layout leases
  fs/ext4: Teach dax_layout_busy_page() to operate on a sub-range
  fs/xfs: Teach xfs to use new dax_layout_busy_page()
  fs/xfs: Fail truncate if page lease can't be broken
  mm/gup: Introduce vaddr_pin structure
  mm/gup: Pass a NULL vaddr_pin through GUP fast
  mm/gup: Pass follow_page_context further down the call stack
  mm/gup: Prep put_user_pages() to take an vaddr_pin struct
  {mm,file}: Add file_pins objects
  fs/locks: Associate file pins while performing GUP
  mm/gup: Introduce vaddr_pin_pages()
  RDMA/uverbs: Add back pointer to system file object
  RDMA/umem: Convert to vaddr_[pin|unpin]* operations.
  {mm,procfs}: Add display file_pins proc
  mm/gup: Remove FOLL_LONGTERM DAX exclusion

 drivers/infiniband/core/umem.c        |  26 +-
 drivers/infiniband/core/umem_odp.c    |  16 +-
 drivers/infiniband/core/uverbs.h      |   1 +
 drivers/infiniband/core/uverbs_main.c |   1 +
 fs/Kconfig                            |   1 +
 fs/dax.c                              |  38 ++-
 fs/ext4/ext4.h                        |   2 +-
 fs/ext4/extents.c                     |   6 +-
 fs/ext4/inode.c                       |  26 +-
 fs/file_table.c                       |   4 +
 fs/locks.c                            | 291 +++++++++++++++++-
 fs/proc/base.c                        | 214 +++++++++++++
 fs/xfs/xfs_file.c                     |  21 +-
 fs/xfs/xfs_inode.h                    |   5 +-
 fs/xfs/xfs_ioctl.c                    |  15 +-
 fs/xfs/xfs_iops.c                     |  14 +-
 include/linux/dax.h                   |  12 +-
 include/linux/file.h                  |  49 +++
 include/linux/fs.h                    |   5 +-
 include/linux/huge_mm.h               |  17 --
 include/linux/mm.h                    |  69 +++--
 include/linux/mm_types.h              |   2 +
 include/rdma/ib_umem.h                |   2 +-
 include/uapi/asm-generic/fcntl.h      |   5 +
 kernel/fork.c                         |   3 +
 mm/gup.c                              | 418 ++++++++++++++++----------
 mm/huge_memory.c                      |  18 +-
 mm/internal.h                         |  28 ++
 28 files changed, 1048 insertions(+), 261 deletions(-)

-- 
2.20.1

