Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3F34E6B0580
	for <linux-mm@kvack.org>; Fri, 18 May 2018 02:24:33 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id q67-v6so4593260wrb.12
        for <linux-mm@kvack.org>; Thu, 17 May 2018 23:24:33 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r17-v6si2037475edb.82.2018.05.17.23.24.32
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 17 May 2018 23:24:32 -0700 (PDT)
Date: Fri, 18 May 2018 08:24:30 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH -mm] mm, huge page: Copy to access sub-page last when
 copy huge page
Message-ID: <20180518062430.GB21711@dhcp22.suse.cz>
References: <20180518030316.31019-1-ying.huang@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180518030316.31019-1-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andi Kleen <andi.kleen@intel.com>, Jan Kara <jack@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Matthew Wilcox <mawilcox@microsoft.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Shaohua Li <shli@fb.com>, Christopher Lameter <cl@linux.com>, Mike Kravetz <mike.kravetz@oracle.com>

On Fri 18-05-18 11:03:16, Huang, Ying wrote:
[...]
> The patch is a generic optimization which should benefit quite some
> workloads, not for a specific use case.  To demonstrate the performance
> benefit of the patch, we tested it with vm-scalability run on
> transparent huge page.

It is also adds quite some non-intuitive code. So is this worth? Does
any _real_ workload benefits from the change?

>  include/linux/mm.h |  3 ++-
>  mm/huge_memory.c   |  3 ++-
>  mm/memory.c        | 43 +++++++++++++++++++++++++++++++++++++++----
>  3 files changed, 43 insertions(+), 6 deletions(-)
-- 
Michal Hocko
SUSE Labs
