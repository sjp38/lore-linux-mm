Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id B4F296B0253
	for <linux-mm@kvack.org>; Tue, 17 Oct 2017 08:23:41 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id w24so1401643pgm.7
        for <linux-mm@kvack.org>; Tue, 17 Oct 2017 05:23:41 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id z15si5404535pgr.145.2017.10.17.05.23.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Oct 2017 05:23:40 -0700 (PDT)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH -mm] mm, pagemap: Fix soft dirty marking for PMD migration entry
References: <20171017081818.31795-1-ying.huang@intel.com>
	<20171017112100.pciya6pmo62owpht@node.shutemov.name>
Date: Tue, 17 Oct 2017 20:23:15 +0800
In-Reply-To: <20171017112100.pciya6pmo62owpht@node.shutemov.name> (Kirill
	A. Shutemov's message of "Tue, 17 Oct 2017 14:21:00 +0300")
Message-ID: <874lqy7yks.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "Huang, Ying" <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, David Rientjes <rientjes@google.com>, Arnd Bergmann <arnd@arndb.de>, Hugh Dickins <hughd@google.com>, Jerome Glisse <jglisse@redhat.com>, Daniel Colascione <dancol@google.com>, Zi Yan <zi.yan@cs.rutgers.edu>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

"Kirill A. Shutemov" <kirill@shutemov.name> writes:

> On Tue, Oct 17, 2017 at 04:18:18PM +0800, Huang, Ying wrote:
>> From: Huang Ying <ying.huang@intel.com>
>> 
>> Now, when the page table is walked in the implementation of
>> /proc/<pid>/pagemap, pmd_soft_dirty() is used for both the PMD huge
>> page map and the PMD migration entries.  That is wrong,
>> pmd_swp_soft_dirty() should be used for the PMD migration entries
>> instead because the different page table entry flag is used.
>> 
>> Cc: Michal Hocko <mhocko@suse.com>
>> Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
>> Cc: David Rientjes <rientjes@google.com>
>> Cc: Arnd Bergmann <arnd@arndb.de>
>> Cc: Hugh Dickins <hughd@google.com>
>> Cc: "J.r.me Glisse" <jglisse@redhat.com>
>> Cc: Daniel Colascione <dancol@google.com>
>> Cc: Zi Yan <zi.yan@cs.rutgers.edu>
>> Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
>> Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
>
> What is effect of the misbehaviour? pagemap reports garbage?

Yes.  pagemap may report incorrect soft dirty information for PMD
migration entries.

> Shoudn't it be in stable@? And maybe add Fixes: <sha1>.

Yes.  Will do that in the next version.

> Otherwise, looks good to me.
>
> Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

Thanks!

Best Regards,
Huang, Ying

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
