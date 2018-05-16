Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id AA4B46B0307
	for <linux-mm@kvack.org>; Wed, 16 May 2018 04:03:19 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id x23-v6so2175041pfm.7
        for <linux-mm@kvack.org>; Wed, 16 May 2018 01:03:19 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id u62-v6si1605920pgc.180.2018.05.16.01.03.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 May 2018 01:03:18 -0700 (PDT)
Date: Wed, 16 May 2018 11:03:12 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCH -mm] mm, hugetlb: Pass fault address to no page handler
Message-ID: <20180516080312.rx6owusozklkmypj@black.fi.intel.com>
References: <20180515005756.28942-1-ying.huang@intel.com>
 <20180515103812.aapv4b4hbzno52zl@kshutemo-mobl1>
 <878t8kzb0c.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <878t8kzb0c.fsf@yhuang-dev.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrea Arcangeli <aarcange@redhat.com>, Andi Kleen <andi.kleen@intel.com>, Jan Kara <jack@suse.cz>, Michal Hocko <mhocko@suse.com>, Matthew Wilcox <mawilcox@microsoft.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Shaohua Li <shli@fb.com>, Christopher Lameter <cl@linux.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Punit Agrawal <punit.agrawal@arm.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>

On Wed, May 16, 2018 at 12:42:43AM +0000, Huang, Ying wrote:
> >> +	unsigned long address = faddress & huge_page_mask(h);
> >
> > faddress? I would rather keep it address and rename maked out variable to
> > 'haddr'. We use 'haddr' for the cause in other places.
> 
> I found haddr is popular in huge_memory.c but not used in hugetlb.c at
> all.  Is it desirable to start to use "haddr" in hugetlb.c?

Yes, I think so. There's no reason to limit haddr convention to THP.

-- 
 Kirill A. Shutemov
