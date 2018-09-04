Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id DF4746B6C74
	for <linux-mm@kvack.org>; Tue,  4 Sep 2018 04:01:23 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id a8-v6so1535282pla.10
        for <linux-mm@kvack.org>; Tue, 04 Sep 2018 01:01:23 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s188-v6sor4544101pgb.256.2018.09.04.01.01.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 04 Sep 2018 01:01:22 -0700 (PDT)
Date: Tue, 4 Sep 2018 11:01:16 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] mm: hugepage: mark splitted page dirty when needed
Message-ID: <20180904080115.o2zj4mlo7yzjdqfl@kshutemo-mobl1>
References: <20180904075510.22338-1-peterx@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180904075510.22338-1-peterx@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Xu <peterx@redhat.com>
Cc: linux-kernel@vger.kernel.org, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Zi Yan <zi.yan@cs.rutgers.edu>, Huang Ying <ying.huang@intel.com>, Dan Williams <dan.j.williams@intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, =?utf-8?B?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, Souptick Joarder <jrdr.linux@gmail.com>, linux-mm@kvack.org

On Tue, Sep 04, 2018 at 03:55:10PM +0800, Peter Xu wrote:
> When splitting a huge page, we should set all small pages as dirty if
> the original huge page has the dirty bit set before.  Otherwise we'll
> lose the original dirty bit.

We don't lose it. It got transfered to struct page flag:

	if (pmd_dirty(old_pmd))
		SetPageDirty(page);

-- 
 Kirill A. Shutemov
