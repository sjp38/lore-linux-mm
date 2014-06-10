Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f53.google.com (mail-qa0-f53.google.com [209.85.216.53])
	by kanga.kvack.org (Postfix) with ESMTP id CD65B6B00D6
	for <linux-mm@kvack.org>; Mon,  9 Jun 2014 22:31:51 -0400 (EDT)
Received: by mail-qa0-f53.google.com with SMTP id k15so8414573qaq.12
        for <linux-mm@kvack.org>; Mon, 09 Jun 2014 19:31:51 -0700 (PDT)
Received: from cdptpa-oedge-vip.email.rr.com (cdptpa-outbound-snat.email.rr.com. [107.14.166.226])
        by mx.google.com with ESMTP id 107si25118623qgn.94.2014.06.09.19.31.50
        for <linux-mm@kvack.org>;
        Mon, 09 Jun 2014 19:31:51 -0700 (PDT)
Message-ID: <53966E16.6010104@ubuntu.com>
Date: Mon, 09 Jun 2014 22:31:50 -0400
From: Phillip Susi <psusi@ubuntu.com>
MIME-Version: 1.0
Subject: kernelcore not working correctly
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA512

I booted with kernelcore=1g and it appears that ZONE_MOVABLE is only using 760mb out of 4g and DMA32 is continuing to use much more than the specified 1g:

