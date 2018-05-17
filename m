Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5B0BD6B037A
	for <linux-mm@kvack.org>; Wed, 16 May 2018 21:39:06 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id f5-v6so1070548pgq.19
        for <linux-mm@kvack.org>; Wed, 16 May 2018 18:39:06 -0700 (PDT)
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id i7-v6si3140377pgq.507.2018.05.16.18.39.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 May 2018 18:39:04 -0700 (PDT)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH -mm] mm, hugetlb: Pass fault address to no page handler
References: <20180515005756.28942-1-ying.huang@intel.com>
	<20180515103812.aapv4b4hbzno52zl@kshutemo-mobl1>
	<878t8kzb0c.fsf@yhuang-dev.intel.com>
	<20180516080312.rx6owusozklkmypj@black.fi.intel.com>
Date: Thu, 17 May 2018 09:39:00 +0800
In-Reply-To: <20180516080312.rx6owusozklkmypj@black.fi.intel.com> (Kirill
	A. Shutemov's message of "Wed, 16 May 2018 11:03:12 +0300")
Message-ID: <87lgcjxdqj.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrea Arcangeli <aarcange@redhat.com>, Andi Kleen <andi.kleen@intel.com>, Jan Kara <jack@suse.cz>, Michal Hocko <mhocko@suse.com>, Matthew Wilcox <mawilcox@microsoft.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Shaohua Li <shli@fb.com>, Christopher Lameter <cl@linux.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Punit Agrawal <punit.agrawal@arm.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>

"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> writes:

> On Wed, May 16, 2018 at 12:42:43AM +0000, Huang, Ying wrote:
>> >> +	unsigned long address = faddress & huge_page_mask(h);
>> >
>> > faddress? I would rather keep it address and rename maked out variable to
>> > 'haddr'. We use 'haddr' for the cause in other places.
>> 
>> I found haddr is popular in huge_memory.c but not used in hugetlb.c at
>> all.  Is it desirable to start to use "haddr" in hugetlb.c?
>
> Yes, I think so. There's no reason to limit haddr convention to THP.

OK.  Will do this.

Best Regards,
Huang, Ying
