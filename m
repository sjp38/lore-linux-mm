Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 7D0F16B0069
	for <linux-mm@kvack.org>; Tue,  1 Nov 2011 18:20:11 -0400 (EDT)
Received: by ywa17 with SMTP id 17so9851269ywa.14
        for <linux-mm@kvack.org>; Tue, 01 Nov 2011 15:20:08 -0700 (PDT)
MIME-Version: 1.0
Date: Tue, 1 Nov 2011 15:20:08 -0700
Message-ID: <CALCETrW1mpVCz2tO5roaz1r6vnno+srHR-dHA6_pkRi2qiCfdw@mail.gmail.com>
Subject: hugetlb oops on 3.1.0-rc8-devel
From: Andy Lutomirski <luto@amacapital.net>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org

(Disclaimer: I have my file_update_time patch running in this kernel.
But I doubt that's the problem, since it has nothing to due with
hugepages.)

My system just oopsed, saying this:

... lots more than just this ...
[334297.627797] PID 25627 killed due to inadequate hugepage pool
[334298.130665] PID 25628 killed due to inadequate hugepage
pool"Developers ("Developers (AMA)" <dev@amacapital.net>, AMA)"
<dev@amacapital.net>,
[334298.993760] PID 25630 killed due to inadequate hugepage pool
[334299.373970] PID 25631 killed due to inadequate hugepage pool
[334301.073572] PID 25633 killed due to inadequate hugepage pool
[334301.460784] PID 25634 killed due to inadequate hugepage pool
[334302.602704] PID 25636 killed due to inadequate hugepage pool
[334302.911221] PID 25637 killed due to inadequate hugepage pool
[334304.119890] PID 25639 killed due to inadequate hugepage pool
[334304.636179] PID 25640 killed due to inadequate hugepage pool
[334305.143010] PID 25641 killed due to inadequate hugepage pool
[334305.934934] PID 25642 killed due to inadequate hugepage pool
[334306.595565] PID 25644 killed due to inadequate hugepage pool
[334308.043332] PID 25646 killed due to inadequate hugepage pool
[334308.606766] PID 25647 killed due to inadequate hugepage pool
[334309.628432] PID 25649 killed due to inadequate hugepage pool
[334309.961794] PID 25650 killed due to inadequate hugepage pool
[334311.170115] PID 25652 killed due to inadequate hugepage pool
[334311.287254] ------------[ cut here ]------------
[334311.287278] kernel BUG at mm/hugetlb.c:2407!
[334311.287296] invalid opcode: 0000 [#1] SMP
[334311.287315] CPU 6
[334311.287326] Modules linked in: ppdev parport_pc lp parport
des_generic ecb md4 nls_utf8 cifs fscache tcp_lp fuse acpi_cpufreq
mperf ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6 ip6table_filter
ip6_tables w83627ehf hwmon_vid coretemp btrfs zlib_deflate
lzo_compress libcrc32c snd_hda_codec_hdmi snd_hda_codec_realtek vfat
fat joydev snd_hda_intel snd_hda_codec snd_hwdep snd_seq
snd_seq_device snd_pcm snd_timer serio_raw snd i2c_i801 pcspkr
microcode e1000e soundcore xhci_hcd mei(C) snd_page_alloc iTCO_wdt
iTCO_vendor_support virtio_net virtio_ring virtio kvm_intel kvm ipv6
xts gf128mul dm_crypt firewire_ohci firewire_core crc_itu_t i915
drm_kms_helper drm i2c_algo_bit i2c_core video [last unloaded:
scsi_wait_scan]
[334311.287682]
[334311.287693] Pid: 22419, comm: lk_index_and_co Tainted: G         C
 3.1.0-rc8-devel+ #416                  /DQ67SW
[334311.287743] RIP: 0010:[<ffffffff810e3137>]  [<ffffffff810e3137>]
hugetlb_cow+0x209/0x355
[334311.287791] RSP: 0018:ffff880147cbdcb8  EFLAGS: 00010202
[334311.287813] RAX: 0000000000000001 RBX: ffff88017e668498 RCX:
0000000000000038
[334311.287840] RDX: 0000000000000000 RSI: ffff88017e6684e8 RDI:
ffffea0005110000
[334311.287868] RBP: ffff880147cbdd78 R08: 0000000000000000 R09:
ffff88023e38c600
[334311.287896] R10: 0000000000000001 R11: ffff88022cceb038 R12:
ffffea0005110000
[334311.287925] R13: 00007f1604600000 R14: ffffffff81bf8c20 R15:
ffff88022cc1c280
[334311.287954] FS:  00007f160b955740(0000) GS:ffff88023e380000(0000)
knlGS:0000000000000000
[334311.287983] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[334311.288007] CR2: 00007f9c18508000 CR3: 00000001549cd000 CR4:
00000000000406e0
[334311.288035] DR0: 0000000000000000 DR1: 0000000000000000 DR2:
00000"Developers (AMA)" <dev@amacapital.net>, 00000000000
[334311.288063] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7:
0000000000000400"Developers (AMA)" <dev@amacapital.net>,
[334311.288092] Process [random internal program] (pid: 22419,
threadinfo ffff880147cbc000, task ffff88022f185a80)
[334311.288126] Stack:
[334311.288137]  ffffffff81a33800 ffff88010c210808 ffff880213c88540
ffffffff81bf8c20
[334311.288172]  0000000000000000 ffff8801498a6118 80000001444000e5
ffff88010c210848
[334311.288206]  0000000000000001 00007f160461acd0 ffff880147cbdd18
ffff88017e6684e8
[334311.288241] Call Trace:
[334311.288256]  [<ffffffff810e36e6>] hugetlb_fault+0x3fd/0x49d
[334311.288280]  [<ffffffff810d17c2>] handle_mm_fault+0x81/0x1ae
[334311.288305]  [<ffffffff8101c9b5>] ? x2apic_send_IPI_mask+0x13/0x15
[334311.288331]  [<ffffffff81440f39>] do_page_fault+0x31f/0x366
[334311.288357]  [<ffffffff8103e9ab>] ? wake_up_new_task+0xb4/0xcd
[334311.288382]  [<ffffffff811c9820>] ? security_file_alloc+0x16/0x18
[334311.288408]  [<ffffffff810457f0>] ? do_fork+0x18c/0x225
[334311.288432]  [<ffffffff8143df2e>] ? _raw_spin_lock+0xe/0x10
[334311.288456]  [<ffffffff8143df2e>] ? _raw_spin_lock+0xe/0x10
[334311.288480]  [<ffffffff8143e4af>] page_fault+0x1f/0x30
[334311.288500] Code: ff ff 48 8d 75 98 48 89 c7 e8 3b 54 fe ff 48 85
c0 75 b6 48 8b bd 78 ff ff ff e8 2d 9f 35 00 4c 89 e7 e8 ed e5 ff ff
ff c8 74 02 <0f> 0b 49 8d 7f 5c e8 de ad 35 00 e9 58 fe ff ff 48 8b bd
78 ff
[334311.288652] RIP  [<ffffffff810e3137>] hugetlb_cow+0x209/0x355
[334311.288676]  RSP <ffff880147cbdcb8>
[334311.400050] ---[ end trace de2300cc5bd541be ]---

After the oops, accesses to /proc/22418/cmdline (and other things in
that directory) hang.  22418 is not the oopsing process or one of its
children, so this is strange.

The program that oopsed is written in python and does very little
other than firing off subprocesses (in C) and having a replacement
malloc LD_PRELOADed that is backed by MAP_PRIVATE | MAP_ANONYMOUS |
MAP_FIXED | MAP_HUGETLB mappings.  This is clearly a bad idea and I'll
stop doing it; nonetheless, it shouldn't oops.

The line that crashed is BUG_ON(page_count(old_page) != 1) in hugetlb_cow.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