root@faldara:~# cat /proc/zoneinfo
Node 0, zone      DMA
~  pages free     3356
~        min      66
~        low      82
~        high     99
~        scanned  0
~        spanned  4095
~        present  3996
~        managed  3975
~    nr_free_pages 3356
~    nr_alloc_batch 17
~    nr_inactive_anon 0
~    nr_active_anon 0
~    nr_inactive_file 1
~    nr_active_file 1
~    nr_unevictable 0
~    nr_mlock     0
~    nr_anon_pages 0
~    nr_mapped    0
~    nr_file_pages 2
~    nr_dirty     0
~    nr_writeback 0
~    nr_slab_reclaimable 5
~    nr_slab_unreclaimable 13
~    nr_page_table_pages 8
~    nr_kernel_stack 2
~    nr_unstable  0
~    nr_bounce    0
~    nr_vmscan_write 0
~    nr_vmscan_immediate_reclaim 0
~    nr_writeback_temp 0
~    nr_isolated_anon 0
~    nr_isolated_file 0
~    nr_shmem     0
~    nr_dirtied   19
~    nr_written   19
~    numa_hit     215007
~    numa_miss    0
~    numa_foreign 0
~    numa_interleave 0
~    numa_local   215007
~    numa_other   0
~    nr_anon_transparent_hugepages 0
~    nr_free_cma  0
~        protection: (0, 3217, 3217, 3912)
~  pagesets
~    cpu: 0
~              count: 0
~              high:  0
~              batch: 1
~  vm stats threshold: 6
~    cpu: 1
~              count: 0
~              high:  0
~              batch: 1
~  vm stats threshold: 6
~    cpu: 2
~              count: 0
~              high:  0
~              batch: 1
~  vm stats threshold: 6
~    cpu: 3
~              count: 0
~              high:  0
~              batch: 1
~  vm stats threshold: 6
~  all_unreclaimable: 0
~  start_pfn:         1
~  inactive_ratio:    1
Node 0, zone    DMA32
~  pages free     110515
~        min      13842
~        low      17302
~        high     20763
~        scanned  0
~        spanned  1044480
~        present  844086
~        managed  824348
~    nr_free_pages 110515
~    nr_alloc_batch 2969
~    nr_inactive_anon 104044
~    nr_active_anon 107653
~    nr_inactive_file 164341
~    nr_active_file 144652
~    nr_unevictable 4
~    nr_mlock     4
~    nr_anon_pages 200317
~    nr_mapped    17257
~    nr_file_pages 326892
~    nr_dirty     5
~    nr_writeback 0
~    nr_slab_reclaimable 11832
~    nr_slab_unreclaimable 9053
~    nr_page_table_pages 6865
~    nr_kernel_stack 449
~    nr_unstable  0
~    nr_bounce    0
~    nr_vmscan_write 127863
~    nr_vmscan_immediate_reclaim 5648
~    nr_writeback_temp 0
~    nr_isolated_anon 0
~    nr_isolated_file 0
~    nr_shmem     1409
~    nr_dirtied   10448485
~    nr_written   10212199
~    numa_hit     234775891
~    numa_miss    0
~    numa_foreign 0
~    numa_interleave 0
~    numa_local   234775891
~    numa_other   0
~    nr_anon_transparent_hugepages 47
~    nr_free_cma  0
~        protection: (0, 0, 0, 694)
~  pagesets
~    cpu: 0
~              count: 80
~              high:  186
~              batch: 31
~  vm stats threshold: 36
~    cpu: 1
~              count: 50
~              high:  186
~              batch: 31
~  vm stats threshold: 36
~    cpu: 2
~              count: 34
~              high:  186
~              batch: 31
~  vm stats threshold: 36
~    cpu: 3
~              count: 125
~              high:  186
~              batch: 31
~  vm stats threshold: 36
~  all_unreclaimable: 0
~  start_pfn:         4096
~  inactive_ratio:    5
Node 0, zone  Movable
~  pages free     7013
~        min      2986
~        low      3732
~        high     4479
~        scanned  0
~        spanned  194560
~        present  194560
~        managed  177867
~    nr_free_pages 7013
~    nr_alloc_batch 456
~    nr_inactive_anon 13942
~    nr_active_anon 14578
~    nr_inactive_file 23643
~    nr_active_file 23600
~    nr_unevictable 0
~    nr_mlock     0
~    nr_anon_pages 25538
~    nr_mapped    3257
~    nr_file_pages 50856
~    nr_dirty     0
~    nr_writeback 0
~    nr_slab_reclaimable 0
~    nr_slab_unreclaimable 0
~    nr_page_table_pages 0
~    nr_kernel_stack 0
~    nr_unstable  0
~    nr_bounce    0
~    nr_vmscan_write 190596
~    nr_vmscan_immediate_reclaim 3187
~    nr_writeback_temp 0
~    nr_isolated_anon 0
~    nr_isolated_file 0
~    nr_shmem     78
~    nr_dirtied   1785494
~    nr_written   1833870
~    numa_hit     22890304
~    numa_miss    0
~    numa_foreign 0
~    numa_interleave 0
~    numa_local   22890304
~    numa_other   0
~    nr_anon_transparent_hugepages 10
~    nr_free_cma  0
~        protection: (0, 0, 0, 0)
~  pagesets
~    cpu: 0
~              count: 22
~              high:  186
~              batch: 31
~  vm stats threshold: 24
~    cpu: 1
~              count: 21
~              high:  186
~              batch: 31
~  vm stats threshold: 24
~    cpu: 2
~              count: 130
~              high:  186
~              batch: 31
~  vm stats threshold: 24
~    cpu: 3
~              count: 142
~              high:  186
~              batch: 31
~  vm stats threshold: 24
~  all_unreclaimable: 0
~  start_pfn:         1048576
~  inactive_ratio:    1
root@faldara:~# cat /proc/cmdline
BOOT_IMAGE=/boot/vmlinuz-3.13.0-29-generic root=/dev/mapper/faldara-trusty ro kernelcore=1g quiet splash nomdmonddf nomdmonisw vt.handoff=7
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iQEcBAEBCgAGBQJTlm4WAAoJEI5FoCIzSKrwJkMH/0eB4Xqi2kf5LrDQSnqJa8RP
ONDl0O+vywvVwXS2GYZatz+WgYySrqwjKYAj8bLCvu9f5Oy9l1Sy9S9Cw5dmaxwV
e7f+2DsJ4NWHDH/P8j4bzLauDyfBoKuifx5eoIc7LdPLCFSnLRUc612172OfNMHr
0bRe+Rc3PeFi2DGy7DyN48Vm+PZwvwUbsXZFYO4LA1YPzfVstP3BL5wEIyS7za7x
zeediEB1UizTa1pl4OD/EBcrOZ3He4SeOgz9msisOUMwRx9wNDJlTGp40tbscSs6
716cpY69jMGuC81H7SkzNBqJPIJFz4D1ezvNfvdfU5y2vyI2nxwdtHEdRIiZjYM=
=P4eq
-----END PGP SIGNATURE-----

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
