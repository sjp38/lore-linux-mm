Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9CCC46B0261
	for <linux-mm@kvack.org>; Tue, 17 Oct 2017 09:55:16 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id x7so1330690pfa.19
        for <linux-mm@kvack.org>; Tue, 17 Oct 2017 06:55:16 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id 1si812210pln.617.2017.10.17.06.55.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Oct 2017 06:55:15 -0700 (PDT)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH -mm] mm, pagemap: Fix soft dirty marking for PMD migration entry
References: <20171017081818.31795-1-ying.huang@intel.com>
	<20171017112100.pciya6pmo62owpht@node.shutemov.name>
	<874lqy7yks.fsf@yhuang-dev.intel.com> <59E5F881.20105@cs.rutgers.edu>
Date: Tue, 17 Oct 2017 21:55:12 +0800
In-Reply-To: <59E5F881.20105@cs.rutgers.edu> (Zi Yan's message of "Tue, 17 Oct
	2017 08:33:05 -0400")
Message-ID: <87vajd7ubj.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zi Yan <zi.yan@cs.rutgers.edu>
Cc: "Huang, Ying" <ying.huang@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, David Rientjes <rientjes@google.com>, Arnd Bergmann <arnd@arndb.de>, Hugh Dickins <hughd@google.com>, =?utf-8?B?Su+/vXLvv71tZQ==?= Glisse <jglisse@redhat.com>, Daniel Colascione <dancol@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

Zi Yan <zi.yan@cs.rutgers.edu> writes:

> Huang, Ying wrote:
>> "Kirill A. Shutemov" <kirill@shutemov.name> writes:
>> 
>>> On Tue, Oct 17, 2017 at 04:18:18PM +0800, Huang, Ying wrote:
>>>> From: Huang Ying <ying.huang@intel.com>
>>>>
>>>> Now, when the page table is walked in the implementation of
>>>> /proc/<pid>/pagemap, pmd_soft_dirty() is used for both the PMD huge
>>>> page map and the PMD migration entries.  That is wrong,
>>>> pmd_swp_soft_dirty() should be used for the PMD migration entries
>>>> instead because the different page table entry flag is used.
>>>>
>>>> Cc: Michal Hocko <mhocko@suse.com>
>>>> Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
>>>> Cc: David Rientjes <rientjes@google.com>
>>>> Cc: Arnd Bergmann <arnd@arndb.de>
>>>> Cc: Hugh Dickins <hughd@google.com>
>>>> Cc: "J.r.me Glisse" <jglisse@redhat.com>
>>>> Cc: Daniel Colascione <dancol@google.com>
>>>> Cc: Zi Yan <zi.yan@cs.rutgers.edu>
>>>> Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
>>>> Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
>>> What is effect of the misbehaviour? pagemap reports garbage?
>> 
>> Yes.  pagemap may report incorrect soft dirty information for PMD
>> migration entries.
>
> Thanks for fixing it.
>
>> 
>>> Shoudn't it be in stable@? And maybe add Fixes: <sha1>.
>> 
>> Yes.  Will do that in the next version.
>
> PMD migration is merged in 4.14, which is not final yet. Do we need to
> split the patch, so that first hunk(for present PMD entries) goes into
> stable and second hunk(for PMD migration entries) goes into 4.14?

Oh, if so, I think we don't need to back port it to stable kernel.  But
we still need Fixes: tag.

Best Regards,
Huang, Ying

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
