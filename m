Return-Path: <SRS0=SemS=S7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 04B0AC004C9
	for <linux-mm@archiver.kernel.org>; Mon, 29 Apr 2019 04:54:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B33B32087B
	for <linux-mm@archiver.kernel.org>; Mon, 29 Apr 2019 04:54:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B33B32087B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4FDE76B0003; Mon, 29 Apr 2019 00:54:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4AD8A6B0006; Mon, 29 Apr 2019 00:54:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3C2976B0007; Mon, 29 Apr 2019 00:54:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 030946B0003
	for <linux-mm@kvack.org>; Mon, 29 Apr 2019 00:54:06 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id t5so5883677pfh.21
        for <linux-mm@kvack.org>; Sun, 28 Apr 2019 21:54:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=ZGpG2GZOOdLM1S/ckpH2GJLzrVUXsS3NaIqACfli3v0=;
        b=ccKmLMhzV8sPuoIpRYziPdRvqo5pVomUnaDOa4EmVt8yMmoHoB2ChjrR4NlDET7MDG
         iPBfaWicWIEcaXavP24kfqbEtSiUO53HtPZXMsRwvNQGsxhZXjT109c4BLD2OC7Qtg/d
         n/C2AemTfpt+7eSKAY9NH0CFqSN0u0lYr/DyOzdjz8CdlvUB1mZ91SQDXU4zk0t29o3t
         dRCmjyx7PIQPWKUE3Ii7FAid8peityllnSprncJcamBJJXWHxs1PloHZPFrN4+fXy2/U
         /PHq3gUvGhdll3sAxxAYbd9o5jzXR6OXDeK6InjA7u/fYr9fQQLYh5W5HUiWoDiDDttI
         1A+Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAUyotmbk6v47u/YdtROVymYUE4w3SQU5j+mjDbVdRiYkjIlnUyE
	Hfr4XpjrFZEwp5aRYi5jP79E2813sbdQKo5GrI1/GMyQ+51FuU5P1I7ALc4Xcv5tnOIoNscnn6n
	6wQkMXjXLRzMAYlVaNsH1jd3hAHtMaO9HT/pDyAOdR7HkYSJ3QETkQk5+JQzWH229VA==
X-Received: by 2002:a62:6086:: with SMTP id u128mr62014533pfb.148.1556513645602;
        Sun, 28 Apr 2019 21:54:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqymdyLZfBsjwmI8v2g6X0E+lXN6S6dAST4Fu2BhU8S/Wdve+DT1NTeYsdhR97vNr3XZUA1v
X-Received: by 2002:a62:6086:: with SMTP id u128mr62014496pfb.148.1556513644577;
        Sun, 28 Apr 2019 21:54:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556513644; cv=none;
        d=google.com; s=arc-20160816;
        b=KmWMGvauYNQK4Dw0s75P7B20NfiMlHCeR68cDh2Ba4/ApA/e4kqy18/GrKiJCE+td8
         JIZT15zKC81hQuhLB6FcoJNoMdO7ehRmos/BFRB48ry+l596Xt/IFVUo38d4yM/EN2EO
         +/gilKyp+m9lr2y7kg997ltYTPtKpeMnJ87rDRHY1Q7z1U1EkzUxwI4A+1NJj0dHksyu
         jDIwjATsytIV5vfq1JrhaQMVSTFAskvRRsz9GXdiTO8PpTORM0ISfqd1VUP090TuQB1J
         BSqLtrsfUFVezSzYmbrgE2qAGqxNoR6k6fcnQG6LSWuCgJVfnHBYuqBdUZPGXf6XP381
         GozA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=ZGpG2GZOOdLM1S/ckpH2GJLzrVUXsS3NaIqACfli3v0=;
        b=PYT6sP7vNOQhLMtT1WJnfyrRd+4hL3rqG4fY+g2cabLcJu1/+gjKMDcgw1bxvVawsN
         +JKQd7hCxdvoe3f7pKRJOuIdEIZVxapQkdjJG7QhqcLQFLQtqWo9ndTouXVMKBWA2zw1
         8Co+IV2MoSwKLQun7FfExsylsbDms88Gv2EVk4zYFTGRj78fiYG8vUD/zAFCckDgsepG
         fXAlJq5nlyDFzr0Egwdm3YUtnWsyskahGZUjchYUMRR22AEuMGeRBIN4sunEg3FiH2N1
         Wq9+5jvoonXbeYDKSUKMHmEzmuBp4UoiF6CD0uCL09/vLkJZFeiDAoUxZWvvUZeICapF
         uVSQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id m184si14181099pfb.166.2019.04.28.21.54.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 28 Apr 2019 21:54:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.136 as permitted sender) client-ip=192.55.52.136;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga003.jf.intel.com ([10.7.209.27])
  by fmsmga106.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 28 Apr 2019 21:54:03 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,408,1549958400"; 
   d="scan'208";a="146566238"
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by orsmga003.jf.intel.com with ESMTP; 28 Apr 2019 21:54:03 -0700
From: ira.weiny@intel.com
To: lsf-pc@lists.linux-foundation.org
Cc: linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	Dan Williams <dan.j.williams@intel.com>,
	Jan Kara <jack@suse.cz>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	John Hubbard <jhubbard@nvidia.com>,
	Michal Hocko <mhocko@suse.com>,
	Ira Weiny <ira.weiny@intel.com>
