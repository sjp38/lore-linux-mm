Received: from wli by holomorphy with local (Exim 3.34 #1 (Debian))
	id 17s07B-0004Zd-00
	for <linux-mm@kvack.org>; Thu, 19 Sep 2002 05:09:01 -0700
Date: Thu, 19 Sep 2002 05:09:01 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: dbench 512 oprofile
Message-ID: <20020919120901.GL28202@holomorphy.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Description: brief message
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Of 2.5.36-mm1, taken on a 32x NUMA-Q with 32GB of RAM:

c01053a4 14040139 35.542      default_idle
c0114ab8 4436882  11.2318     load_balance
c015c5c6 4243413  10.742      .text.lock.dcache
c01317f4 2229431  5.64371     generic_file_write_nolock
c0130d10 2182906  5.52593     file_read_actor
c0114f30 2126191  5.38236     scheduler_tick
c0154b83 1905648  4.82407     .text.lock.namei
c011749d 1344623  3.40386     .text.lock.sched
c019f8ab 1102566  2.7911      .text.lock.dec_and_lock
c01066a8 612167   1.54968     .text.lock.semaphore
c015ba5c 440889   1.11609     d_lookup
c013f81c 314222   0.79544     blk_queue_bounce
c0111798 310317   0.785554    smp_apic_timer_interrupt
c013fac4 228103   0.577433    .text.lock.highmem
c01523b8 206811   0.523533    path_lookup
c0115274 164177   0.415607    do_schedule
c019f830 143365   0.362922    atomic_dec_and_lock
c0114628 136075   0.344468    try_to_wake_up
c01062dc 125245   0.317052    __down
c010d9d8 121864   0.308494    timer_interrupt
c015ae30 114653   0.290239    prune_dcache
c0144e00 102093   0.258444    generic_file_llseek
c015b714 83273    0.210802    d_instantiate

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
