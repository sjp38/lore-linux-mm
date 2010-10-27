Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 435C26B0071
	for <linux-mm@kvack.org>; Tue, 26 Oct 2010 23:55:51 -0400 (EDT)
Date: Tue, 26 Oct 2010 23:55:44 -0400 (EDT)
From: caiqian@redhat.com
Message-ID: <980303336.519221288151744899.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
In-Reply-To: <314680146.519081288151589117.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
Subject: inode scaling series broke zram
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm <linux-mm@kvack.org>
Cc: npiggin <npiggin@kernel.dk>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

After applied the inode scaling series (http://lkml.org/lkml/2010/10/19/15) on top of linus's tree, "modprobe zram" threw those warnings,

zram: module is from the staging directory, the quality is unknown, you have been warned.
zram: num_devices not specified. Using default: 1
zram: Creating 1 devices ...
------------[ cut here ]------------
WARNING: at lib/list_debug.c:26 __list_add+0x6d/0xa0()
Hardware name: KVM
list_add corruption. next->prev should be prev (ffffffff81a636a0), but was (null). (next=ffff88020a5c1950).
Modules linked in: zram(C+) veth snd_seq_dummy tun autofs4 sunrpc ipt_REJECT nf_conntrack_ipv4 nf_defrag_ipv4 iptable_filter ip_tables ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6 xt_state nf_conntrack ip6table_filter ip6_tables ipv6 dm_mirror dm_region_hash dm_log virtio_balloon pcspkr snd_intel8x0 snd_ac97_codec ac97_bus snd_seq snd_seq_device snd_pcm snd_timer snd soundcore snd_page_alloc 8139too 8139cp mii i2c_piix4 i2c_core sg ext4 mbcache jbd2 floppy virtio_blk sd_mod crc_t10dif virtio_pci virtio_ring virtio pata_acpi ata_generic ata_piix dm_mod [last unloaded: speedstep_lib]
Pid: 10267, comm: modprobe Tainted: G        WC  2.6.36vfs+ #2
Call Trace:
 [<ffffffff81060eef>] warn_slowpath_common+0x7f/0xc0
 [<ffffffff81060fe6>] warn_slowpath_fmt+0x46/0x50
 [<ffffffff812300cd>] __list_add+0x6d/0xa0
 [<ffffffffa0067000>] ? zram_init+0x0/0x27e [zram]
 [<ffffffff81234256>] __percpu_counter_init+0x56/0x70
 [<ffffffff8111439a>] bdi_init+0x10a/0x190
 [<ffffffffa0067000>] ? zram_init+0x0/0x27e [zram]
 [<ffffffff81207629>] blk_alloc_queue_node+0x79/0x190
 [<ffffffff81207753>] blk_alloc_queue+0x13/0x20
 [<ffffffffa00670f2>] zram_init+0xf2/0x27e [zram]
 [<ffffffff81002053>] do_one_initcall+0x43/0x190
 [<ffffffff8109e6fb>] sys_init_module+0xbb/0x200
 [<ffffffff8100b0b2>] system_call_fastpath+0x16/0x1b
---[ end trace 84534d674448c5db ]---
zram: Invalid ioctl 21297

CAI Qian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
