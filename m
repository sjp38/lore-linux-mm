Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id A5FFC6B01B1
	for <linux-mm@kvack.org>; Fri, 21 May 2010 13:25:54 -0400 (EDT)
Date: Fri, 21 May 2010 13:25:51 -0400
Subject: Re: TMPFS over NFS
Message-ID: <20100521172551.GC9639@fieldses.org>
References: <AANLkTim5q1abuL3BtXST7IEHBgfczaqEmA4Jn73XWUST@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <AANLkTim5q1abuL3BtXST7IEHBgfczaqEmA4Jn73XWUST@mail.gmail.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: owner-linux-mm@kvack.org
To: Tharindu Rukshan Bamunuarachchi <btharindu@gmail.com>
Cc: linux-nfs@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, May 21, 2010 at 01:51:40PM +0100, Tharindu Rukshan Bamunuarachchi wrote:
> dear All,
> 
> I tried to export tmpfs file system over NFS and got followin oops ....
> this kernel is provided with SLES 11 and tainted due to OFED installation.
> 
> I am using NFSv4. Please help me to find the root cause if you feel free ....

I don't know.  My first thought is to blame tmpfs; hopefully cc'ing
linux-mm@kvack.org is the right thing to do for that....

--b.

> BUG: unable to handle kernel NULL pointer dereference at 00000000000000b0
> IP: __vm_enough_memory+0xf9/0x14e
> PGD 0
> Oops: 0000 [1] SMP
> last sysfs file:
> /sys/devices/pci0000:00/0000:00:09.0/0000:24:00.0/infiniband/mlx4_1/node_desc
> CPU 0
> Modules linked in: md5 mmfs26(X) mmfslinux(X) tracedev(X) nfsd lockd
> nfs_acl auth_rpcgss sunrpc exportfs bonding binfmt_misc microcode
> rdma_ucm(N) ib_sdp(N) rdma_cm(N) iw_cm(N) ib_addr(N) ib_ipoib(N)
> ib_cm(N) ib_sa(N) ipv6 ib_uverbs(N) ib_umad(N) mlx4_en(N) mlx4_ib(N)
> ib_mthca(N) ib_mad(N) ib_core(N) fuse ext2 xfs loop dm_mod cdc_ether
> usbnet i2c_i801 rtc_cmos shpchp button joydev mlx4_core(N) rtc_core
> pcspkr pci_hotplug sr_mod rtc_lib mii bnx2 i2c_core cdrom sg usbhid
> hid ff_memless uhci_hcd ehci_hcd sd_mod crc_t10dif usbcore edd ext3
> mbcache jbd fan thermal processor thermal_sys hwmon ide_pci_generic
> ide_core ata_generic ata_piix libata dock megaraid_sas scsi_mod [last
> unloaded: tracedev]
> Supported: No, Unsupported modules are loaded
> Pid: 8855, comm: nfsd Tainted: G 2.6.27.45-0.1-default #1
> RIP: 0010: __vm_enough_memory+0xf9/0x14e
> RSP: 0018:ffff8803642cd780 EFLAGS: 00010202
> RAX: 00000000002f151c RBX: 0000000012643f22 RCX: 0000000000400293
> RDX: 0000000000000032 RSI: 0000000000000001 RDI: 00000000002f151c
> RBP: 0000000000000001 R08: 00000000ffffffe5 R09: 0000000000000000
> R10: ffffffff806eb5c8 R11: ffffffff80317108 R12: 0000000000000001
> R13: 0000000000000000 R14: 0000000000001000 R15: ffff88037b93b738
> FS: 0000000000000000(0000) GS:ffffffff80a43080(0000) knlGS:0000000000000000
> CS: 0010 DS: 0018 ES: 0018 CR0: 000000008005003b
> CR2: 00000000000000b0 CR3: 0000000000201000 CR4: 00000000000006e0
> DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> Process nfsd (pid: 8855, threadinfo ffff8803642cc000, task ffff88036f140380)
> Stack: ffff88037b93b668 ffff88037009de40 ffff88037b93b668 0000000000000000
> ffff88037b93b601 ffffffff802a8573 ffffffff80a33680 ffffffff80a30730
> 0000000000000000 0000000300000002 ffff8803642cd930 0000000000000000
> Call Trace:
> shmem_getpage+0x4d8/0x764
> generic_perform_write+0xae/0x1b5
> generic_file_buffered_write+0x80/0x130
> __generic_file_aio_write_nolock+0x349/0x37d
> generic_file_aio_write+0x64/0xc4
> do_sync_readv_writev+0xc0/0x107
> do_readv_writev+0xb2/0x18b
> nfsd_vfs_write+0x10a/0x328 [nfsd]
> nfsd_write+0x79/0xe2 [nfsd]
> nfsd4_write+0xd9/0x10d [nfsd]
> nfsd4_proc_compound+0x1bd/0x2c7 [nfsd]
> nfsd_dispatch+0xdd/0x1b9 [nfsd]
> svc_process+0x3d8/0x700 [sunrpc]
> nfsd+0x1b1/0x27e [nfsd]
> kthread+0x47/0x73
> child_rip+0xa/0x11
> 
> 
> Code: 00 48 29 c3 48 63 05 49 1a 45 00 48 0f af d8 48 89 d8 48 f7 f1
> 45 85 e4 48 89 c7 75 07 48 c1 e8 05 48 29 c7 48 8b 0d b9 2f 86 00 <49>
> 8b b5 b0 00 00 00 48 8b 15 43 2f 86 00 b8 01 00 00 00 48 85
> RIP __vm_enough_memory+0xf9/0x14e
> RSP <ffff8803642cd780>
> CR2: 00000000000000b0
> ---[ end trace ca3d7c15970cb4b6 ]---
> 
> __
> tharindu.info
> 
> "those that can, do. Those that cana??t, complain." -- Linus
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
gg> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
