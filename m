Date: Mon, 9 Oct 2000 10:26:33 +0200 (CEST)
From: Richard Guenther <richard.guenther@student.uni-tuebingen.de>
Subject: [OOPS][BUG] with 2.4.0-test9
Message-ID: <Pine.LNX.4.21.0010091022400.905-100000@fs1.dekanat.physik.uni-tuebingen.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Linux Kernel List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Hi!

The following BUG related oopses caused my machine to die (well, X didnt
survive...) while just compiling a little program. I dont know if these
issues are fixed yet within one of the floating patches, so here goes the
report (dmesg stripped a little).

Richard.

--
Richard Guenther <richard.guenther@student.uni-tuebingen.de>
WWW: http://www.anatom.uni-tuebingen.de/~richi/
The GLAME Project: http://www.glame.de/


Oct  7 11:19:40 localhost kernel: Linux version 2.4.0-test9 (root@mickey) (gcc version 2.95.2 20000220 (Debian GNU/Linux)) #15 Mit Okt 4 19:23:28 CEST 2000
Oct  7 11:19:40 localhost kernel: On node 0 totalpages: 8192
Oct  7 11:19:40 localhost kernel: zone(0): 4096 pages.
Oct  7 11:19:40 localhost kernel: zone(1): 4096 pages.
Oct  7 11:19:40 localhost kernel: zone(2): 0 pages.
Oct  7 11:19:40 localhost kernel: Initializing CPU#0
Oct  7 11:19:40 localhost kernel: Detected 99.475 MHz processor.
Oct  7 11:19:40 localhost kernel: Memory: 30304k/32768k available (1059k kernel code, 2080k reserved, 81k data, 188k init, 0k highmem)
Oct  7 11:19:40 localhost kernel: Dentry-cache hash table entries: 4096 (order: 3, 32768 bytes)
Oct  7 11:19:40 localhost kernel: Buffer-cache hash table entries: 1024 (order: 0, 4096 bytes)
Oct  7 11:19:40 localhost kernel: Page-cache hash table entries: 8192 (order: 3, 32768 bytes)
Oct  7 11:19:40 localhost kernel: Inode-cache hash table entries: 2048 (order: 2, 16384 bytes)
Oct  7 11:19:40 localhost kernel: CPU: Intel Pentium 75 - 200 stepping 05
Oct  7 11:19:40 localhost kernel: Linux video capture interface: v1.00
Oct  7 11:19:40 localhost kernel: Uniform Multi-Platform E-IDE driver Revision: 6.31
Oct  7 11:19:40 localhost kernel: ide: Assuming 33MHz system bus speed for PIO modes; override with idebus=xx
Oct  7 11:19:40 localhost kernel: PIIX: IDE controller on PCI bus 00 dev 38
Oct  7 11:19:40 localhost kernel: PIIX: chipset revision 2
Oct  7 11:19:40 localhost kernel: Real Time Clock Driver v1.10c
Oct  7 11:19:40 localhost kernel: SCSI subsystem driver Revision: 1.00
Oct  7 11:19:40 localhost kernel: sym53c8xx: at PCI bus 0, device 9, function 0
Oct  7 11:19:40 localhost kernel: Soundblaster audio driver Copyright (C) by Hannu Savolainen 1993-1996
Oct  7 11:19:40 localhost kernel: <Sound Blaster 16 (4.13)> at 0x220 irq 5 dma 1,5
Oct  7 11:19:40 localhost kernel: Adding Swap: 98780k swap-space (priority -1)
Oct  7 11:39:38 localhost -- MARK --
Oct  7 11:50:47 localhost kernel: kernel BUG at page_alloc.c:91!
Oct  7 11:50:47 localhost kernel: invalid operand: 0000
Oct  7 11:50:47 localhost kernel: CPU:    0
Oct  7 11:50:47 localhost kernel: EIP:    0010:[__free_pages_ok+73/892]
Oct  7 11:50:47 localhost kernel: EFLAGS: 00010286
Oct  7 11:50:47 localhost kernel: eax: 0000001f   ebx: c1002a90   ecx: c10a4000   edx: 00000000
Oct  7 11:50:47 localhost kernel: esi: c1002aac   edi: 00000000   ebp: 0000002c   esp: c10a5f64
Oct  7 11:50:47 localhost kernel: ds: 0018   es: 0018   ss: 0018
Oct  7 11:50:47 localhost kernel: Process kswapd (pid: 2, stackpage=c10a5000)
Oct  7 11:50:47 localhost kernel: Stack: c01d4877 c01d4a65 0000005b c1002a90 c1002aac 000000ce 0000002c 000000ce 
Oct  7 11:50:47 localhost kernel:        0000002b 00000000 00000003 c0126042 c01278cb c0126229 00000000 00000004 
Oct  7 11:50:47 localhost kernel:        00000000 00000000 00000000 00000004 00000000 00000000 c0126870 00000004 
Oct  7 11:50:47 localhost kernel: Call Trace: [tvecs+8671/55752] [tvecs+9165/55752] [page_launder+674/1888] [__free_pages+19/20] [page_launder+1161/1888] [do_try_to_free_pages+52/128] [tvecs+7999/55752] 
Oct  7 11:50:47 localhost kernel:        [kswapd+115/288] [kernel_thread+40/56] 
Oct  7 11:50:47 localhost kernel: Code: 0f 0b 83 c4 0c 89 f6 89 da 2b 15 f8 89 26 c0 89 d0 c1 e0 04 
Oct  7 11:50:51 localhost kernel: kernel BUG at vmscan.c:538!
Oct  7 11:50:51 localhost kernel: invalid operand: 0000
Oct  7 11:50:51 localhost kernel: CPU:    0
Oct  7 11:50:51 localhost kernel: EIP:    0010:[reclaim_page+897/980]
Oct  7 11:50:51 localhost kernel: EFLAGS: 00010282
Oct  7 11:50:51 localhost kernel: eax: 0000001c   ebx: c1002aac   ecx: c1636000   edx: 00000010
Oct  7 11:50:51 localhost kernel: esi: c1002a90   edi: 00000000   ebp: 00000040   esp: c1637e3c
Oct  7 11:50:51 localhost kernel: ds: 0018   es: 0018   ss: 0018
Oct  7 11:50:51 localhost kernel: Process cc1 (pid: 2614, stackpage=c1637000)
Oct  7 11:50:51 localhost kernel: Stack: c01d4277 c01d4456 0000021a c020bb20 c020bdb4 00000000 00000000 c0127548 
Oct  7 11:50:51 localhost kernel:        c020bb20 00000000 c020bdb8 00000001 00000000 c0127702 c020bdac 00000000 
Oct  7 11:50:51 localhost kernel:        00000000 00000001 00001000 c03a7d60 00000001 c04fe080 0007a746 00000005 
Oct  7 11:50:51 localhost kernel: Call Trace: [tvecs+7135/55752] [tvecs+7614/55752] [__alloc_pages_limit+124/172] [__alloc_pages+394/756] [do_anonymous_page+57/160] [do_no_page+48/192] [handle_mm_fault+232/340] 
Oct  7 11:50:51 localhost kernel:        [do_page_fault+299/976] [merge_segments+324/364] [do_brk+267/316] [sys_brk+180/216] [error_code+44/64] 
Oct  7 11:50:51 localhost kernel: Code: 0f 0b 83 c4 0c 31 c0 0f b3 46 18 8d 4e 28 8d 46 2c 39 46 2c 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
