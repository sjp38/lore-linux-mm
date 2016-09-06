Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4E3BA6B0038
	for <linux-mm@kvack.org>; Tue,  6 Sep 2016 16:16:05 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id g202so388003792pfb.3
        for <linux-mm@kvack.org>; Tue, 06 Sep 2016 13:16:05 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id lz7si36917258pab.147.2016.09.06.13.16.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Sep 2016 13:16:04 -0700 (PDT)
Date: Tue, 6 Sep 2016 13:16:03 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 3/5] mm: fix show_smap() for zone_device-pmd ranges
Message-Id: <20160906131603.5374113e726e1e05becc34cb@linux-foundation.org>
In-Reply-To: <147318057623.30325.10495460878595242707.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <147318056046.30325.5100892122988191500.stgit@dwillia2-desk3.amr.corp.intel.com>
	<147318057623.30325.10495460878595242707.stgit@dwillia2-desk3.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: linux-nvdimm@ml01.01.org, linux-mm@kvack.org, Ross Zwisler <ross.zwisler@linux.intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-kernel@vger.kernel.org

On Tue, 06 Sep 2016 09:49:36 -0700 Dan Williams <dan.j.williams@intel.com> wrote:

> Attempting to dump /proc/<pid>/smaps for a process with pmd dax mappings
> currently results in the following VM_BUG_ONs:
> 
>  kernel BUG at mm/huge_memory.c:1105!
>  task: ffff88045f16b140 task.stack: ffff88045be14000
>  RIP: 0010:[<ffffffff81268f9b>]  [<ffffffff81268f9b>] follow_trans_huge_pmd+0x2cb/0x340
>  [..]
>  Call Trace:
>   [<ffffffff81306030>] smaps_pte_range+0xa0/0x4b0
>   [<ffffffff814c2755>] ? vsnprintf+0x255/0x4c0
>   [<ffffffff8123c46e>] __walk_page_range+0x1fe/0x4d0
>   [<ffffffff8123c8a2>] walk_page_vma+0x62/0x80
>   [<ffffffff81307656>] show_smap+0xa6/0x2b0
> 
>  kernel BUG at fs/proc/task_mmu.c:585!
>  RIP: 0010:[<ffffffff81306469>]  [<ffffffff81306469>] smaps_pte_range+0x499/0x4b0
>  Call Trace:
>   [<ffffffff814c2795>] ? vsnprintf+0x255/0x4c0
>   [<ffffffff8123c46e>] __walk_page_range+0x1fe/0x4d0
>   [<ffffffff8123c8a2>] walk_page_vma+0x62/0x80
>   [<ffffffff81307696>] show_smap+0xa6/0x2b0
> 
> These locations are sanity checking page flags that must be set for an
> anonymous transparent huge page, but are not set for the zone_device
> pages associated with dax mappings.

Acked-by: Andrew Morton <akpm@linux-foundation.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
