Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7B4126B0005
	for <linux-mm@kvack.org>; Thu, 16 Aug 2018 08:34:36 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id r3-v6so3197781wrj.21
        for <linux-mm@kvack.org>; Thu, 16 Aug 2018 05:34:36 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u8-v6sor9621994wrq.10.2018.08.16.05.34.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 16 Aug 2018 05:34:35 -0700 (PDT)
Date: Thu, 16 Aug 2018 14:34:33 +0200
From: Oscar Salvador <osalvador@techadventures.net>
Subject: Re: [PATCH v1 2/5] mm/memory_hotplug: enforce section alignment when
 onlining/offlining
Message-ID: <20180816123433.GB16861@techadventures.net>
References: <20180816100628.26428-1-david@redhat.com>
 <20180816100628.26428-3-david@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180816100628.26428-3-david@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Stephen Rothwell <sfr@canb.auug.org.au>, Pavel Tatashin <pasha.tatashin@oracle.com>, Kemi Wang <kemi.wang@intel.com>, David Rientjes <rientjes@google.com>, Jia He <jia.he@hxt-semitech.com>, Oscar Salvador <osalvador@suse.de>, Petr Tesarik <ptesarik@suse.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Dan Williams <dan.j.williams@intel.com>, Mathieu Malaterre <malat@debian.org>, Baoquan He <bhe@redhat.com>, Wei Yang <richard.weiyang@gmail.com>, Ross Zwisler <zwisler@kernel.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>

On Thu, Aug 16, 2018 at 12:06:25PM +0200, David Hildenbrand wrote:
> onlining/offlining code works on whole sections, so let's enforce that.
> Existing code only allows to add memory in memory block size. And only
> whole memory blocks can be onlined/offlined. Memory blocks are always
> aligned to sections, so this should not break anything.
> 
> online_pages/offline_pages will implicitly mark whole sections
> online/offline, so the code really can only handle such granularities.
> 
> (especially offlining code cannot deal with pageblock_nr_pages but
>  theoretically only MAX_ORDER-1)
> 
> Signed-off-by: David Hildenbrand <david@redhat.com>

Hi David,

If you are really willing to move the checks from this patch[1] to
online/offline_pages, you might consider to put that in as well.
So we have a function that checks for everything, and not multiple checks.

Another thing is that I would have prefered to take the checks up to
memory_block_action, but offline_pages gets also called from ppc-memtrace code.

Other than that, 

Reviewed-by: Oscar Salvador <osalvador@suse.de>


[1] https://patchwork.kernel.org/patch/10567277/

Thanks
-- 
Oscar Salvador
SUSE L3
