Return-Path: <SRS0=NBIx=RK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.4 required=3.0 tests=DATE_IN_PAST_06_12,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DF776C10F03
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 16:38:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8DAFE2085A
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 16:38:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8DAFE2085A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 132148E0006; Thu,  7 Mar 2019 11:38:56 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0E42E8E0002; Thu,  7 Mar 2019 11:38:56 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F0A6C8E0006; Thu,  7 Mar 2019 11:38:55 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id AD8CF8E0002
	for <linux-mm@kvack.org>; Thu,  7 Mar 2019 11:38:55 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id 134so18391102pfx.21
        for <linux-mm@kvack.org>; Thu, 07 Mar 2019 08:38:55 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=ewlumg6CCGkfxUO72Yi4z9djh6d1wc1yinxVVUQlnPg=;
        b=n43cORIMdklPuC7VByMeHPoS5u7StqNHtIDgKfaOjNcyjNfLzVQW4gluJHv+/40axH
         6WwOxVi8PbMd5+b7TJvkH+bjF8NoAq9Y8Fcc/PmKBWP72bCFCmx53bgZUfV1V2tGsOmb
         dRnZ09Cu+mcVOWE1+G9DuG+ND6sDNx7crIZRam/3HrBW5UvR3VMdFNANXB8tPjjGHWI2
         uQSKHO5a9durED18FG/H07DY7TaapgJw6uzpMPGHKWiKkBOF4VejVvcu+C3guVW59fX+
         w3iUEbrkYdX5PNVXWu1L27tLJtaHg3neL7MEjE94foTXRnfQ55ON0gBNBYmJeYav7+pN
         JnCg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAWs/2kgIrGlHhzP3Qd8Xz/UMGJ1LFhY15ShbeLcZgQVKsaSA2j8
	GI9RqDdhBzlSXlxPsMDUKzFFlMJJseVWx1PIDxf3fOFjD8GxQ41FhnxCUHl3RbMHzVvYS2rubXX
	lZheFBb6IxpOflt/jLZ+Z3Yyp6oYMynWhz9acyhmXOdPHKXvP3RnfPThkGLn6NQAsNg==
X-Received: by 2002:a62:53c7:: with SMTP id h190mr13968553pfb.204.1551976735334;
        Thu, 07 Mar 2019 08:38:55 -0800 (PST)