Subject: [RFC PATCH 00/10] RDMA/FS DAX "LONGTERM" lease proposal
Date: Sun, 28 Apr 2019 21:53:49 -0700
Message-Id: <20190429045359.8923-1-ira.weiny@intel.com>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Ira Weiny <ira.weiny@intel.com>

In order to support RDMA to File system pages[*] without On Demand Paging a
number of things need to be done.

1) GUP "longterm"[1] users need to inform the other subsystems that they have
   taken a pin on a page which may remain pinned for a very "long time".[1]

2) Any page which is "controlled" by a file system such needs to have special
   handling.  The details of the handling depends on if the page is page cache
   backed or not.

   2a) A page cache backed page which has been pinned by GUP Longterm can use a
   bounce buffer to allow the file system to write back snap shots of the page.
   This is handled by the FS recognizing the GUP longterm pin and making a copy
   of the page to be written back.
   	NOTE: this patch set does not address this path.

   2b) A FS "controlled" page which is not page cache backed is either easier
   to deal with or harder depending on the operation the filesystem is trying
   to do.
   
	2ba) [Hard case] If the FS operation _is_ a truncate or hole punch the
	FS can no longer use the pages in question until the pin has been
	removed.  This patch set presents a solution to this by introducing
	some reasonable restrictions on user space applications.

	2bb) [Easy case] If the FS operation is _not_ a truncate or hole punch
	then there is nothing which need be done.  Data is Read or Written
	directly to the page.  This is an easy case which would currently work
	if not for GUP longterm pins being disabled.  Therefore this patch set
	need not change access to the file data but does allow for GUP pins
	after 2ba above is dealt with.


The architecture of this series is to introduce a F_LONGTERM file lease
mechanism which applications use in one of 2 ways.

1) Applications which may require hole punch or truncation operations on files
   they intend to mmmapping and pinning for long periods.  Can take a
   F_LONGTERM lease on the file.  When a file system operation needs truncate
   access to this file the lease is broken and the application gets a SIGIO.
   Upon catching SIGIO the application can un-pin (note munmap is not required)
   the memory associated with that file.  At that point the truncating user can
   proceed.  Re-pinning the memory is entirely left up to the application.  In
   some cases a new mmap will be required (as with a truncation) or a SIGBUS
   would be experienced anyway.

   Failure to respond to a SIGIO lease break within the system configured
   lease-break-time will result in a SIGBUS.

   WIP: SIGBUS could be caught and ignored...  what danger does this present...
   should this be SIGKILL  or should we wait another lease-break-time and then
   send SIGKILL?

2) Applications which don't require hold punch or truncate operations can use
   pinning without taking a F_LONGTERM lease.  However, applications such as
   this are expected to have considered the access to the files they are
   mmaping and are expected to be controlling them in a way that other users on
   a system can't truncate a file and cause a DOS on the application.  These
   applications will be sent a SIGBUS if someone attempts to truncate or hole
   punch a file.

	ALTERNATIVE WIP patch in series: If the F_LONGTERM lease is not taken
	fail the GUP.

The patches compile and have been tested to a first degree.

NOTES:
Can we deal with the lease/pin at the VFS layer?  or for all FSs?
LONGTERM seems like a bad name.  Suggestions?

[1] The definition of long time is debatable but it has been established
that RDMAs use of pages, minutes or hours after the pin is the extreme case
which makes this problem most severe.

[*] Not all file system pages are Page Cache pages.  FS DAX bypasses the page
cache.


Ira Weiny (10):
  fs/locks: Add trace_leases_conflict
  fs/locks: Introduce FL_LONGTERM file lease
  mm/gup: Pass flags down to __gup_device_huge* calls
  WIP: mm/gup: Ensure F_LONGTERM lease is held on GUP pages
  mm/gup: Take FL_LONGTERM lease if not set by user
  fs/locks: Add longterm lease traces
  fs/dax: Create function dax_mapping_is_dax()
  mm/gup: fs: Send SIGBUS on truncate of active file
  fs/locks: Add tracepoint for SIGBUS on LONGTERM expiration
  mm/gup: Remove FOLL_LONGTERM DAX exclusion

 fs/dax.c                         |  23 ++-
 fs/ext4/inode.c                  |   4 +
 fs/locks.c                       | 301 +++++++++++++++++++++++++++++--
 fs/xfs/xfs_file.c                |   4 +
 include/linux/dax.h              |   6 +
 include/linux/fs.h               |  18 ++
 include/linux/mm.h               |   2 +
 include/trace/events/filelock.h  |  74 +++++++-
 include/uapi/asm-generic/fcntl.h |   2 +
 mm/gup.c                         | 107 ++++-------
 mm/huge_memory.c                 |  18 ++
 11 files changed, 468 insertions(+), 91 deletions(-)

-- 
2.20.1

