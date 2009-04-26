Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 1B7466B003D
	for <linux-mm@kvack.org>; Sun, 26 Apr 2009 06:22:13 -0400 (EDT)
From: soho@paralax.org
Subject: ------------[ cut here ]------------
Date: Sun, 26 Apr 2009 13:22:29 +0300
MIME-Version: 1.0
Content-Type: text/plain;
  charset="windows-1251"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200904261322.29788.soho@paralax.org>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, inux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

------------[ cut here ]------------
kernel BUG at mm/page_alloc.c:1109!
invalid opcode: 0000 [#1] SMP
last sysfs file: /sys/module/ip_tables/initstate
CPU 0
Modules linked in: ipv6 xt_state iptable_nat nf_nat 
nf_conntrack_ipv4 nf_conntrack nf_defrag_ipv4 iptable_mangle 
xt_MARK xt_tcpudp iptable_raw iptable_filter ip_tables x_tables 
parport_pc parport nvidia(P) firewire_ohci firewire_core 
snd_hda_intel ohci1394 uhci_hcd ieee1394 atl1 ehci_hcd rtc_cmos 
rtc_core 8139too e100 sg i2c_core snd_hwdep rtc_lib mii
Pid: 18044, comm: mrtg Tainted: P           2.6.28.7 #1
RIP: 0010:[<ffffffff8029b26b>]  [<ffffffff8029b26b>] 
get_page_from_freelist+0x5fb/0x620
RSP: 0000:ffff8800b8d0fa58  EFLAGS: 00010202
RAX: 0000000000000001 RBX: ffffe2000286cb50 RCX: 
0000000000001000
RDX: 0000000000000000 RSI: ffffe2000286cb50 RDI: 
ffffffff80701140
RBP: ffff8800b8d0fb28 R08: 00000000000b8cc6 R09: 
0000000000000000
R10: 0000000000000000 R11: 0000000000000001 R12: 
ffff8801367f8d00
R13: ffffffff80701140 R14: 0000000000000000 R15: 
0000000000000246
FS:  00007f8c771606f0(0000) GS:ffffffff807f1000(0000) 
knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 00000000010009e8 CR3: 00000000b8e53000 CR4: 
00000000000006e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 
0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 
0000000000000400
Process mrtg (pid: 18044, threadinfo ffff8800b8d0e000, task 
ffff8801367f8d00)
Stack:
 ffff880000000002 0000000080701380 ffffffff807b99e0 
0000000000000001
 0000000180701140 0000000000000000 0000000000000000 
0000000000000040
 0000004400000000 0000000000000002 0000000000000000 
000284d08029b1ad
Call Trace:
 [<ffffffff8029b473>] __alloc_pages_internal+0xe3/0x4f0
 [<ffffffff8023390e>] pte_alloc_one+0x1e/0x50
 [<ffffffff802a850a>] __pte_alloc+0x2a/0x100
 [<ffffffff802a87cc>] handle_mm_fault+0x1ec/0x950
 [<ffffffff802e0121>] ? mntput_no_expire+0x31/0x150
 [<ffffffff80593547>] do_page_fault+0x307/0xcd0
 [<ffffffff802969cf>] ? generic_file_aio_read+0x2df/0x690
 [<ffffffff802c7491>] ? do_sync_read+0xf1/0x140
 [<ffffffff802adbf5>] ? vma_adjust+0x265/0x4e0
 [<ffffffff8025f9d0>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff802ae55a>] ? vma_merge+0x1aa/0x290
 [<ffffffff8022c529>] ? default_spin_lock_flags+0x9/0x10
 [<ffffffff802c8139>] ? vfs_read+0x129/0x180
 [<ffffffff80590bea>] error_exit+0x0/0x70
Code: 25 10 00 00 00 48 63 80 48 e0 ff ff a9 00 ff ff 0f 0f 84 ff fe ff ff 
0f 0b eb fe 48 89 df e8 cd e5 ff ff 48 8b 0b e9 41 fd ff ff <0f> 0b eb 
fe be 6e 00 00 00 48 c7 c7 44 3b 64 80 e8 b0 ce fa ff
RIP  [<ffffffff8029b26b>] get_page_from_freelist+0x5fb/0x620
 RSP <ffff8800b8d0fa58>
---[ end trace bd83db21a080c00f ]---
***********************************
root@darkness:~# uname -a
Linux darkness 2.6.28.7 #1 SMP Tue Apr 14 00:37:44 EEST 2009 
x86_64 Intel(R) Core(TM)2 Duo CPU     E8200  @ 2.66GHz 
GenuineIntel GNU/Linux
root@darkness:~# gcc -v
Reading specs from /usr/lib64/gcc/x86_64-slamd64-linux/4.3.3/specs
Target: x86_64-slamd64-linux
Configured with: ../gcc-4.3.3/configure --prefix=/usr --
libdir=/usr/lib64 --enable-shared --enable-bootstrap --enable-
languages=ada,c,c++,fortran,java,objc --enable-threads=posix --
enable-checking=release --with-system-zlib --disable-libunwind-
exceptions --enable-__cxa_atexit --with-gnu-ld --verbose --
target=x86_64-slamd64-linux --build=x86_64-slamd64-linux --
host=x86_64-slamd64-linux
Thread model: posix
gcc version 4.3.3 (GCC)

-- 
In God we Trust (all others must submit a X.509 certificate)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