X-Google-Smtp-Source: APXvYqzFjNNxzMqAQw0fmvXevxCmCG3rzi8JeW7KohZwicDA/A7Uh7FA/kFVxKyKkLR1dq5PT9K9
X-Received: by 2002:a62:53c7:: with SMTP id h190mr13968462pfb.204.1551976733840;
        Thu, 07 Mar 2019 08:38:53 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551976733; cv=none;
        d=google.com; s=arc-20160816;
        b=Fz/Sf9oPvIE07xcwb9c6VD6hsoA3v/DHCOBtHSEZssv58szNp+feSYg8QeQ1fYDi83
         GunuR/01k9Jks+8AdHAhJVHC4Zzg5mWkZ5HIUo8fGV5WYw3wLbtjm4EsuYJo8J8ypDD0
         2kLXQBLg8BZNuEcZ9kEvbaFER5EEywyLZtjXor0bmHhhbhMdn0DTdj/jWgX2BC0PQdpz
         BJGtc8gHWVWKbVwxXCfYmNgf3/mKCou1jk/5W/tCYfuR8VBPBeoZS03mJhtksr5SKnEd
         JJag7pQa+CWSDcI9v0LbGsbtJZjtviyPzy07fWiVMhKd2CUfXVecRchHJ0oRVMTGXu2B
         8kcQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=ewlumg6CCGkfxUO72Yi4z9djh6d1wc1yinxVVUQlnPg=;
        b=WlD4AE7l6INvWvUNPmGLHrku6NsP5lSIbjvVuFLdSIuoNIBsUjxsoBW71dVcRycF31
         esKw2W3wwN6KZ1N0IxGG+HMB+nwd/z0dyU4/Ee3uroldPKGWxuZlSOiWXKO6xAiL4c/8
         KmjJNeeR+vt9S6dZDHxGNLjYIlffn+JbHLW3VpQC9PRe4tEeTlA6b7V28KHAGOFT4TIu
         CL7Y5qELGBLr/4IpGula7hCzv6/HCSaCGubCnLsAiQ8GZOJhH/70fBkmjXsddH4hOZVs
         1IKDrCCG0dE7K1zjI2oZPZCI80Wm7fEltlYcV4a0TYTrNujY0xMQBmXkGLToCLkmRhEj
         h6Og==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id a4si4515841pfj.68.2019.03.07.08.38.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Mar 2019 08:38:53 -0800 (PST)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.93 as permitted sender) client-ip=192.55.52.93;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from fmsmga004.fm.intel.com ([10.253.24.48])
  by fmsmga102.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 07 Mar 2019 08:38:53 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,451,1544515200"; 
   d="scan'208";a="150217459"
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by fmsmga004.fm.intel.com with ESMTP; 07 Mar 2019 08:38:52 -0800
Date: Thu, 7 Mar 2019 00:37:17 -0800
From: Ira Weiny <ira.weiny@intel.com>
To: john.hubbard@gmail.com
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	Al Viro <viro@zeniv.linux.org.uk>,
	Christian Benvenuti <benve@cisco.com>,
	Christoph Hellwig <hch@infradead.org>,
	Christopher Lameter <cl@linux.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Dave Chinner <david@fromorbit.com>,
	Dennis Dalessandro <dennis.dalessandro@intel.com>,
	Doug Ledford <dledford@redhat.com>, Jan Kara <jack@suse.cz>,
	Jason Gunthorpe <jgg@ziepe.ca>, Jerome Glisse <jglisse@redhat.com>,
	Matthew Wilcox <willy@infradead.org>,
	Michal Hocko <mhocko@kernel.org>,
	Mike Rapoport <rppt@linux.ibm.com>,
	Mike Marciniszyn <mike.marciniszyn@intel.com>,
	Ralph Campbell <rcampbell@nvidia.com>, Tom Talpey <tom@talpey.com>,
	LKML <linux-kernel@vger.kernel.org>, linux-fsdevel@vger.kernel.org,
	John Hubbard <jhubbard@nvidia.com>
Subject: Re: [PATCH v3 0/1] mm: introduce put_user_page*(), placeholder
 versions
Message-ID: <20190307083716.GA21304@iweiny-DESK2.sc.intel.com>
References: <20190306235455.26348-1-jhubbard@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190306235455.26348-1-jhubbard@nvidia.com>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 06, 2019 at 03:54:54PM -0800, john.hubbard@gmail.com wrote:
> From: John Hubbard <jhubbard@nvidia.com>
> 
> Hi Andrew and all,
> 
> Can we please apply this (destined for 5.2) once the time is right?
> (I see that -mm just got merged into the main tree today.)
> 
> We seem to have pretty solid consensus on the concept and details of the
> put_user_pages() approach. Or at least, if we don't, someone please speak
> up now. Christopher Lameter, especially, since you had some concerns
> recently.
> 
> Therefore, here is the first patch--only. This allows us to begin
> converting the get_user_pages() call sites to use put_user_page(), instead
> of put_page(). This is in order to implement tracking of get_user_page()
> pages.
> 
> Normally I'd include a user of this code, but in this case, I think we have
> examples of how it will work in the RFC and related discussions [1]. What
> matters more at this point is unblocking the ability to start fixing up
> various subsystems, through git trees other than linux-mm. For example, the
> Infiniband example conversion now needs to pick up some prerequisite
> patches via the RDMA tree. It seems likely that other call sites may need
> similar attention, and so having put_user_pages() available would really
> make this go more quickly.
>

FWIW I agree with John.

Ira

