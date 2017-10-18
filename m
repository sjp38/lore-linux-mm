Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3C15D6B0069
	for <linux-mm@kvack.org>; Wed, 18 Oct 2017 04:40:25 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id l18so2056455wrc.23
        for <linux-mm@kvack.org>; Wed, 18 Oct 2017 01:40:25 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h4sor5518336edb.7.2017.10.18.01.40.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 18 Oct 2017 01:40:24 -0700 (PDT)
Date: Wed, 18 Oct 2017 11:40:22 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] mm: mark mm_pgtables_bytes() argument as const
Message-ID: <20171018084021.ha3ftkbfn5cqqjm6@node.shutemov.name>
References: <20171018083226.3124972-1-arnd@arndb.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171018083226.3124972-1-arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Jan Kara <jack@suse.cz>, Ross Zwisler <ross.zwisler@linux.intel.com>, Lorenzo Stoakes <lstoakes@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Oct 18, 2017 at 10:31:17AM +0200, Arnd Bergmann wrote:
> The newly introduced mm_pgtables_bytes() function has two
> definitions with slightly different prototypes. The one
> used for CONFIG_MMU=n causes a compile-time warning:
> 
> In file included from include/linux/kernel.h:13:0,
>                  from mm/debug.c:8:
> mm/debug.c: In function 'dump_mm':
> mm/debug.c:137:21: error: passing argument 1 of 'mm_pgtables_bytes' discards 'const' qualifier from pointer target type [-Werror=discarded-qualifiers]
> 
> This changes it to be the same as the other one and avoid the
> warning.
> 
> Fixes: 7444e6ee9cce ("mm: consolidate page table accounting")
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

The fix is already in mmots:

http://ozlabs.org/~akpm/mmots/broken-out/mm-consolidate-page-table-accounting-fix.patch

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
