Date: Wed, 24 Jul 2002 21:50:40 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: page_add/remove_rmap costs
Message-ID: <20020725045040.GD2907@holomorphy.com>
References: <3D3E4A30.8A108B45@zip.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Description: brief message
Content-Disposition: inline
In-Reply-To: <3D3E4A30.8A108B45@zip.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, Jul 23, 2002 at 11:33:20PM -0700, Andrew Morton wrote:
> Been taking a look at the page_add_rmap/page_remove_rmap cost in 2.5.27
> on the quad pIII.  The workload is ten instances of this script running
> concurrently:

The workload is 16 instances of the same script running on a 16 cpu NUMA-Q
with 16GB of RAM. oprofile results attached.


Cheers,
Bill


c0105340 3309367  51.0125     default_idle            /boot/vmlinux-2.5.28-3
c0135667 1095488  16.8865     .text.lock.page_alloc   /boot/vmlinux-2.5.28-3
00000fec 475107   7.32358     dump_one                /lib/modules/2.5.28-3/kern
el/arch/i386/oprofile/oprofile.o
c0129c10 349662   5.3899      do_anonymous_page       /boot/vmlinux-2.5.28-3
c01353e4 236718   3.64891     get_page_state          /boot/vmlinux-2.5.28-3
c0112a84 213189   3.28622     load_balance            /boot/vmlinux-2.5.28-3
c013d31c 71599    1.10367     page_add_rmap           /boot/vmlinux-2.5.28-3
c013d3cc 67122    1.03466     page_remove_rmap        /boot/vmlinux-2.5.28-3
c013d85a 64302    0.991189    .text.lock.rmap         /boot/vmlinux-2.5.28-3
c013b2a0 49197    0.758352    blk_queue_bounce        /boot/vmlinux-2.5.28-3
c0129eb4 47963    0.73933     do_no_page              /boot/vmlinux-2.5.28-3
c010fa60 41383    0.637902    smp_apic_timer_interrupt /boot/vmlinux-2.5.28-3
c0134ba0 39661    0.611358    rmqueue                 /boot/vmlinux-2.5.28-3
c019f890 32770    0.505136    serial_in               /boot/vmlinux-2.5.28-3
c0133714 28913    0.445682    lru_cache_add           /boot/vmlinux-2.5.28-3
c0134840 27436    0.422915    __free_pages_ok         /boot/vmlinux-2.5.28-3
c013d71c 25028    0.385796    pte_chain_alloc         /boot/vmlinux-2.5.28-3
c01963c0 24580    0.378891    __generic_copy_to_user  /boot/vmlinux-2.5.28-3
c0196408 19186    0.295744    __generic_copy_from_user /boot/vmlinux-2.5.28-3
c013d7b4 18805    0.289871    pte_chain_free          /boot/vmlinux-2.5.28-3
c01338cb 16173    0.2493      .text.lock.swap         /boot/vmlinux-2.5.28-3
c01281e0 12649    0.194979    zap_pte_range           /boot/vmlinux-2.5.28-3
c012d30c 11764    0.181337    file_read_actor         /boot/vmlinux-2.5.28-3
c012a230 11738    0.180936    handle_mm_fault         /boot/vmlinux-2.5.28-3
c0135c10 11062    0.170516    free_page_and_swap_cache /boot/vmlinux-2.5.28-3
c0112f4c 10638    0.16398     scheduler_tick          /boot/vmlinux-2.5.28-3
c0129164 10439    0.160913    do_wp_page              /boot/vmlinux-2.5.28-3
c010d0f0 9551     0.147225    timer_interrupt         /boot/vmlinux-2.5.28-3
c0133864 8974     0.138331    lru_cache_del           /boot/vmlinux-2.5.28-3
c01350b8 6378     0.0983143   __alloc_pages           /boot/vmlinux-2.5.28-3
c0140430 6215     0.0958017   get_empty_filp          /boot/vmlinux-2.5.28-3
c01352b8 5968     0.0919943   page_cache_release      /boot/vmlinux-2.5.28-3
c0135324 5119     0.0789073   nr_free_pages           /boot/vmlinux-2.5.28-3
c012ce18 4951     0.0763177   find_get_page           /boot/vmlinux-2.5.28-3
c01406c0 4217     0.0650033   __fput                  /boot/vmlinux-2.5.28-3
c014aaf8 4188     0.0645563   link_path_walk          /boot/vmlinux-2.5.28-3
c014e828 3276     0.0504982   kill_fasync             /boot/vmlinux-2.5.28-3
c013ab78 3085     0.047554    kmap_high               /boot/vmlinux-2.5.28-3
c014da9d 3012     0.0464288   .text.lock.namei        /boot/vmlinux-2.5.28-3
c013b573 2976     0.0458738   .text.lock.highmem      /boot/vmlinux-2.5.28-3
c0120620 2886     0.0444865   update_one_process      /boot/vmlinux-2.5.28-3
c0127e88 2847     0.0438853   copy_page_range         /boot/vmlinux-2.5.28-3
c012a6b0 2721     0.0419431   vm_enough_memory        /boot/vmlinux-2.5.28-3
c0110f34 2678     0.0412803   pgd_alloc               /boot/vmlinux-2.5.28-3
c0154608 2394     0.0369025   __d_lookup              /boot/vmlinux-2.5.28-3
c0107d50 2384     0.0367484   page_fault              /boot/vmlinux-2.5.28-3
c0107b98 2236     0.034467    apic_timer_interrupt    /boot/vmlinux-2.5.28-3
c0111080 2205     0.0339892   pte_alloc_one           /boot/vmlinux-2.5.28-3
c013ead0 2170     0.0334497   dentry_open             /boot/vmlinux-2.5.28-3
c0196650 2074     0.0319699   atomic_dec_and_lock     /boot/vmlinux-2.5.28-3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
