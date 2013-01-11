Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id 016ED6B0068
	for <linux-mm@kvack.org>; Fri, 11 Jan 2013 15:53:31 -0500 (EST)
Received: by mail-vb0-f43.google.com with SMTP id fs19so1839230vbb.16
        for <linux-mm@kvack.org>; Fri, 11 Jan 2013 12:53:31 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1357379377-30021-1-git-send-email-jcmvbkbc@gmail.com>
References: <1357379377-30021-1-git-send-email-jcmvbkbc@gmail.com>
Date: Fri, 11 Jan 2013 12:53:30 -0800
Message-ID: <CAGXD9Of=ByWJFv7fXb2g_uzufhw-P=nCSkYnGOA8BpNOP_YgRw@mail.gmail.com>
Subject: Re: [PATCH v3] mm: bootmem: fix free_all_bootmem_core with odd bitmap alignment
From: Prasad Koya <prasad.koya@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Max Filippov <jcmvbkbc@gmail.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, "David S. Miller" <davem@davemloft.net>, Tejun Heo <tj@kernel.org>, Joonsoo Kim <js1304@gmail.com>

Hi

I am seeing similar issue with 2.6.38 as well.

[    0.000000] Your BIOS doesn't leave a aperture memory hole
[    0.000000] Please enable the IOMMU option in the BIOS setup
[    0.000000] This costs you 64 MB of RAM
[    0.000000] Mapping aperture over 65536 KB of RAM @ b4000000
[    0.000000] BUG: Bad page state in process swapper  pfn:73676
[    0.000000] page:ffffea0002ee1ff0 count:0 mapcount:0
mapping:0040000054000045 index:0xdb0a0008120411ac
[    0.000000] page flags: 0x4000000000000000()
[    0.000000] Pid: 0, comm: swapper Not tainted
2.6.38.8.Ar-1049552.2012kernelmainline.2 #1
[    0.000000] Call Trace:
[    0.000000] [<ffffffff81077ac8>] ? dump_page+0xd3/0xd8
[    0.000000] [<ffffffff81078ac4>] ? bad_page+0xef/0x105
[    0.000000] [<ffffffff81078b37>] ? free_pages_prepare+0x5d/0x98
[    0.000000] [<ffffffff8107946f>] ? __free_pages_ok+0x1e/0x94
[    0.000000] [<ffffffff81079673>] ? __free_pages+0x22/0x24
[    0.000000] [<ffffffff816b2f79>] ? __free_pages_bootmem+0x54/0x56
[    0.000000] [<ffffffff81698a35>] ? free_all_memory_core_early+0xd4/0x134
[    0.000000] [<ffffffff81393e40>] ? _etext+0x0/0x2f01c0
[    0.000000] [<ffffffff81698aa3>] ? free_all_bootmem+0xe/0x10
[    0.000000] [<ffffffff816932ff>] ? mem_init+0x1e/0xec
[    0.000000] [<ffffffff81684af3>] ? start_kernel+0x1a0/0x362
[    0.000000] [<ffffffff816842a8>] ? x86_64_start_reservations+0xb8/0xbc
[    0.000000] [<ffffffff8168439e>] ? x86_64_start_kernel+0xf2/0xf9
[    0.000000] Disabling lock debugging due to kernel taint
[    0.000000] BUG: Bad page state in process swapper  pfn:73677
[    0.000000] page:ffffea0002ee2058 count:0 mapcount:0 mapping:
   (null) index:0x0
