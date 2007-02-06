Received: by ug-out-1314.google.com with SMTP id s2so9199uge
        for <linux-mm@kvack.org>; Tue, 06 Feb 2007 13:36:45 -0800 (PST)
Message-ID: <29495f1d0702061336ra41f060id52db9a1a26d47aa@mail.gmail.com>
Date: Tue, 6 Feb 2007 13:36:45 -0800
From: "Nish Aravamudan" <nish.aravamudan@gmail.com>
Subject: Re: hugetlb: preserve hugetlb pte dirty state
In-Reply-To: <b040c32a0702061306l771d2b71s719cee7cf4713e71@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <b040c32a0702061306l771d2b71s719cee7cf4713e71@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ken Chen <kenchen@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 2/6/07, Ken Chen <kenchen@google.com> wrote:
> __unmap_hugepage_range() is buggy that it does not preserve dirty
> state of huge_pte when unmapping hugepage range.  It causes data
> corruption in the event of dop_caches being used by sys admin.
> For example, an application creates a hugetlb file, modify pages,
> then unmap it.  While leaving the hugetlb file alive, comes along
> sys admin doing a "echo 3 > /proc/sys/vm/drop_caches".
> drop_pagecache_sb() will happily frees all pages that isn't marked
> dirty if there are no active mapping. Later when application remaps
> the hugetlb file back and all data are gone, triggering catastrophic
> flip over on application.
>
> Not only that, the internal resv_huge_pages count will also get all
> messed up.  Fix it up by marking page dirty appropriately.
>
> Signed-off-by: Ken Chen <kenchen@google.com>

This fixes my bug with HugePages_Rsvd going to 2^64 - 1.
("Hugepages_Rsvd goes huge in 2.6.20-rc7" is the subject on linux-mm).
Stable material, too, I would say.

Acked-by: Nishanth Aravamudan <nacc@us.ibm.com>

Thanks,
Nish

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