> 
> Previous cover letter follows:
> ==============================
> 
> A discussion of the overall problem is below.
> 
> As mentioned in patch 0001, the steps are to fix the problem are:
> 
> 1) Provide put_user_page*() routines, intended to be used
>    for releasing pages that were pinned via get_user_pages*().
> 
> 2) Convert all of the call sites for get_user_pages*(), to
>    invoke put_user_page*(), instead of put_page(). This involves dozens of
>    call sites, and will take some time.
> 
> 3) After (2) is complete, use get_user_pages*() and put_user_page*() to
>    implement tracking of these pages. This tracking will be separate from
>    the existing struct page refcounting.
> 
> 4) Use the tracking and identification of these pages, to implement
>    special handling (especially in writeback paths) when the pages are
>    backed by a filesystem.
> 
> Overview
> ========
> 
> Some kernel components (file systems, device drivers) need to access
> memory that is specified via process virtual address. For a long time, the
> API to achieve that was get_user_pages ("GUP") and its variations. However,
> GUP has critical limitations that have been overlooked; in particular, GUP
> does not interact correctly with filesystems in all situations. That means
> that file-backed memory + GUP is a recipe for potential problems, some of
> which have already occurred in the field.
> 
> GUP was first introduced for Direct IO (O_DIRECT), allowing filesystem code
> to get the struct page behind a virtual address and to let storage hardware
> perform a direct copy to or from that page. This is a short-lived access
> pattern, and as such, the window for a concurrent writeback of GUP'd page
> was small enough that there were not (we think) any reported problems.
> Also, userspace was expected to understand and accept that Direct IO was
> not synchronized with memory-mapped access to that data, nor with any
> process address space changes such as munmap(), mremap(), etc.
> 
> Over the years, more GUP uses have appeared (virtualization, device
> drivers, RDMA) that can keep the pages they get via GUP for a long period
> of time (seconds, minutes, hours, days, ...). This long-term pinning makes
> an underlying design problem more obvious.
> 
> In fact, there are a number of key problems inherent to GUP:
> 
> Interactions with file systems
> ==============================
> 
> File systems expect to be able to write back data, both to reclaim pages,
> and for data integrity. Allowing other hardware (NICs, GPUs, etc) to gain
> write access to the file memory pages means that such hardware can dirty
> the pages, without the filesystem being aware. This can, in some cases
> (depending on filesystem, filesystem options, block device, block device
> options, and other variables), lead to data corruption, and also to kernel
> bugs of the form:
> 
>     kernel BUG at /build/linux-fQ94TU/linux-4.4.0/fs/ext4/inode.c:1899!
>     backtrace:
>         ext4_writepage
>         __writepage
>         write_cache_pages
>         ext4_writepages
>         do_writepages
>         __writeback_single_inode
>         writeback_sb_inodes
>         __writeback_inodes_wb
>         wb_writeback
>         wb_workfn
>         process_one_work
>         worker_thread
>         kthread
>         ret_from_fork
> 
> ...which is due to the file system asserting that there are still buffer
> heads attached:
> 
>         ({                                                      \
>                 BUG_ON(!PagePrivate(page));                     \
>                 ((struct buffer_head *)page_private(page));     \
>         })
> 
> Dave Chinner's description of this is very clear:
> 
>     "The fundamental issue is that ->page_mkwrite must be called on every
>     write access to a clean file backed page, not just the first one.
>     How long the GUP reference lasts is irrelevant, if the page is clean
>     and you need to dirty it, you must call ->page_mkwrite before it is
>     marked writeable and dirtied. Every. Time."
> 
> This is just one symptom of the larger design problem: filesystems do not
> actually support get_user_pages() being called on their pages, and letting
> hardware write directly to those pages--even though that pattern has been
> going on since about 2005 or so.
> 
> Long term GUP
> =============
> 
> Long term GUP is an issue when FOLL_WRITE is specified to GUP (so, a
> writeable mapping is created), and the pages are file-backed. That can lead
> to filesystem corruption. What happens is that when a file-backed page is
> being written back, it is first mapped read-only in all of the CPU page
> tables; the file system then assumes that nobody can write to the page, and
> that the page content is therefore stable. Unfortunately, the GUP callers
> generally do not monitor changes to the CPU pages tables; they instead
> assume that the following pattern is safe (it's not):
> 
>     get_user_pages()
> 
>     Hardware can keep a reference to those pages for a very long time,
>     and write to it at any time. Because "hardware" here means "devices
>     that are not a CPU", this activity occurs without any interaction
>     with the kernel's file system code.
> 
>     for each page
>         set_page_dirty
>         put_page()
> 
> In fact, the GUP documentation even recommends that pattern.
> 
> Anyway, the file system assumes that the page is stable (nothing is writing
> to the page), and that is a problem: stable page content is necessary for
> many filesystem actions during writeback, such as checksum, encryption,
> RAID striping, etc. Furthermore, filesystem features like COW (copy on
> write) or snapshot also rely on being able to use a new page for as memory
> for that memory range inside the file.
> 
> Corruption during write back is clearly possible here. To solve that, one
> idea is to identify pages that have active GUP, so that we can use a bounce
> page to write stable data to the filesystem. The filesystem would work
> on the bounce page, while any of the active GUP might write to the
> original page. This would avoid the stable page violation problem, but note
> that it is only part of the overall solution, because other problems
> remain.
> 
> Other filesystem features that need to replace the page with a new one can
> be inhibited for pages that are GUP-pinned. This will, however, alter and
> limit some of those filesystem features. The only fix for that would be to
> require GUP users to monitor and respond to CPU page table updates.
> Subsystems such as ODP and HMM do this, for example. This aspect of the
> problem is still under discussion.
> 
> Direct IO
> =========
> 
> Direct IO can cause corruption, if userspace does Direct-IO that writes to
> a range of virtual addresses that are mmap'd to a file.  The pages written
> to are file-backed pages that can be under write back, while the Direct IO
> is taking place.  Here, Direct IO races with a write back: it calls
> GUP before page_mkclean() has replaced the CPU pte with a read-only entry.
> The race window is pretty small, which is probably why years have gone by
> before we noticed this problem: Direct IO is generally very quick, and
> tends to finish up before the filesystem gets around to do anything with
> the page contents.  However, it's still a real problem.  The solution is
> to never let GUP return pages that are under write back, but instead,
> force GUP to take a write fault on those pages.  That way, GUP will
> properly synchronize with the active write back.  This does not change the
> required GUP behavior, it just avoids that race.
> 
> Changes since v2:
> 
>  * Reduced down to just one patch, in order to avoid dependencies between
>    subsystem git repos.
> 
>  * Rebased to latest linux.git: commit afe6fe7036c6 ("Merge tag
>    'armsoc-late' of git://git.kernel.org/pub/scm/linux/kernel/git/soc/soc")
> 
>  * Added Ira's review tag, based on
>    https://lore.kernel.org/lkml/20190215002312.GC7512@iweiny-DESK2.sc.intel.com/
> 
> 
> [1] https://lore.kernel.org/r/20190208075649.3025-3-jhubbard@nvidia.com
>     (RFC v2: mm: gup/dma tracking)
> 
> Cc: Christian Benvenuti <benve@cisco.com>
> Cc: Christoph Hellwig <hch@infradead.org>
> Cc: Christopher Lameter <cl@linux.com>
> Cc: Dan Williams <dan.j.williams@intel.com>
> Cc: Dave Chinner <david@fromorbit.com>
> Cc: Dennis Dalessandro <dennis.dalessandro@intel.com>
> Cc: Doug Ledford <dledford@redhat.com>
> Cc: Ira Weiny <ira.weiny@intel.com>
> Cc: Jan Kara <jack@suse.cz>
> Cc: Jason Gunthorpe <jgg@ziepe.ca>
> Cc: Jérôme Glisse <jglisse@redhat.com>
> Cc: Matthew Wilcox <willy@infradead.org>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Mike Rapoport <rppt@linux.ibm.com>
> Cc: Mike Marciniszyn <mike.marciniszyn@intel.com>
> Cc: Ralph Campbell <rcampbell@nvidia.com>
> Cc: Tom Talpey <tom@talpey.com>
> 
> 
> John Hubbard (1):
>   mm: introduce put_user_page*(), placeholder versions
> 
>  include/linux/mm.h | 24 ++++++++++++++
>  mm/swap.c          | 82 ++++++++++++++++++++++++++++++++++++++++++++++
>  2 files changed, 106 insertions(+)
> 
> -- 
> 2.21.0
> 