[    0.000000] page flags:
0x5b1a191817161114(referenced|dirty|owner_priv_1|private_2|mappedtodisk|reclaim|unevictable)
[    0.000000] Pid: 0, comm: swapper Tainted: G    B
2.6.38.8.Ar-1049552.2012kernelmainline.2 #1
[    0.000000] Call Trace:
[    0.000000] [<ffffffff81077ac8>] ? dump_page+0xd3/0xd8
[    0.000000] [<ffffffff81078ac4>] ? bad_page+0xef/0x105
[    0.000000] [<ffffffff81078b37>] ? free_pages_prepare+0x5d/0x98
[    0.000000] [<ffffffff8107946f>] ? __free_pages_ok+0x1e/0x94
[    0.000000] [<ffffffff81079673>] ? __free_pages+0x22/0x24
[    0.000000] [<ffffffff816b2f79>] ? __free_pages_bootmem+0x54/0x56
[    0.000000] [<ffffffff81698a35>] ? free_all_memory_core_early+0xd4/0x134
[    0.000000] [<ffffffff81393e40>] ? _etext+0x0/0x2f01c0
[    0.000000] [<ffffffff81698aa3>] ? free_all_bootmem+0xe/0x10
[    0.000000] [<ffffffff816932ff>] ? mem_init+0x1e/0xec
[    0.000000] [<ffffffff81684af3>] ? start_kernel+0x1a0/0x362
[    0.000000] [<ffffffff816842a8>] ? x86_64_start_reservations+0xb8/0xbc
[    0.000000] [<ffffffff8168439e>] ? x86_64_start_kernel+0xf2/0xf9
[    0.000000] BUG: Bad page state in process swapper  pfn:73d8a
[    0.000000] page:ffffea0002f10010 count:0 mapcount:0
mapping:0b0a09080001f1c5 index:0x1b1a191817161514
[    0.000000] page flags: 0x4000000000000000()
[    0.000000] Pid: 0, comm: swapper Tainted: G    B
2.6.38.8.Ar-1049552.2012kernelmainline.2 #1
[    0.000000] Call Trace:
[    0.000000] [<ffffffff81077ac8>] ? dump_page+0xd3/0xd8
[    0.000000] [<ffffffff81078ac4>] ? bad_page+0xef/0x105
[    0.000000] [<ffffffff81078b37>] ? free_pages_prepare+0x5d/0x98
[    0.000000] [<ffffffff8107946f>] ? __free_pages_ok+0x1e/0x94
[    0.000000] [<ffffffff81079673>] ? __free_pages+0x22/0x24
[    0.000000] [<ffffffff816b2f79>] ? __free_pages_bootmem+0x54/0x56
[    0.000000] [<ffffffff81698a35>] ? free_all_memory_core_early+0xd4/0x134
[    0.000000] [<ffffffff81393e40>] ? _etext+0x0/0x2f01c0
[    0.000000] [<ffffffff81698aa3>] ? free_all_bootmem+0xe/0x10
[    0.000000] [<ffffffff816932ff>] ? mem_init+0x1e/0xec
[    0.000000] [<ffffffff81684af3>] ? start_kernel+0x1a0/0x362
[    0.000000] [<ffffffff816842a8>] ? x86_64_start_reservations+0xb8/0xbc
[    0.000000] [<ffffffff8168439e>] ? x86_64_start_kernel+0xf2/0xf9
[    0.000000] BUG: Bad page state in process swapper  pfn:73d8b
[    0.000000] page:ffffea0002f10078 count:0 mapcount:0 mapping:
   (null) index:0x0
[    0.000000] page flags:
0x7d78d20b37363134(referenced|dirty|lru|owner_priv_1|private_2|writeback|mappedtodisk|reclaim|unevictable|mlocked)
[    0.000000] Pid: 0, comm: swapper Tainted: G    B
2.6.38.8.Ar-1049552.2012kernelmainline.2 #1
[    0.000000] Call Trace:
[    0.000000] [<ffffffff81077ac8>] ? dump_page+0xd3/0xd8
[    0.000000] [<ffffffff81078ac4>] ? bad_page+0xef/0x105
[    0.000000] [<ffffffff81078b37>] ? free_pages_prepare+0x5d/0x98
[    0.000000] [<ffffffff8107946f>] ? __free_pages_ok+0x1e/0x94
[    0.000000] [<ffffffff81079673>] ? __free_pages+0x22/0x24
[    0.000000] [<ffffffff816b2f79>] ? __free_pages_bootmem+0x54/0x56
[    0.000000] [<ffffffff81698a35>] ? free_all_memory_core_early+0xd4/0x134
[    0.000000] [<ffffffff81393e40>] ? _etext+0x0/0x2f01c0
[    0.000000] [<ffffffff81698aa3>] ? free_all_bootmem+0xe/0x10
[    0.000000] [<ffffffff816932ff>] ? mem_init+0x1e/0xec
[    0.000000] [<ffffffff81684af3>] ? start_kernel+0x1a0/0x362
[    0.000000] [<ffffffff816842a8>] ? x86_64_start_reservations+0xb8/0xbc
[    0.000000] [<ffffffff8168439e>] ? x86_64_start_kernel+0xf2/0xf9
[    0.000000] Memory: 3891076k/5242880k available (3663k kernel code,
1049088k absent, 302204k reserved, 2930k data, 416k init)

