Received: from wli by holomorphy with local (Exim 3.34 #1 (Debian))
	id 17s1Jg-0005OA-00
	for <linux-mm@kvack.org>; Thu, 19 Sep 2002 06:26:00 -0700
Date: Thu, 19 Sep 2002 06:26:00 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: dbench 512 oprofile
Message-ID: <20020919132600.GM28202@holomorphy.com>
References: <20020919120901.GL28202@holomorphy.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Description: brief message
Content-Disposition: inline
In-Reply-To: <20020919120901.GL28202@holomorphy.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Sep 19, 2002 at 05:09:01AM -0700, William Lee Irwin III wrote:
> Of 2.5.36-mm1, taken on a 32x NUMA-Q with 32GB of RAM:

rerun with akpm's patch to remove section directives from lock spinloops:

c01053a4 31781009 38.3441     default_idle
c0114968 13184373 15.9071     load_balance
c0114de0 6545861  7.89765     scheduler_tick
c0151718 4514372  5.44664     path_lookup
c015ac4c 3314721  3.99924     d_lookup
c0130560 3153290  3.80448     file_read_actor
c0131044 2816477  3.39811     generic_file_write_nolock
c015a8e4 1980809  2.38987     d_instantiate
c019e1b0 1959187  2.36378     atomic_dec_and_lock
c0111668 1447604  1.74655     smp_apic_timer_interrupt
c0159fc0 1291884  1.55867     prune_dcache
c015a714 1089696  1.31473     d_alloc
c01062cc 1030194  1.24294     __down
c015b0dc 625279   0.754405    d_rehash
c013edac 554017   0.668427    blk_queue_bounce
c0115128 508229   0.613183    do_schedule
c01144c8 441818   0.533058    try_to_wake_up
c010d8f8 403607   0.486956    timer_interrupt
c01229a4 333023   0.401796    update_one_process
c015af70 322781   0.389439    d_delete
c01508a0 248442   0.299748    do_lookup
c01155f4 213738   0.257877    __wake_up
c013e63c 185472   0.223774    kmap_high

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
