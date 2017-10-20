Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2B90E6B0253
	for <linux-mm@kvack.org>; Fri, 20 Oct 2017 05:30:56 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id r6so9500123pfj.14
        for <linux-mm@kvack.org>; Fri, 20 Oct 2017 02:30:56 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id a34si399303pld.559.2017.10.20.02.30.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Oct 2017 02:30:54 -0700 (PDT)
Date: Fri, 20 Oct 2017 12:29:50 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCH -mm -V2] mm, pagemap: Fix soft dirty marking for PMD
 migration entry
Message-ID: <20171020092950.uikxca6ign4ydpjt@black.fi.intel.com>
References: <20171019151046.3443-1-ying.huang@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171019151046.3443-1-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@suse.com>, David Rientjes <rientjes@google.com>, Arnd Bergmann <arnd@arndb.de>, Hugh Dickins <hughd@google.com>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, Daniel Colascione <dancol@google.com>, Zi Yan <zi.yan@cs.rutgers.edu>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

On Thu, Oct 19, 2017 at 03:10:46PM +0000, Huang, Ying wrote:
> From: Huang Ying <ying.huang@intel.com>
> 
> Now, when the page table is walked in the implementation of
> /proc/<pid>/pagemap, pmd_soft_dirty() is used for both the PMD huge
> page map and the PMD migration entries.  That is wrong,
> pmd_swp_soft_dirty() should be used for the PMD migration entries
> instead because the different page table entry flag is used.
> Otherwise, the soft dirty information in /proc/<pid>/pagemap may be
> wrong.
> 
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

As I said before, you can use my ack for this.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