On Sat, Jan 5, 2013 at 1:49 AM, Max Filippov <jcmvbkbc@gmail.com> wrote:
> Currently free_all_bootmem_core ignores that node_min_pfn may be not
> multiple of BITS_PER_LONG. E.g. commit 6dccdcbe "mm: bootmem: fix
> checking the bitmap when finally freeing bootmem" shifts vec by lower
> bits of start instead of lower bits of idx. Also
>
>   if (IS_ALIGNED(start, BITS_PER_LONG) && vec == ~0UL)
>
> assumes that vec bit 0 corresponds to start pfn, which is only true when
> node_min_pfn is a multiple of BITS_PER_LONG. Also loop in the else
> clause can double-free pages (e.g. with node_min_pfn == start == 1,
> map[0] == ~0 on 32-bit machine page 32 will be double-freed).
>
> This bug causes the following message during xtensa kernel boot:
>
> [    0.000000] bootmem::free_all_bootmem_core nid=0 start=1 end=8000
> [    0.000000] BUG: Bad page state in process swapper  pfn:00001
> [    0.000000] page:d04bd020 count:0 mapcount:-127 mapping:  (null) index:0x2
> [    0.000000] page flags: 0x0()
> [    0.000000]
> [    0.000000] Stack: 00000000 00000002 00000004 ffffffff d0193e44 ffffff81 00000000 00000002
> [    0.000000]        90038c66 d0193e90 d04bd020 000001a8 00000000 ffffffff 00000000 00000020
> [    0.000000]        90039a4c d0193eb0 d04bd020 00000001 d04b7b20 ffff8ad0 00000000 00000000
> [    0.000000] Call Trace:
> [    0.000000]  [<d0038bf8>] bad_page+0x8c/0x9c
> [    0.000000]  [<d0038c66>] free_pages_prepare+0x5e/0x88
> [    0.000000]  [<d0039a4c>] free_hot_cold_page+0xc/0xa0
> [    0.000000]  [<d0039b28>] __free_pages+0x24/0x38
> [    0.000000]  [<d01b8230>] __free_pages_bootmem+0x54/0x56
> [    0.000000]  [<d01b1667>] free_all_bootmem_core$part$11+0xeb/0x138
> [    0.000000]  [<d01b179e>] free_all_bootmem+0x46/0x58
> [    0.000000]  [<d01ae7a9>] mem_init+0x25/0xa4
> [    0.000000]  [<d01ad13e>] start_kernel+0x11e/0x25c
> [    0.000000]  [<d01a9121>] should_never_return+0x0/0x3be7
>
> The fix is the following:
> - always align vec so that its bit 0 corresponds to start
> - provide BITS_PER_LONG bits in vec, if those bits are available in the map
> - don't free pages past next start position in the else clause.
>
> Signed-off-by: Max Filippov <jcmvbkbc@gmail.com>
> ---
> Arrrgh, I no longer send patches at 4am, sorry ):
> v1 didn't build, v2 else loop initialization was wrong.
>
>  mm/bootmem.c |   24 ++++++++++++++++++------
>  1 files changed, 18 insertions(+), 6 deletions(-)
>
> diff --git a/mm/bootmem.c b/mm/bootmem.c
> index 1324cd7..b93376c 100644
> --- a/mm/bootmem.c
> +++ b/mm/bootmem.c
> @@ -185,10 +185,23 @@ static unsigned long __init free_all_bootmem_core(bootmem_data_t *bdata)
>
>         while (start < end) {
>                 unsigned long *map, idx, vec;
> +               unsigned shift;
>
>                 map = bdata->node_bootmem_map;
>                 idx = start - bdata->node_min_pfn;
> +               shift = idx & (BITS_PER_LONG - 1);
> +               /*
> +                * vec holds at most BITS_PER_LONG map bits,
> +                * bit 0 corresponds to start.
> +                */
>                 vec = ~map[idx / BITS_PER_LONG];
> +
> +               if (shift) {
> +                       vec >>= shift;
> +                       if (end - start >= BITS_PER_LONG)
> +                               vec |= ~map[idx / BITS_PER_LONG + 1] <<
> +                                       (BITS_PER_LONG - shift);
> +               }
>                 /*
>                  * If we have a properly aligned and fully unreserved
>                  * BITS_PER_LONG block of pages in front of us, free
> @@ -201,19 +214,18 @@ static unsigned long __init free_all_bootmem_core(bootmem_data_t *bdata)
>                         count += BITS_PER_LONG;
>                         start += BITS_PER_LONG;
>                 } else {
> -                       unsigned long off = 0;
> +                       unsigned long cur = start;
>
> -                       vec >>= start & (BITS_PER_LONG - 1);
> -                       while (vec) {
> +                       start = ALIGN(start + 1, BITS_PER_LONG);
> +                       while (vec && cur != start) {
>                                 if (vec & 1) {
> -                                       page = pfn_to_page(start + off);
> +                                       page = pfn_to_page(cur);
>                                         __free_pages_bootmem(page, 0);
>                                         count++;
>                                 }
>                                 vec >>= 1;
> -                               off++;
> +                               ++cur;
>                         }
> -                       start = ALIGN(start + 1, BITS_PER_LONG);
>                 }
>         }
>
> --
> 1.7.7.6
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
