Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 61A576B007E
	for <linux-mm@kvack.org>; Wed, 17 Jun 2009 08:04:48 -0400 (EDT)
Date: Wed, 17 Jun 2009 08:04:52 -0400
From: Bart Trojanowski <bart@jukie.net>
Subject: Re: [v2.6.30 nfs+fscache] BUG: unable to handle kernel NULL
	pointer dereference at 0000000000000078
Message-ID: <20090617120451.GF30951@jukie.net>
References: <20090615123658.GC4721@jukie.net> <20090613182721.GA24072@jukie.net> <25357.1245068384@redhat.com> <25124.1245074627@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <25124.1245074627@redhat.com>
Sender: owner-linux-mm@kvack.org
To: David Howells <dhowells@redhat.com>, linux-kernel@vger.kernel.org
Cc: linux-cachefs@redhat.com, linux-nfs@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi David,

I still owe you a test with cachefilesd caching to ext3 (not xfs), I'll
have to free up some space on lvm to make a new volume.

I just saw another issue with fscache; setup is the same as in previous
emails.

BUG: unable to handle kernel NULL pointer dereference at 0000000000000078
IP: [<ffffffffa00e8cb6>] fscache_object_slow_work_execute+0x44c/0x814 [fscache]
PGD 396ef8067 PUD 4057a6067 PMD 0 
Oops: 0002 [#1] SMP 
last sysfs file: /sys/block/md1/size
CPU 7 
Modules linked in: iptable_filter ip_tables x_tables tun virtio_rng virtio_pci virtio_ring virtio_net virtio_console virtio_blk virtio nfs lockd nfs_acl auth_rpcgss sunrpc kvm_amd kvm cachefiles fscache cpufreq_userspace cpufreq_powersave cpufreq_conservative ipv6 bridge stp ext2 mbcache loop pcspkr psmouse ata_generic pata_acpi rtc_cmos rtc_core rtc_lib button
Pid: 16705, comm: kslowd Not tainted 2.6.30-kvm3-dirty #4 empty
RIP: 0010:[<ffffffffa00e8cb6>]  [<ffffffffa00e8cb6>] fscache_object_slow_work_execute+0x44c/0x814 [fscache]
RSP: 0018:ffff88037b2bde50  EFLAGS: 00010206
RAX: 0000000000000078 RBX: ffff88042d8f5de0 RCX: 00000000ffffffff
RDX: ffffffff805a21a3 RSI: ffff88042d8f5df8 RDI: 0000000000000246
RBP: ffff88037b2bdea0 R08: 0000000000000002 R09: ffffffffa00e8ca3
R10: ffffffffa00fa6e0 R11: ffffffff8023fcf9 R12: 0000000000000101
R13: ffff88042d8f5e78 R14: ffff88042d8f5dc0 R15: ffff88042d8f5e30
FS:  00007f1fcfaaa6e0(0000) GS:ffffc20000cda000(0000) knlGS:0000000000000000
CS:  0010 DS: 0018 ES: 0018 CR0: 000000008005003b
CR2: 0000000000000078 CR3: 0000000375cc0000 CR4: 00000000000006e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process kslowd (pid: 16705, threadinfo ffff88037b2bc000, task ffff880407d50000)
Stack:
 ffffffff807beae0 0000000103bb5248 ffffffff807beae0 0000000000000101
 ffff88037b2bde80 ffff88042d8f5e78 0000000000000101 0000000000000032
 0000000000000064 ffff88037b2bdec0 ffff88037b2bdf20 ffffffff802a4166
Call Trace:
 [<ffffffff802a4166>] slow_work_thread+0x278/0x43a
 [<ffffffff8025a31b>] ? autoremove_wake_function+0x0/0x3d
 [<ffffffff802a3eee>] ? slow_work_thread+0x0/0x43a
 [<ffffffff802a3eee>] ? slow_work_thread+0x0/0x43a
 [<ffffffff80259f0c>] kthread+0x5b/0x88
 [<ffffffff8020ce8a>] child_rip+0xa/0x20
 [<ffffffff805a1f50>] ? _spin_unlock_irq+0x30/0x3b
 [<ffffffff8020c850>] ? restore_args+0x0/0x30
 [<ffffffff8023fcf9>] ? finish_task_switch+0x40/0x111
 [<ffffffff80259e8c>] ? kthreadd+0x10f/0x134
 [<ffffffff80259eb1>] ? kthread+0x0/0x88
 [<ffffffff8020ce80>] ? child_rip+0x0/0x20
Code: 66 68 fd 49 8d 5e 20 4c 89 f7 48 8b 00 ff 50 18 48 89 df e8 9e 94 4b e0 49 8b 45 f0 41 c7 85 48 ff ff ff 06 00 00 00 48 83 c0 78 <f0> 0f ba 30 01 19 d2 85 d2 74 12 49 8b 7d f0 be 01 00 00 00 48 
RIP  [<ffffffffa00e8cb6>] fscache_object_slow_work_execute+0x44c/0x814 [fscache]
 RSP <ffff88037b2bde50>
CR2: 0000000000000078
---[ end trace bc3032821b5333dd ]---

-Bart

-- 
				WebSig: http://www.jukie.net/~bart/sig/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
