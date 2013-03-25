Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id 74FCB6B0002
	for <linux-mm@kvack.org>; Mon, 25 Mar 2013 01:37:52 -0400 (EDT)
Date: Mon, 25 Mar 2013 01:37:50 -0400 (EDT)
From: CAI Qian <caiqian@redhat.com>
Message-ID: <364499626.5604667.1364189870552.JavaMail.root@redhat.com>
In-Reply-To: <alpine.DEB.2.02.1303220231280.12597@chino.kir.corp.google.com>
Subject: Re: BUG at kmem_cache_alloc
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-mm <linux-mm@kvack.org>, linux-kernel@vger.kernel.org, Oleg Nesterov <oleg@redhat.com>



----- Original Message -----
> From: "David Rientjes" <rientjes@google.com>
> To: "CAI Qian" <caiqian@redhat.com>
> Cc: "linux-mm" kvack.org>, linux-kernel@vger.kernel.org, "Oleg Nesterov" <oleg@redhat.com>
> Sent: Friday, March 22, 2013 5:35:34 PM
> Subject: Re: BUG at kmem_cache_alloc
> 
> On Fri, 22 Mar 2013, CAI Qian wrote:
> 
> > Starting to see those on 3.8.4 (never saw in 3.8.2) stable kernel
> > on a few systems
> > during LTP run,
> > 
> > [11297.597242] BUG: unable to handle kernel paging request at
> > 00000000fffffffe
> > [11297.598022] IP: [] kmem_cache_alloc+0x68/0x1e0
> 
> Is this repeatable?  Do you have CONFIG_SLAB or CONFIG_SLUB enabled?
Saw it on 2 systems so far - one HP server and one KVM guest. Still
trying to reproduce. Used CONFIG_SLUB=y.
CAI Qian
> 
> > [11297.598022] PGD 7b9eb067 PUD 0
> > [11297.598022] Oops: 0000 [#2] SMP
> > [11297.598022] Modules linked in: cmtp kernelcapi bnep
> > scsi_transport_iscsi rfcomm l2tp_ppp l2tp_netlink l2tp_core hidp
> > ipt_ULOG af_key nfc rds pppoe pppox ppp_generic slhc af_802154 atm
> > ip6table_filter ip6_tables iptable_filter ip_tables btrfs
> > zlib_deflate vfat fat nfs_layout_nfsv41_files nfsv4 auth_rpcgss
> > nfsv3 nfs_acl nfsv2 nfs lockd sunrpc fscache nfnetlink_log
> > nfnetlink bluetooth rfkill arc4 md4 nls_utf8 cifs dns_resolver
> > nf_tproxy_core nls_koi8_u nls_cp932 ts_kmp sctp sg kvm_amd kvm
> > virtio_balloon i2c_piix4 pcspkr xfs libcrc32c ata_generic
> > pata_acpi cirrus drm_kms_helper ttm ata_piix virtio_net drm libata
> > virtio_blk i2c_core floppy dm_mirror dm_region_hash dm_log dm_mod
> > [last unloaded: ipt_REJECT]
> > [11297.598022] CPU 1
> > [11297.598022] Pid: 14134, comm: ltp-pan Tainted: G      D
> >      3.8.4+ #1 Bochs Bochs
> > [11297.598022] RIP: 0010:[]  [] kmem_cache_alloc+0x68/0x1e0
> > [11297.598022] RSP: 0018:ffff8800447dbdd0  EFLAGS: 00010246
> > [11297.598022] RAX: 0000000000000000 RBX: ffff88007c169970 RCX:
> > 00000000018acdcd
> > [11297.598022] RDX: 000000000006c104 RSI: 00000000000080d0 RDI:
> > ffff88007d04ac00
> > [11297.598022] RBP: ffff8800447dbe10 R08: 0000000000017620 R09:
> > ffffffff810fe2e2
> > [11297.598022] R10: 0000000000000000 R11: 0000000000000000 R12:
> > 00000000fffffffe
> > [11297.598022] R13: 00000000000080d0 R14: ffff88007d04ac00 R15:
> > ffff88007d04ac00
> > [11297.598022] FS:  00007f09c29b4740(0000)
> > GS:ffff88007fd00000(0000) knlGS:00000000f74d86c0
> > [11297.598022] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> > [11297.598022] CR2: 00000000fffffffe CR3: 0000000037213000 CR4:
> > 00000000000006e0
> > [11297.598022] DR0: 0000000000000000 DR1: 0000000000000000 DR2:
> > 0000000000000000
> > [11297.598022] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7:
> > 0000000000000400
> > [11297.598022] Process ltp-pan (pid: 14134, threadinfo
> > ffff8800447da000, task ffff8800551ab2e0)
> > [11297.598022] Stack:
> > [11297.598022]  ffffffff810fe2e2 ffffffff8108cf0f 0000000001200011
> > ffff88007c169970
> > [11297.598022]  0000000000000000 00007f09c29b4a10 0000000000000000
> > ffff88007c169970
> > [11297.598022]  ffff8800447dbe30 ffffffff810fe2e2 0000000000000000
> > 0000000001200011
> > [11297.598022] Call Trace:
> > [11297.598022]  [] ? __delayacct_tsk_init+0x22/0x40
> > [11297.598022]  [] ? prepare_creds+0xdf/0x190
> > [11297.598022]  [] __delayacct_tsk_init+0x22/0x40
> > [11297.598022]  [] copy_process.part.25+0x31f/0x13f0
> > [11297.598022]  [] do_fork+0xa9/0x350
> > [11297.598022]  [] sys_clone+0x16/0x20
> > [11297.598022]  [] stub_clone+0x69/0x90
> > [11297.598022]  [] ? system_call_fastpath+0x16/0x1b
> > [11297.598022] Code: 90 4d 89 fe 4d 8b 06 65 4c 03 04 25 c8 db 00
> > 00 49 8b 50 08 4d 8b 20 4d 85 e4 0f 84 2b 01 00 00 49 63 46 20 4d
> > 8b 06 41 f6 c0 0f <49> 8b 1c 04 0f 85 55 01 00 00 48 8d 4a 01 4c
> > 89 e0 65 49 0f c7
> > [11297.598022] RIP  [] kmem_cache_alloc+0x68/0x1e0
> > [11297.598022]  RSP
> > [11297.598022] CR2: 00000000fffffffe
> > [11297.727799] ---[ end trace 037bde72f23b34d2 ]---
> > 
> > Never saw this in mainline but only something like this wondering
> > could be related
> > (that kmem_cache_alloc also in the trace).
> > 
> 
> These are unrelated.
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: href=mailto:"dont@kvack.org"> email@kvack.org 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
