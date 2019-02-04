Return-Path: <SRS0=bR/Z=QL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DB5DBC282D7
	for <linux-mm@archiver.kernel.org>; Mon,  4 Feb 2019 05:22:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 82A6921773
	for <linux-mm@archiver.kernel.org>; Mon,  4 Feb 2019 05:22:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="fcAAdWDc"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 82A6921773
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 304A98E0037; Mon,  4 Feb 2019 00:21:52 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 28F348E001C; Mon,  4 Feb 2019 00:21:52 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 10B938E0037; Mon,  4 Feb 2019 00:21:52 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id B55758E001C
	for <linux-mm@kvack.org>; Mon,  4 Feb 2019 00:21:51 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id x14so2986206pln.5
        for <linux-mm@kvack.org>; Sun, 03 Feb 2019 21:21:51 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=+NGzTTJYka4kEPYhIjO26w8qWqAMcgcRWgdS5H6mxCk=;
        b=Gl8YIt59nC3abDtMORTYjaybWqWTwade3cQXJPGmRAwsN8glM2xjDP/qhGT5VGh/d7
         cbc1/PeStvtFQ2tlMLbJg5g+l1Fwts2R3vRtPfXYDB2+wG/nizwdKddtSB5f6o/SrMjM
         ++LyV9VbBEb0dgBUPbUf4FdwY1IRCBzKBG1h5Qhxbkt4m4nj43Z4ZB3YRN8wlwIRDOuy
         tYKjhBllJlLdn5eNDSUwSMK68luqWarIV4CY9hsG70Sqb2GgjYAVdyT3oMwneSjoIODU
         +HvXMb3olvjWF4vZF0ehyg5DRvifKYDQgYPMc/3gRagag92nraPddILIGKYADw4C2jQW
         rU9w==
X-Gm-Message-State: AJcUukdf0i5DRxQw1sF/TYBVSfwdDu/4b/+Ze7rJdAzsYH7BWnk/QS8f
	9gBYm4/53VZARnQJtTcbWnkg4qbHmPe6LGp4oj7QM+RZD1+TS/eCr3o/D6UAjEnKtd0mLfXXPM3
	g13+SPojzEIRTXq0L9QXfXleCB7y58oEKi1hWp+pMTPJQOUumcn8YLP2LxNMfpEzqsc2L8XwkVP
	IhqpcW2zxKO3MaiLztxZcS3h0KvtyvpT/SN+P9rLz53NmIbZ5aCae5BHkUXJasCWrRs8M3Z9m0/
	gKtsa7pujEm7KL+wGk4r37UDuOftomyt1f/VeFFzzxdLCpH3LIZ8n4f39JqZGarNkuxBGAWB8pk
	oAPO7cqODYX9r5IxPulowECdNccs/A+WeizlEXU+VJv7DxOH06gH8E1HDQqY8JoX+88n/urtgUI
	g
X-Received: by 2002:a62:39cb:: with SMTP id u72mr49567457pfj.223.1549257711356;
        Sun, 03 Feb 2019 21:21:51 -0800 (PST)
