Received: by nf-out-0910.google.com with SMTP id h3so1488965nfh
        for <linux-mm@kvack.org>; Tue, 27 Nov 2007 20:59:48 -0800 (PST)
Message-ID: <733610bd0711272059s5ba0954g5f7bfa7cb0324e02@mail.gmail.com>
Date: Wed, 28 Nov 2007 12:59:47 +0800
From: "=?GB2312?B?0PG2q831?=" <wangeastsun@gmail.com>
Subject: a questio about slab: double free detected in cache
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi,

The environment of a device  is as below:

kernel version is 2.6.14, it is OS distribution kernel Fedora 2. The
file system is ext3. The cpu type is arm9.

I use "yafc" to upload the file from sd card in the device to ftp
server through wifi.

I have tried two times,both of them calls below problem:

1)
*************************************************************
slab: double free detected in cache 'journal_head', objp c0613dc8
kernel BUG at mm/slab.c:2641!
Unable to handle kernel NULL pointer dereference at virtual address 00000000
pgd = c0004000
[00000000] *pgd=00000000
Internal error: Oops: 817 [#1]
Modules linked in: rt73 fxcgpio rtc_pcf8563 keypad gpio_irda hi_sio
tlv320 hi3510_vs adv7179 ohci_hcd tvp5150 hi_i2c hi_gpio
CPU: 0
PC is at __bug+0x44/0x58
LR is at vprintk+0x304/0x368
pc : [<c0026f08>]    lr : [<c003cb6c>]    Not tainted
sp : c2ee9e10  ip : c2ee9d70  fp : c2ee9e1c
r10: 0000000b  r9 : 00000010  r8 : c0613dc8
r7 : c2c382c0  r6 : 00000033  r5 : c2c179f0  r4 : 00000000
r3 : 00000000  r2 : 00000004  r1 : c2ee8000  r0 : 00000001
Flags: nZcv  IRQs off  FIQs on  Mode SVC_32  Segment user
Control: 5317F  Table: 62F60000  DAC: 00000015
Process kjournald (pid: 324, stack limit = 0xc2ee8194)
Stack: (0xc2ee9e10 to 0xc2eea000)
9e00:                                     c2ee9e50 c2ee9e20 c00651cc c0026ed4
9e20: 00000000 c2c3c7d8 c2c3b1c8 00000010 c2c179f0 c2c3c7b8 c2c382c0 00000000
9e40: c2c17a18 c2ee9e78 c2ee9e54 c00653f4 c0065108 c00d8cb8 c2c382c0 c2c3c7b8
9e60: c2f39888 40000013 c2a54268 c2ee9e9c c2ee9e7c c0064f84 c0065358 c2f3988c
9e80: c1e886f8 00000000 00000000 c2a5413c c2ee9eb0 c2ee9ea0 c00d8cb8 c0064efc
9ea0: c2f3988c c2ee9ed4 c2ee9eb4 c00d976c c00d8c7c c194a644 c1e886f8 c2ee8000
9ec0: 0000007d c1d74848 c2ee9ee8 c2ee9ed8 c00d9824 c00d95c4 c1e886f8 c2ee9f80
9ee0: c2ee9eec c00d2da0 c00d97b4 c2ee9f08 c2a54150 00000000 00000000 00000000
9f00: 00000000 c217c8f8 c212d38c 0000511b 3b9aca00 c2ee9f40 c2ee9f24 c0037864
9f20: 00000000 c2ee9f40 c208b5a8 c2a541f0 80000013 c2a541f0 c2a541f0 c2ee8000
9f40: 80000013 c2ee9f64 c2ee9f54 c2a54150 c2a5413c c02fdd58 c2a54150 c2a5413c
9f60: c02fdd58 00000000 c2ee8000 c02fdd58 c2a541c0 c2ee9ff4 c2ee9f84 c00d6d78
9f80: c00d2734 c2ee9f80 00000000 c2f863a0 c005216c c2ee9fa8 c2ee9fa8 00000000
9fa0: c2f863a0 c005216c c2ee9fa8 c2ee9fa8 00000000 00200200 001a6049 4b87ad6e
9fc0: c00d6c4c c2f863a0 c02f96f8 00000000 00000000 00000000 00000000 00000000
9fe0: 00000000 00000000 00000000 c2ee9ff8 c003e304 c00d6c70 00000000 00000000
Backtrace:
[<c0026ec4>] (__bug+0x0/0x58) from [<c00651cc>] (free_block+0xd4/0x19c)
[<c00650f8>] (free_block+0x0/0x19c) from [<c00653f4>]
(cache_flusharray+0xac/0x130)
[<c0065348>] (cache_flusharray+0x0/0x130) from [<c0064f84>]
(kmem_cache_free+0x98/0xb4)
[<c0064eec>] (kmem_cache_free+0x0/0xb4) from [<c00d8cb8>]
(journal_free_journal_head+0x4c/0x58)
 r8 = C2A5413C  r7 = 00000000  r6 = 00000000  r5 = C1E886F8
 r4 = C2F3988C
[<c00d8c6c>] (journal_free_journal_head+0x0/0x58) from [<c00d976c>]
(__journal_remove_journal_head+0x1b8/0x1f0)
 r4 = C2F3988C
[<c00d95b4>] (__journal_remove_journal_head+0x0/0x1f0) from
[<c00d9824>] (journal_remove_journal_head+0x80/0xe0)
 r7 = C1D74848  r6 = 0000007D  r5 = C2EE8000  r4 = C1E886F8
[<c00d97a4>] (journal_remove_journal_head+0x0/0xe0) from [<c00d2da0>]
(journal_commit_transaction+0x67c/0x19f0)
 r4 = C1E886F8
[<c00d2724>] (journal_commit_transaction+0x0/0x19f0) from [<c00d6d78>]
(kjournald+0x118/0x318)
[<c00d6c60>] (kjournald+0x0/0x318) from [<c003e304>] (do_exit+0x0/0xc38)
Code: eb005734 e59f0014 eb005732 e3a03000 (e5833000)
 <6>note: kjournald[324] exited with preempt_count 3
BUG: spinlock cpu recursion on CPU#0, subwayD/328
 lock: c2a54268, .magic: dead4ead, .owner: kjournald/324, .owner_cpu: 0
[<c0027078>] (dump_stack+0x0/0x14) from [<c01329c8>] (spin_bug+0x9c/0xb4)
[<c013292c>] (spin_bug+0x0/0xb4) from [<c0132a48>] (_raw_spin_lock+0x68/0x170)
 r6 = C1FFF50C  r5 = 00000000  r4 = C2A54268
[<c01329e0>] (_raw_spin_lock+0x0/0x170) from [<c023d694>] (_spin_lock+0x20/0x24)
 r8 = C2A54268  r7 = C20893A4  r6 = C1FFF50C  r5 = 00000000
 r4 = C2A54268
[<c023d674>] (_spin_lock+0x0/0x24) from [<c00d1714>]
(journal_dirty_data+0xfc/0x394)
 r4 = C1709D4C
[<c00d1618>] (journal_dirty_data+0x0/0x394) from [<c00bf5b0>]
(ext3_journal_dirty_data+0x1c/0x48)
[<c00bf594>] (ext3_journal_dirty_data+0x0/0x48) from [<c00bf308>]
(walk_page_buffers+0x80/0xb4)
 r6 = C1709D4C  r5 = C1709D4C  r4 = 00001000
[<c00bf288>] (walk_page_buffers+0x0/0xb4) from [<c00bf6d8>]
(ext3_ordered_commit_write+0x74/0x108)
[<c00bf664>] (ext3_ordered_commit_write+0x0/0x108) from [<c005d83c>]
(generic_file_buffered_write+0x418/0x698)
[<c005d428>] (generic_file_buffered_write+0x4/0x698) from [<c005e2d4>]
(__generic_file_aio_write_nolock+0x530/0x560)
[<c005dda4>] (__generic_file_aio_write_nolock+0x0/0x560) from
[<c005e668>] (generic_file_aio_write+0xb0/0x144)
[<c005e5bc>] (generic_file_aio_write+0x4/0x144) from [<c00bdbe0>]
(ext3_file_write+0x34/0xb8)
[<c00bdbb0>] (ext3_file_write+0x4/0xb8) from [<c007dd2c>]
(do_sync_write+0xc4/0x108)
 r7 = 00000C80  r6 = C20B3F78  r5 = C20B3EEC  r4 = C20B3EB0
[<c007dc68>] (do_sync_write+0x0/0x108) from [<c007de2c>] (vfs_write+0xbc/0x178)
[<c007dd70>] (vfs_write+0x0/0x178) from [<c007dfac>] (sys_write+0x4c/0x78)
[<c007df60>] (sys_write+0x0/0x78) from [<c0021de0>] (ret_fast_syscall+0x0/0x2c)
 r8 = C0021F64  r7 = 00000004  r6 = 00000C80  r5 = 000500D0
 r4 = 0000001D
BUG: spinlock lockup on CPU#0, subwayD/328, c2a54268
[<c0027078>] (dump_stack+0x0/0x14) from [<c0132b18>]
(_raw_spin_lock+0x138/0x170)
[<c01329e0>] (_raw_spin_lock+0x0/0x170) from [<c023d694>] (_spin_lock+0x20/0x24)
 r8 = C2A54268  r7 = C20893A4  r6 = C1FFF50C  r5 = 00000000
 r4 = C2A54268
[<c023d674>] (_spin_lock+0x0/0x24) from [<c00d1714>]
(journal_dirty_data+0xfc/0x394)
 r4 = C1709D4C
[<c00d1618>] (journal_dirty_data+0x0/0x394) from [<c00bf5b0>]
(ext3_journal_dirty_data+0x1c/0x48)
[<c00bf594>] (ext3_journal_dirty_data+0x0/0x48) from [<c00bf308>]
(walk_page_buffers+0x80/0xb4)
 r6 = C1709D4C  r5 = C1709D4C  r4 = 00001000
[<c00bf288>] (walk_page_buffers+0x0/0xb4) from [<c00bf6d8>]
(ext3_ordered_commit_write+0x74/0x108)
[<c00bf664>] (ext3_ordered_commit_write+0x0/0x108) from [<c005d83c>]
(generic_file_buffered_write+0x418/0x698)
[<c005d428>] (generic_file_buffered_write+0x4/0x698) from [<c005e2d4>]
(__generic_file_aio_write_nolock+0x530/0x560)
[<c005dda4>] (__generic_file_aio_write_nolock+0x0/0x560) from
[<c005e668>] (generic_file_aio_write+0xb0/0x144)
[<c005e5bc>] (generic_file_aio_write+0x4/0x144) from [<c00bdbe0>]
(ext3_file_write+0x34/0xb8)
[<c00bdbb0>] (ext3_file_write+0x4/0xb8) from [<c007dd2c>]
(do_sync_write+0xc4/0x108)
 r7 = 00000C80  r6 = C20B3F78  r5 = C20B3EEC  r4 = C20B3EB0
[<c007dc68>] (do_sync_write+0x0/0x108) from [<c007de2c>] (vfs_write+0xbc/0x178)
[<c007dd70>] (vfs_write+0x0/0x178) from [<c007dfac>] (sys_write+0x4c/0x78)
[<c007df60>] (sys_write+0x0/0x78) from [<c0021de0>] (ret_fast_syscall+0x0/0x2c)
 r8 = C0021F64  r7 = 00000004  r6 = 00000C80  r5 = 000500D0
 r4 = 0000001D
BUG: soft lockup detected on CPU#0!

Pid: 328, comm:              subwayD
CPU: 0
PC is at _raw_spin_lock+0xbc/0x170
LR is at vprintk+0x31c/0x368
pc : [<c0132a9c>]    lr : [<c003cb84>]    Not tainted
sp : c20b3c14  ip : c20b3b38  fp : c20b3c38
r10: 00000001  r9 : c2a5413c  r8 : 00000000
r7 : c20b2000  r6 : 00000000  r5 : 0159b6c4  r4 : c2a54268
r3 : 00000000  r2 : 04042000  r1 : 00000001  r0 : c0283a34
Flags: nzCv  IRQs on  FIQs on  Mode SVC_32  Segment user
Control: 5317F  Table: 62F60000  DAC: 00000015
[<c0023a48>] (show_regs+0x0/0x4c) from [<c005a914>] (softlockup_tick+0x78/0x9c)
 r4 = 00000000
[<c005a89c>] (softlockup_tick+0x0/0x9c) from [<c0045bc4>]
(do_timer+0x438/0x4b0)
 r5 = C02F96C0  r4 = 00000000
[<c004578c>] (do_timer+0x0/0x4b0) from [<c0026e94>] (timer_tick+0xb4/0xe4)
[<c0026de0>] (timer_tick+0x0/0xe4) from [<c002d908>]
(hisilicon_timer_interrupt+0x40/0x64)
 r6 = C02863DC  r5 = C20B3BCC  r4 = C02863D8
[<c002d8c8>] (hisilicon_timer_interrupt+0x0/0x64) from [<c0022acc>]
(__do_irq+0x54/0x94)
 r6 = 00000000  r5 = 00000000  r4 = C0284C04
[<c0022a78>] (__do_irq+0x0/0x94) from [<c0022d30>] (do_level_IRQ+0x70/0xc8)
 r8 = C20B3BCC  r7 = 00000003  r6 = C20B3BCC  r5 = 00000004
 r4 = C02D5F50
[<c0022cc0>] (do_level_IRQ+0x0/0xc8) from [<c0022ddc>] (asm_do_IRQ+0x54/0x150)
 r6 = 00000001  r5 = C02D5F50  r4 = 00000004
[<c0022d88>] (asm_do_IRQ+0x0/0x150) from [<c00219b8>] (__irq_svc+0x38/0x8c)
[<c01329e0>] (_raw_spin_lock+0x0/0x170) from [<c023d694>] (_spin_lock+0x20/0x24)
 r8 = C2A54268  r7 = C20893A4  r6 = C1FFF50C  r5 = 00000000
 r4 = C2A54268
[<c023d674>] (_spin_lock+0x0/0x24) from [<c00d1714>]
(journal_dirty_data+0xfc/0x394)
 r4 = C1709D4C
[<c00d1618>] (journal_dirty_data+0x0/0x394) from [<c00bf5b0>]
(ext3_journal_dirty_data+0x1c/0x48)
[<c00bf594>] (ext3_journal_dirty_data+0x0/0x48) from [<c00bf308>]
(walk_page_buffers+0x80/0xb4)
 r6 = C1709D4C  r5 = C1709D4C  r4 = 00001000
[<c00bf288>] (walk_page_buffers+0x0/0xb4) from [<c00bf6d8>]
(ext3_ordered_commit_write+0x74/0x108)
[<c00bf664>] (ext3_ordered_commit_write+0x0/0x108) from [<c005d83c>]
(generic_file_buffered_write+0x418/0x698)
[<c005d428>] (generic_file_buffered_write+0x4/0x698) from [<c005e2d4>]
(__generic_file_aio_write_nolock+0x530/0x560)
[<c005dda4>] (__generic_file_aio_write_nolock+0x0/0x560) from
[<c005e668>] (generic_file_aio_write+0xb0/0x144)
[<c005e5bc>] (generic_file_aio_write+0x4/0x144) from [<c00bdbe0>]
(ext3_file_write+0x34/0xb8)
[<c00bdbb0>] (ext3_file_write+0x4/0xb8) from [<c007dd2c>]
(do_sync_write+0xc4/0x108)
 r7 = 00000C80  r6 = C20B3F78  r5 = C20B3EEC  r4 = C20B3EB0
[<c007dc68>] (do_sync_write+0x0/0x108) from [<c007de2c>] (vfs_write+0xbc/0x178)
[<c007dd70>] (vfs_write+0x0/0x178) from [<c007dfac>] (sys_write+0x4c/0x78)
[<c007df60>] (sys_write+0x0/0x78) from [<c0021de0>] (ret_fast_syscall+0x0/0x2c)
 r8 = C0021F64  r7 = 00000004  r6 = 00000C80  r5 = 000500D0
 r4 = 0000001D

*************************************************************
2)+WiFi_Guider-+WiFi_Guider-+WiFi_Guider-+WiFi_Guider-+WiFi_Guider-+WiFi_Guider-+WiFi_Guider-+WiFi_Guider-+WiFi_Guider-+WiFi_Guider-+WiFi_Guider-+WiFi_Guider-+WiFi_Guider-+WiFi_Guider-+WiFi_Guider-+WiFi_Guider-+WiFi_Guider-+WiFi_Guider-+WiFi_Guider-+WiFi_Guider-+WiFi_Guider-slab:
double free detected in cache 'journal_head', objp c0613dc8
kernel BUG at mm/slab.c:2641!
Unable to handle kernel NULL pointer dereference at virtual address 00000000
pgd = c0004000
[00000000] *pgd=00000000
Internal error: Oops: 817 [#1]
Modules linked in: rt73 fxcgpio rtc_pcf8563 keypad gpio_irda hi_sio
tlv320 hi3510_vs adv7179 ohci_hcd tvp5150 hi_i2c hi_gpio
CPU: 0
PC is at __bug+0x44/0x58
LR is at vprintk+0x304/0x368
pc : [<c0026f08>]    lr : [<c003cb6c>]    Not tainted
sp : c2ee1e10  ip : c2ee1d70  fp : c2ee1e1c
r10: 00000004  r9 : 00000010  r8 : c0613dc8
r7 : c2c382c0  r6 : 00000033  r5 : c2c179f0  r4 : 00000000
r3 : 00000000  r2 : 00000004  r1 : c2ee0000  r0 : 00000001
Flags: nZcv  IRQs off  FIQs on  Mode SVC_32  Segment user
Control: 5317F  Table: 62090000  DAC: 00000015
Process kjournald (pid: 322, stack limit = 0xc2ee0194)
Stack: (0xc2ee1e10 to 0xc2ee2000)
1e00:                                     c2ee1e50 c2ee1e20 c00651cc c0026ed4
1e20: 00000000 c2c3c7d8 c2c3b1c8 00000010 c2c179f0 c2c3c7b8 c2c382c0 00000000
1e40: c2c17a18 c2ee1e78 c2ee1e54 c00653f4 c0065108 c00d8cb8 c2c382c0 c2c3c7b8
1e60: c0566248 40000013 c2faf680 c2ee1e9c c2ee1e7c c0064f84 c0065358 c056624c
1e80: c08b1af4 00000000 00000000 c2faf554 c2ee1eb0 c2ee1ea0 c00d8cb8 c0064efc
1ea0: c056624c c2ee1ed4 c2ee1eb4 c00d976c c00d8c7c c2faf680 c08b1af4 c2ee0000
1ec0: 00000000 c21eef08 c2ee1ee8 c2ee1ed8 c00d9824 c00d95c4 c08b1af4 c2ee1f80
1ee0: c2ee1eec c00d2da0 c00d97b4 c2ee1f08 c2faf568 00000000 00000000 00000000
1f00: 00000000 c216e8d8 c1dd314c c02d81ac c2ee0000 c2ee1f9c c2faf608 c2f82960
1f20: 00000000 c2ee1f40 c2081320 c2faf608 20000013 c2faf608 c2faf608 c2ee0000
1f40: 20000013 c2ee1f64 c2ee1f54 c023d88c c0037238 c2ee1fa8 c2faf568 c2faf554
1f60: c02fdd58 00000000 c2ee0000 c02fdd58 c2faf5d8 c2ee1ff4 c2ee1f84 c00d6d78
1f80: c00d2734 c2ee1f80 00000000 c2f82960 c005216c c2ee1fa8 c2ee1fa8 00000000
1fa0: c2f82960 c005216c c2ee1fa8 c2ee1fa8 c02870c4 c030b3b8 000dbaf0 4b87ad6e
1fc0: c00d6c4c c2f82960 c02f96f8 00000000 00000000 00000000 00000000 00000000
1fe0: 00000000 00000000 00000000 c2ee1ff8 c003e304 c00d6c70 e92d40f0 e1a06000
Backtrace:
[<c0026ec4>] (__bug+0x0/0x58) from [<c00651cc>] (free_block+0xd4/0x19c)
[<c00650f8>] (free_block+0x0/0x19c) from [<c00653f4>]
(cache_flusharray+0xac/0x130)
[<c0065348>] (cache_flusharray+0x0/0x130) from [<c0064f84>]
(kmem_cache_free+0x98/0xb4)
[<c0064eec>] (kmem_cache_free+0x0/0xb4) from [<c00d8cb8>]
(journal_free_journal_head+0x4c/0x58)
 r8 = C2FAF554  r7 = 00000000  r6 = 00000000  r5 = C08B1AF4
 r4 = C056624C
[<c00d8c6c>] (journal_free_journal_head+0x0/0x58) from [<c00d976c>]
(__journal_remove_journal_head+0x1b8/0x1f0)
 r4 = C056624C
[<c00d95b4>] (__journal_remove_journal_head+0x0/0x1f0) from
[<c00d9824>] (journal_remove_journal_head+0x80/0xe0)
 r7 = C21EEF08  r6 = 00000000  r5 = C2EE0000  r4 = C08B1AF4
[<c00d97a4>] (journal_remove_journal_head+0x0/0xe0) from [<c00d2da0>]
(journal_commit_transaction+0x67c/0x19f0)
 r4 = C08B1AF4
[<c00d2724>] (journal_commit_transaction+0x0/0x19f0) from [<c00d6d78>]
(kjournald+0x118/0x318)
[<c00d6c60>] (kjournald+0x0/0x318) from [<c003e304>] (do_exit+0x0/0xc38)
Code: eb005734 e59f0014 eb005732 e3a03000 (e5833000)
 <6>note: kjournald[322] exited with preempt_count 3
BUG: spinlock cpu recursion on CPU#0, subwayDD/370
 lock: c2faf680, .magic: dead4ead, .owner: kjournald/322, .owner_cpu: 0
[<c0027078>] (dump_stack+0x0/0x14) from [<c01329c8>] (spin_bug+0x9c/0xb4)
[<c013292c>] (spin_bug+0x0/0xb4) from [<c0132a48>] (_raw_spin_lock+0x68/0x170)
 r6 = C061340C  r5 = 00000000  r4 = C2FAF680
[<c01329e0>] (_raw_spin_lock+0x0/0x170) from [<c023d694>] (_spin_lock+0x20/0x24)
 r8 = C2FAF680  r7 = C22373A4  r6 = C061340C  r5 = 00000000
 r4 = C2FAF680
[<c023d674>] (_spin_lock+0x0/0x24) from [<c00d1714>]
(journal_dirty_data+0xfc/0x394)
 r4 = C097DE78
[<c00d1618>] (journal_dirty_data+0x0/0x394) from [<c00bf5b0>]
(ext3_journal_dirty_data+0x1c/0x48)
[<c00bf594>] (ext3_journal_dirty_data+0x0/0x48) from [<c00bf308>]
(walk_page_buffers+0x80/0xb4)
 r6 = C097DE78  r5 = C097DE78  r4 = 00001000
[<c00bf288>] (walk_page_buffers+0x0/0xb4) from [<c00bf6d8>]
(ext3_ordered_commit_write +0x74/0x108)
[<c00bf664>] (ext3_ordered_commit_write+0x0/0x108) from [<c005d83c>]
(generic_file_buffered_write+0x418/0x698)
[<c005d428>] (generic_file_buffered_write+0x4/0x698) from [<c005e2d4>]
(__generic_file_aio_write_nolock+0x530/0x560)
[<c005dda4>] (__generic_file_aio_write_nolock+0x0/0x560) from
[<c005e668>] (generic_file_aio_write+0xb0/0x144)
[<c005e5bc>] (generic_file_aio_write+0x4/0x144) from [<c00bdbe0>]
(ext3_file_write+0x34/0xb8)
[<c00bdbb0>] (ext3_file_write+0x4/0xb8) from [<c007dd2c>]
(do_sync_write+0xc4/0x108)
 r7 = 00000C80  r6 = C2EABF78  r5 = C2EABEEC  r4 = C2EABEB0
[<c007dc68>] (do_sync_write+0x0/0x108) from [<c007de2c>] (vfs_write+0xbc/0x178)
[<c007dd70>] (vfs_write+0x0/0x178) from [<c007dfac>] (sys_write+0x4c/0x78)
[<c007df60>] (sys_write+0x0/0x78) from [<c0021de0>] (ret_fast_syscall+0x0/0x2c)
 r8 = C0021F64  r7 = 00000004  r6 = 00000C80  r5 = 00051720
 r4 = 0000001D
BUG: spinlock lockup on CPU#0, subwayDD/370, c2faf680
[<c0027078>] (dump_stack+0x0/0x14) from [<c0132b18>]
(_raw_spin_lock+0x138/0x170)
[<c01329e0>] (_raw_spin_lock+0x0/0x170) from [<c023d694>] (_spin_lock+0x20/0x24)
 r8 = C2FAF680  r7 = C22373A4  r6 = C061340C  r5 = 00000000
 r4 = C2FAF680
[<c023d674>] (_spin_lock+0x0/0x24) from [<c00d1714>]
(journal_dirty_data+0xfc/0x394)
 r4 = C097DE78
[<c00d1618>] (journal_dirty_data+0x0/0x394) from [<c00bf5b0>]
(ext3_journal_dirty_data+0x1c/0x48)
[<c00bf594>] (ext3_journal_dirty_data+0x0/0x48) from [<c00bf308>]
(walk_page_buffers+0x80/0xb4)
 r6 = C097DE78  r5 = C097DE78  r4 = 00001000
[<c00bf288>] (walk_page_buffers+0x0/0xb4) from [<c00bf6d8>]
(ext3_ordered_commit_write+0x74/0x108)
[<c00bf664>] (ext3_ordered_commit_write+0x0/0x108) from [<c005d83c>]
(generic_file_buffered_write +0x418/0x698)
[<c005d428>] (generic_file_buffered_write+0x4/0x698) from [<c005e2d4>]
(__generic_file_aio_write_nolock+0x530/0x560)
[<c005dda4>] (__generic_file_aio_write_nolock+0x0/0x560) from
[<c005e668>] (generic_file_aio_write+0xb0/0x144)
[<c005e5bc>] (generic_file_aio_write+0x4/0x144) from [<c00bdbe0>]
(ext3_file_write+0x34/0xb8)
[<c00bdbb0>] (ext3_file_write+0x4/0xb8) from [<c007dd2c>]
(do_sync_write+0xc4/0x108)
 r7 = 00000C80  r6 = C2EABF78  r5 = C2EABEEC  r4 = C2EABEB0
[<c007dc68>] (do_sync_write+0x0/0x108) from [<c007de2c>] (vfs_write+0xbc/0x178)
[<c007dd70>] (vfs_write+0x0/0x178) from [<c007dfac>] (sys_write+0x4c/0x78)
[<c007df60>] (sys_write+0x0/0x78) from [<c0021de0>] (ret_fast_syscall+0x0/0x2c)
 r8 = C0021F64  r7 = 00000004  r6 = 00000C80  r5 = 00051720
 r4 = 0000001D
BUG: soft lockup detected on CPU#0!

Pid: 370, comm:             subwayDD
CPU: 0
PC is at _raw_spin_lock+0xd0/0x170
LR is at vprintk+0x31c/0x368
pc : [<c0132ab0>]    lr : [<c003cb84>]    Not tainted
sp : c2eabc14  ip : c2eabb38  fp : c2eabc38
r10: 00000001  r9 : c2faf554  r8 : 00000000
r7 : c2eaa000  r6 : 00000000  r5 : 01e1f04a  r4 : c2faf680
r3 : 000a4800  r2 : 04042000  r1 : 00000001  r0 : c0283a34
Flags: nZCv  IRQs on  FIQs on  Mode SVC_32  Segment user
Control: 5317F  Table: 62090000  DAC: 00000015
[<c0023a48>] (show_regs+0x0/0x4c) from [<c005a914>] (softlockup_tick+0x78/0x9c)
 r4 = 00000000
[<c005a89c>] (softlockup_tick+0x0/0x9c) from [<c0045bc4>]
(do_timer+0x438/0x4b0)
 r5 = C02F96C0  r4 = 00000000
[<c004578c>] (do_timer+0x0/0x4b0) from [<c0026e94>] (timer_tick+0xb4/0xe4)
[<c0026de0>] (timer_tick+0x0/0xe4) from [<c002d908>]
(hisilicon_timer_interrupt+0x40/0x64)
 r6 = C02863DC  r5 = C2EABBCC  r4 = C02863D8
[<c002d8c8>] (hisilicon_timer_interrupt+0x0 /0x64) from [<c0022acc>]
(__do_irq+0x54/0x94)
 r6 = 00000000  r5 = 00000000  r4 = C0284C04
[<c0022a78>] (__do_irq+0x0/0x94) from [<c0022d30>] (do_level_IRQ+0x70/0xc8)
 r8 = C2EABBCC  r7 = 00000003  r6 = C2EABBCC  r5 = 00000004
 r4 = C02D5F50
[<c0022cc0>] (do_level_IRQ+0x0/0xc8) from [<c0022ddc>] (asm_do_IRQ+0x54/0x150)
 r6 = 00000001  r5 = C02D5F50  r4 = 00000004
[<c0022d88>] (asm_do_IRQ+0x0/0x150) from [<c00219b8>] (__irq_svc+0x38/0x8c)
[<c01329e0>] (_raw_spin_lock+0x0/0x170) from [<c023d694>] (_spin_lock+0x20/0x24)
 r8 = C2FAF680  r7 = C22373A4  r6 = C061340C  r5 = 00000000
 r4 = C2FAF680
[<c023d674>] (_spin_lock+0x0/0x24) from [<c00d1714>]
(journal_dirty_data+0xfc/0x394)
 r4 = C097DE78
[<c00d1618>] (journal_dirty_data+0x0/0x394) from [<c00bf5b0>]
(ext3_journal_dirty_data+0x1c/0x48)
[<c00bf594>] (ext3_journal_dirty_data+0x0/0x48) from [<c00bf308>]
(walk_page_buffers+0x80/0xb4)
 r6 = C097DE78  r5 = C097DE78  r4 = 00001000
[<c00bf288>] (walk_page_buffers+0x0/0xb4) from [<c00bf6d8>]
(ext3_ordered_commit_write+0x74/0x108)
[<c00bf664>] (ext3_ordered_commit_write+0x0/0x108) from [<c005d83c>]
(generic_file_buffered_write+0x418/0x698)
[<c005d428>] (generic_file_buffered_write+0x4/0x698) from [<c005e2d4>]
(__generic_file_aio_write_nolock+0x530/0x560)
[<c005dda4>] (__generic_file_aio_write_nolock+0x0/0x560) from
[<c005e668>] (generic_file_aio_write+0xb0/0x144)
[<c005e5bc>] (generic_file_aio_write+0x4/0x144) from [<c00bdbe0>]
(ext3_file_write+0x34/0xb8)
[<c00bdbb0>] (ext3_file_write+0x4/0xb8) from [<c007dd2c>]
(do_sync_write+0xc4/0x108)
 r7 = 00000C80  r6 = C2EABF78  r5 = C2EABEEC  r4 = C2EABEB0
[<c007dc68>] (do_sync_write+0x0/0x108) from [<c007de2c>] (vfs_write+0xbc/0x178)
[<c007dd70>] (vfs_write+0x0/0x178) from [<c007dfac>] (sys_write+0x4c/0x78)
[<c007df60>] (sys_write+0x0/0x78) from [<c0021de0>] (ret_fast_syscall+0x0/0x2c)
 r8 = C0021F64  r7 = 00000004  r6 = 00000C80  r5 = 00051720
 r4 = 0000001D

Could you kindly enough tell me what is the problem and how to solve it?

Thanks very much.

Regards

Kurt

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
