Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f51.google.com (mail-wg0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 05EAD6B006E
	for <linux-mm@kvack.org>; Tue, 24 Feb 2015 09:48:08 -0500 (EST)
Received: by wggz12 with SMTP id z12so5758872wgg.2
        for <linux-mm@kvack.org>; Tue, 24 Feb 2015 06:48:07 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id fj3si23835834wib.98.2015.02.24.06.48.05
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 24 Feb 2015 06:48:06 -0800 (PST)
Date: Tue, 24 Feb 2015 15:48:04 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC v2 0/5] introduce gcma
Message-ID: <20150224144804.GE15626@dhcp22.suse.cz>
References: <1424721263-25314-1-git-send-email-sj38.park@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1424721263-25314-1-git-send-email-sj38.park@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: SeongJae Park <sj38.park@gmail.com>
Cc: akpm@linux-foundation.org, lauraa@codeaurora.org, minchan@kernel.org, sergey.senozhatsky@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue 24-02-15 04:54:18, SeongJae Park wrote:
[...]
>  include/linux/cma.h  |    4 +
>  include/linux/gcma.h |   64 +++
>  mm/Kconfig           |   24 +
>  mm/Makefile          |    1 +
>  mm/cma.c             |  113 ++++-
>  mm/gcma.c            | 1321 ++++++++++++++++++++++++++++++++++++++++++++++++++
>  6 files changed, 1508 insertions(+), 19 deletions(-)
>  create mode 100644 include/linux/gcma.h
>  create mode 100644 mm/gcma.c

Wow this is huge! And I do not see reason for it to be so big. Why
cannot you simply define (per-cma area) 2-class users policy? Either via
kernel command line or export areas to userspace and allow to set policy
there.

For starter something like the following policies should suffice AFAIU
your description.
	- NONE - exclusive pool for CMA allocations only
	- DROPABLE - only allocations which might be dropped without any
	  additional actions - e.g. cleancache and frontswap with
	  write-through policy
	- RECLAIMABLE - only movable allocations which can be migrated
	  or dropped after writeback.

Has such an approach been considered?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