X-Received: by 2002:a62:39cb:: with SMTP id u72mr49567403pfj.223.1549257710124;
        Sun, 03 Feb 2019 21:21:50 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549257710; cv=none;
        d=google.com; s=arc-20160816;
        b=Tqw+eRI06dnQHdhZvqEotUbnw/BNnLsD8d3poY/VRF8M5e6BYDHVFBdrKHHNHw+Bf4
         /uc+65vMLPgqLOD83r2lPVTzAuaSnjBlYocGwPv2NmFwkO0jeE6v6+LZHVeWTlRVghRE
         zvY56WpuBeud4j/ATXMetCJCEc2fpjVwTw4Oks3XAG11AkXNAVkcNBVjTslh+KE6b4n3
         OQDcLOsVXf57qwPThq/lcyZvBAWxQAWA8++zzYea4lK6T6MGYhyfAr0n7J3VO98f3Gyz
         JJJyCIX6aQ8Z4mtyNOp1r8JKShpm7Vj6V8F/m9nHVAUfdpGoaGPGG5TwODePE4KeygOS
         kM7w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=+NGzTTJYka4kEPYhIjO26w8qWqAMcgcRWgdS5H6mxCk=;
        b=Lv3yAXZmGiEr7XvWd+TkKJfydKS9wgx2Fe1iIHCXE+dfjSnDRHmhJK+AVkLcVvHKyq
         FYJSsrvC/KYOqOx0sNQZtz8x5vZ6pooeMfMed10crT+n9YiwufMzqBfQr7wxNDZ1+DcW
         UF+IrWV33Zu9YoxBy66visoxcnhOp++lGn/e5Nr+k8cQTEQdUvKUmU2jgamsKAF/+Cid
         tF0bjMfU3rtUp7ox+wGTnqC6JHwLHNrPU+MqrEbmD8WLX9WkgkjInA9wxV51hDIFXcxZ
         Oc3+duHzW1CVVdiugTDN7P/jv2bdN4lXqUvyBxJ5YiOmWipvUTc52SnjCKrV97Dgy7PD
         ebnA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=fcAAdWDc;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g16sor24059475plo.1.2019.02.03.21.21.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 03 Feb 2019 21:21:50 -0800 (PST)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=fcAAdWDc;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=+NGzTTJYka4kEPYhIjO26w8qWqAMcgcRWgdS5H6mxCk=;
        b=fcAAdWDcvho+hxPsmITn/Nb/O2jFmC5G9jBshXx/d4cmPZpXX8zVU6RBWKB/FUQiEv
         Ly52aF3VgHyCzKz8tQN5kKT7vCrK8BhXOueH3iwxQytzrWLCeywVWIf4H+WM6HIqIf2r
         e0B8KAwTxJtqz0QV6daWE/dqoD6r4xeEMEg+KtcS/IUWnkgImgtz5zVZVxdYa3pbHCS0
         fWPbhjoA1NMEZNO4O1oCsLvp9DrjwjmUUhqN9T56ii1ImI5q0DAPGJErKMzVQQjb6WcG
         Tvbi+Of+/pEhJhj5iXbGHfDxjnfT96xQC+oJyO6NRqlA4L4tZsYRPmB5avEh9JcGXFs9
         c4Ag==
X-Google-Smtp-Source: AHgI3IZDrRMmcnIrdv5spY2BD9+EltnV+6cGIH9w4YsUW5ZGKfbTzAkcx/Xx7fnrBITQ2+J5R2mYmg==
X-Received: by 2002:a17:902:6949:: with SMTP id k9mr7253249plt.85.1549257709692;
        Sun, 03 Feb 2019 21:21:49 -0800 (PST)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id m9sm33428844pgd.32.2019.02.03.21.21.47
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 03 Feb 2019 21:21:48 -0800 (PST)
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
Subject: [PATCH 6/6] mm/gup: Documentation/vm/get_user_pages.rst, MAINTAINERS
Date: Sun,  3 Feb 2019 21:21:35 -0800
Message-Id: <20190204052135.25784-7-jhubbard@nvidia.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190204052135.25784-1-jhubbard@nvidia.com>
References: <20190204052135.25784-1-jhubbard@nvidia.com>
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

1. Added Documentation/vm/get_user_pages.rst

2. Added a GET_USER_PAGES entry in MAINTAINERS

Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Jan Kara <jack@suse.cz>
Signed-off-by: Jérôme Glisse <jglisse@redhat.com>
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
---
 Documentation/vm/get_user_pages.rst | 197 ++++++++++++++++++++++++++++
 Documentation/vm/index.rst          |   1 +
 MAINTAINERS                         |  10 ++
 3 files changed, 208 insertions(+)
 create mode 100644 Documentation/vm/get_user_pages.rst

