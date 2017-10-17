Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id BEFDF6B0038
	for <linux-mm@kvack.org>; Tue, 17 Oct 2017 07:21:03 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id h191so732420wmd.15
        for <linux-mm@kvack.org>; Tue, 17 Oct 2017 04:21:03 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k26sor4810015edk.44.2017.10.17.04.21.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 17 Oct 2017 04:21:02 -0700 (PDT)
Date: Tue, 17 Oct 2017 14:21:00 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH -mm] mm, pagemap: Fix soft dirty marking for PMD
 migration entry
Message-ID: <20171017112100.pciya6pmo62owpht@node.shutemov.name>
References: <20171017081818.31795-1-ying.huang@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20171017081818.31795-1-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, David Rientjes <rientjes@google.com>, Arnd Bergmann <arnd@arndb.de>, Hugh Dickins <hughd@google.com>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, Daniel Colascione <dancol@google.com>, Zi Yan <zi.yan@cs.rutgers.edu>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

On Tue, Oct 17, 2017 at 04:18:18PM +0800, Huang, Ying wrote:
> From: Huang Ying <ying.huang@intel.com>
> 
> Now, when the page table is walked in the implementation of
> /proc/<pid>/pagemap, pmd_soft_dirty() is used for both the PMD huge
> page map and the PMD migration entries.  That is wrong,
> pmd_swp_soft_dirty() should be used for the PMD migration entries
> instead because the different page table entry flag is used.
> 
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> Cc: David Rientjes <rientjes@google.com>
> Cc: Arnd Bergmann <arnd@arndb.de>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: "Jerome Glisse" <jglisse@redhat.com>
> Cc: Daniel Colascione <dancol@google.com>
> Cc: Zi Yan <zi.yan@cs.rutgers.edu>
> Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Signed-off-by: "Huang, Ying" <ying.huang@intel.com>

What is effect of the misbehaviour? pagemap reports garbage?

Shoudn't it be in stable@? And maybe add Fixes: <sha1>.

Otherwise, looks good to me.

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