diff --git a/Documentation/vm/get_user_pages.rst b/Documentation/vm/get_user_pages.rst
new file mode 100644
index 000000000000..8598f20afb09
--- /dev/null
+++ b/Documentation/vm/get_user_pages.rst
@@ -0,0 +1,197 @@
+.. _get_user_pages:
+
+==============
+get_user_pages
+==============
+
+.. contents:: :local:
+
+Overview
+========
+
+Some kernel components (file systems, device drivers) need to access
+memory that is specified via process virtual address. For a long time, the
+API to achieve that was get_user_pages ("GUP") and its variations. However,
+GUP has critical limitations that have been overlooked; in particular, GUP
+does not interact correctly with filesystems in all situations. That means
+that file-backed memory + GUP is a recipe for potential problems, some of
+which have already occurred in the field.
+
+GUP was first introduced for Direct IO (O_DIRECT), allowing filesystem code
+to get the struct page behind a virtual address and to let storage hardware
+perform a direct copy to or from that page. This is a short-lived access
+pattern, and as such, the window for a concurrent writeback of GUP'd page
+was small enough that there were not (we think) any reported problems.
+Also, userspace was expected to understand and accept that Direct IO was
+not synchronized with memory-mapped access to that data, nor with any
+process address space changes such as munmap(), mremap(), etc.
+
+Over the years, more GUP uses have appeared (virtualization, device
+drivers, RDMA) that can keep the pages they get via GUP for a long period
+of time (seconds, minutes, hours, days, ...). This long-term pinning makes
+an underlying design problem more obvious.
+
+In fact, there are a number of key problems inherent to GUP:
+
+Interactions with file systems
+==============================
+
+File systems expect to be able to write back data, both to reclaim pages,
+and for data integrity. Allowing other hardware (NICs, GPUs, etc) to gain
+write access to the file memory pages means that such hardware can dirty the
+pages, without the filesystem being aware. This can, in some cases
+(depending on filesystem, filesystem options, block device, block device
+options, and other variables), lead to data corruption, and also to kernel
+bugs of the form:
+
+::
+
+    kernel BUG at /build/linux-fQ94TU/linux-4.4.0/fs/ext4/inode.c:1899!
+    backtrace:
+
+	ext4_writepage
+	__writepage
+	write_cache_pages
+	ext4_writepages
+	do_writepages
+	__writeback_single_inode
+	writeback_sb_inodes
+	__writeback_inodes_wb
+	wb_writeback
+	wb_workfn
+	process_one_work
+	worker_thread
+	kthread
+	ret_from_fork
+
+...which is due to the file system asserting that there are still buffer
+heads attached:
+
+::
+
+ /* If we *know* page->private refers to buffer_heads */
+ #define page_buffers(page)                                      \
+        ({                                                      \
+                BUG_ON(!PagePrivate(page));                     \
+                ((struct buffer_head *)page_private(page));     \
+        })
+ #define page_has_buffers(page)  PagePrivate(page)
+
+Dave Chinner's description of this is very clear:
+
+    "The fundamental issue is that ->page_mkwrite must be called on every
+    write access to a clean file backed page, not just the first one.
+    How long the GUP reference lasts is irrelevant, if the page is clean
+    and you need to dirty it, you must call ->page_mkwrite before it is
+    marked writeable and dirtied. Every. Time."
+
+This is just one symptom of the larger design problem: filesystems do not
+actually support get_user_pages() being called on their pages, and letting
+hardware write directly to those pages--even though that pattern has been
+going on since about 2005 or so.
+
+Long term GUP
+=============
+
+Long term GUP is an issue when FOLL_WRITE is specified to GUP (so, a
+writeable mapping is created), and the pages are file-backed. That can lead
+to filesystem corruption. What happens is that when a file-backed page is
+being written back, it is first mapped read-only in all of the CPU page
+tables; the file system then assumes that nobody can write to the page, and
+that the page content is therefore stable. Unfortunately, the GUP callers
+generally do not monitor changes to the CPU pages tables; they instead
+assume that the following pattern is safe (it's not):
+
+::
+
+    get_user_pages()
+
+    Hardware then keeps a reference to those pages for some potentially
+    long time. During this time, hardware may write to the pages. Because
+    "hardware" here means "devices that are not a CPU", this activity
+    occurs without any interaction with the kernel's file system code.
+
+    for each page:
+	set_page_dirty()
+	put_page()
+
+In fact, the GUP documentation even recommends that pattern.
+
+Anyway, the file system assumes that the page is stable (nothing is writing
+to the page), and that is a problem: stable page content is necessary for
+many filesystem actions during writeback, such as checksum, encryption,
+RAID striping, etc. Furthermore, filesystem features like COW (copy on
+write) or snapshot also rely on being able to use a new page for as memory
+for that memory range inside the file.
+
+Corruption during write back is clearly possible here. To solve that, one
+idea is to identify pages that have active GUP, so that we can use a bounce
+page to write stable data to the filesystem. The filesystem would work
+on the bounce page, while any of the active GUP might write to the
+original page. This would avoid the stable page violation problem, but note
+that it is only part of the overall solution, because other problems
+remain.
+
+Other filesystem features that need to replace the page with a new one can
+be inhibited for pages that are GUP-pinned. This will, however, alter and
+limit some of those filesystem features. The only fix for that would be to
+require GUP users monitor and respond to CPU page table updates. Subsystems
+such as ODP and HMM do this, for example. This aspect of the problem is
+still under discussion.
+
+Direct IO
+=========
+
+Direct IO can cause corruption, if userspace does Direct-IO that writes to
+a range of virtual addresses that are mmap'd to a file.  The pages written
+to are file-backed pages that can be under write back, while the Direct IO
+is taking place.  Here, Direct IO need races with a write back: it calls
+GUP before page_mkclean() has replaced the CPU pte with a read-only entry.
+The race window is pretty small, which is probably why years have gone by
+before we noticed this problem: Direct IO is generally very quick, and
+tends to finish up before the filesystem gets around to do anything with
+the page contents.  However, it's still a real problem.  The solution is
+to never let GUP return pages that are under write back, but instead,
+force GUP to take a write fault on those pages.  That way, GUP will
+properly synchronize with the active write back.  This does not change the
+required GUP behavior, it just avoids that race.
+
+Measurement and visibility
+==========================
+
+There are several /proc/vmstat items, in order to provide some visibility
+into what get_user_pages() and put_user_page() are doing.
+
+After booting and running fio (https://github.com/axboe/fio)
+a few times on an NVMe device, as a way to get lots of
+get_user_pages_fast() calls, the counters look like this:
+
+::
+
+ $ cat /proc/vmstat | grep gup
+ nr_gup_slow_pages_requested 21319
+ nr_gup_fast_pages_requested 11533792
+ nr_gup_fast_page_backoffs 0
+ nr_gup_page_count_overflows 0
+ nr_gup_pages_returned 11555104
+
+Interpretation of the above:
+
+::
+
+ Total gup requests (slow + fast): 11555111
+ Total put_user_page calls:        11555104
+
+This shows 7 more calls to get_user_pages(), than to put_user_page().
+That may, or may not, represent a problem worth investigating.
+
+Normally, those last two numbers should be equal, but a couple of things
+may cause them to differ:
+
+1. Inherent race condition in reading /proc/vmstat values.
+
+2. Bugs at any of the get_user_pages*() call sites. Those
+sites need to match get_user_pages() and put_user_page() calls.
+
+
+
diff --git a/Documentation/vm/index.rst b/Documentation/vm/index.rst
index 2b3ab3a1ccf3..433aaf1996e6 100644
--- a/Documentation/vm/index.rst
+++ b/Documentation/vm/index.rst
@@ -32,6 +32,7 @@ descriptions of data structures and algorithms.
    balance
    cleancache
    frontswap
+   get_user_pages
    highmem
    hmm
    hwpoison
diff --git a/MAINTAINERS b/MAINTAINERS
index 8c68de3cfd80..1e8f91b8ce4f 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -6384,6 +6384,16 @@ M:	Frank Haverkamp <haver@linux.ibm.com>
 S:	Supported
 F:	drivers/misc/genwqe/
 
+GET_USER_PAGES
+M:	Dan Williams <dan.j.williams@intel.com>
+M:	Jan Kara <jack@suse.cz>
+M:	Jérôme Glisse <jglisse@redhat.com>
+M:	John Hubbard <jhubbard@nvidia.com>
+L:	linux-mm@kvack.org
+S:	Maintained
+F:	mm/gup.c
+F:	Documentation/vm/get_user_pages.rst
+
 GET_MAINTAINER SCRIPT
 M:	Joe Perches <joe@perches.com>
 S:	Maintained
-- 
2.20.1

