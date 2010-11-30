Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 727296B004A
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 18:01:15 -0500 (EST)
Received: from kpbe18.cbf.corp.google.com (kpbe18.cbf.corp.google.com [172.25.105.82])
	by smtp-out.google.com with ESMTP id oAUN1A5g031880
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 15:01:11 -0800
Received: from gxk4 (gxk4.prod.google.com [10.202.11.4])
	by kpbe18.cbf.corp.google.com with ESMTP id oAUN12dO028940
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 15:01:09 -0800
Received: by gxk4 with SMTP id 4so4001222gxk.7
        for <linux-mm@kvack.org>; Tue, 30 Nov 2010 15:01:07 -0800 (PST)
Date: Tue, 30 Nov 2010 15:00:59 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: kernel BUG at mm/truncate.c:475!
In-Reply-To: <20101130194945.58962c44@xenia.leun.net>
Message-ID: <alpine.LSU.2.00.1011301453090.12516@tigran.mtv.corp.google.com>
References: <20101130194945.58962c44@xenia.leun.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Michael Leun <lkml20101129@newton.leun.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 30 Nov 2010, Michael Leun wrote:

> happenes sporadically, cannot reproduce at will.
> 
> 
> Nov 30 15:24:55 elektra kernel: [ 6604.258610] ------------[ cut here ]------------
> Nov 30 15:24:55 elektra kernel: [ 6604.258628] kernel BUG at mm/truncate.c:475!
> Nov 30 15:24:55 elektra kernel: [ 6604.258633] invalid opcode: 0000 [#1] PREEMPT SMP
> Nov 30 15:24:55 elektra kernel: [ 6604.258640] last sysfs file: /sys/devices/system/cpu/cpu3/cache/index2/shared_cpu_map
> Nov 30 15:24:55 elektra kernel: [ 6604.258646] CPU 3
> Nov 30 15:24:55 elektra kernel: [ 6604.258649] Modules linked in: veth fuse af_packet bridge 8021q garp stp llc vboxnetadp vboxnetflt vboxdrv nouveau ttm drm_kms_helper drm i2c_algo_bit snd_pcm_oss snd_mixer_oss snd_seq snd_seq_device edd cpufreq_conservative cpufreq_userspace cpufreq_powersave acpi_cpufreq mperf ip6t_REJECT ipt_REJECT ip6t_LOG ipt_LOG xt_limit xt_recent nf_conntrack_ipv6 xt_state xt_tcpudp ip6table_mangle iptable_mangle iptable_nat ip6table_filter ip6_tables iptable_filter nf_nat_ftp nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_conntrack_ftp nf_conntrack ip_tables x_tables nls_utf8 loop arc4 ecb snd_hda_codec_nvhdmi iwlagn iwlcore snd_hda_codec_idt snd_hda_intel snd_hda_codec snd_hwdep mac80211 snd_pcm ohci1394 ieee1394 cfg80211 snd_timer sdhci_pci snd sdhci pcmcia firewire_ohci e1000e mmc_core yenta_socket soundcore firewire_core pcmcia_rsrc crc_itu_t pcmcia_core ppdev mcs7830 dm9601 dell_laptop usbnet rfkill snd_page_alloc dell_wmi shpchp sr_mod parport_p!
 c !
>  sg cdrom wmi dcdbas intel_ips parport i
> Nov 30 15:24:55 elektra kernel: ntel_agp i2c_i801 pci_hotplug iTCO_wdt pcspkr iTCO_vendor_support button video battery ac ext4 jbd2 crc16 sha256_generic aesni_intel cryptd aes_x86_64 aes_generic cbc dm_crypt usbhid linear ehci_hcd usbcore sd_mod dm_snapshot dm_mod fan processor ahci libahci libata scsi_mod thermal thermal_sys
> Nov 30 15:24:55 elektra kernel: [ 6604.258914]
> Nov 30 15:24:55 elektra kernel: [ 6604.258918] Pid: 31399, comm: cut Not tainted 2.6.36.1 #2 0N5KHN/Latitude E6510
> Nov 30 15:24:55 elektra kernel: [ 6604.258924] RIP: 0010:[<ffffffff810ee5e1>]  [<ffffffff810ee5e1>] invalidate_inode_pages2_range+0x271/0x350
> Nov 30 15:24:55 elektra kernel: [ 6604.258939] RSP: 0018:ffff8800774d5b58  EFLAGS: 00010246
> Nov 30 15:24:55 elektra kernel: [ 6604.258944] RAX: 0000000000000000 RBX: ffffea0001ea2f40 RCX: ffff8800c05a5bd0
> Nov 30 15:24:55 elektra kernel: [ 6604.258950] RDX: 0000000000000000 RSI: ffff8800774d5a28 RDI: ffff8800c0521a18
> Nov 30 15:24:55 elektra kernel: [ 6604.258956] RBP: ffff8800774d5c38 R08: ffff8800c05a5bd0 R09: ffff8800774d5ae8
> Nov 30 15:24:55 elektra kernel: [ 6604.258962] R10: 0000000000000008 R11: 0000000000000001 R12: ffff8800774d5b98
> Nov 30 15:24:55 elektra kernel: [ 6604.258969] R13: 0000000000000000 R14: ffff8800c05219d8 R15: 0000000000000000
> Nov 30 15:24:55 elektra kernel: [ 6604.258980] FS:  0000000000000000(0000) GS:ffff880001cc0000(0000) knlGS:0000000000000000
> Nov 30 15:24:55 elektra kernel: [ 6604.258992] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> Nov 30 15:24:55 elektra kernel: [ 6604.258999] CR2: 00007f3ad2337290 CR3: 00000000850b3000 CR4: 00000000000006e0
> Nov 30 15:24:55 elektra kernel: [ 6604.259010] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> Nov 30 15:24:55 elektra kernel: [ 6604.259019] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> Nov 30 15:24:55 elektra kernel: [ 6604.259028] Process cut (pid: 31399, threadinfo ffff8800774d4000, task ffff8800a2bbae40)
> Nov 30 15:24:55 elektra kernel: [ 6604.259038] Stack:
> Nov 30 15:24:55 elektra kernel: [ 6604.259042]  ffffffff81074300 ffff8800c05219f0 00000001774d5b60 0000000000000001
> Nov 30 15:24:55 elektra kernel: [ 6604.259054] <0> ffffffffffffffff 00000000c41fec70 000000000000000e 0000000000000000
> Nov 30 15:24:55 elektra kernel: [ 6604.259069] <0> ffffea0001ea2f40 ffffea0001a246c8 ffffea0001a24690 ffffea0001a47348
> Nov 30 15:24:55 elektra kernel: [ 6604.259087] Call Trace:
> Nov 30 15:24:55 elektra kernel: [ 6604.259094]  [<ffffffff81074300>] ? autoremove_wake_function+0x0/0x40
> Nov 30 15:24:55 elektra kernel: [ 6604.259101]  [<ffffffff810ee6d2>] invalidate_inode_pages2+0x12/0x20
> Nov 30 15:24:55 elektra kernel: [ 6604.259111]  [<ffffffffa0848ce0>] fuse_finish_open+0x60/0x70 [fuse]
> Nov 30 15:24:55 elektra kernel: [ 6604.259118]  [<ffffffffa0848d71>] fuse_open_common+0x81/0x90 [fuse]
> Nov 30 15:24:55 elektra kernel: [ 6604.259125]  [<ffffffffa0848d80>] ? fuse_open+0x0/0x10 [fuse]
> Nov 30 15:24:55 elektra kernel: [ 6604.259132]  [<ffffffffa0848d8b>] fuse_open+0xb/0x10 [fuse]
> Nov 30 15:24:55 elektra kernel: [ 6604.259139]  [<ffffffff81137a1a>] __dentry_open+0x11a/0x3c0
> Nov 30 15:24:55 elektra kernel: [ 6604.259147]  [<ffffffff811efbda>] ? security_inode_permission+0x1a/0x20
> Nov 30 15:24:55 elektra kernel: [ 6604.259154]  [<ffffffff81138cc4>] nameidata_to_filp+0x54/0x70
> Nov 30 15:24:55 elektra kernel: [ 6604.259160]  [<ffffffff81147168>] do_last+0x488/0x760
> Nov 30 15:24:55 elektra kernel: [ 6604.259166]  [<ffffffff81147868>] do_filp_open+0x428/0x670
> Nov 30 15:24:55 elektra kernel: [ 6604.259173]  [<ffffffffa0842983>] ? fuse_request_free+0x13/0x20 [fuse]
> Nov 30 15:24:55 elektra kernel: [ 6604.259181]  [<ffffffffa0842a48>] ? fuse_put_request+0xb8/0xc0 [fuse]
> Nov 30 15:24:55 elektra kernel: [ 6604.259193]  [<ffffffff81138d40>] do_sys_open+0x60/0x120
> Nov 30 15:24:55 elektra kernel: [ 6604.259205]  [<ffffffff81138e1b>] sys_open+0x1b/0x20
> Nov 30 15:24:55 elektra kernel: [ 6604.259217]  [<ffffffff81002f02>] system_call_fastpath+0x16/0x1b
> Nov 30 15:24:55 elektra kernel: [ 6604.259228] Code: fe ff ff 0f 1f 80 00 00 00 00 48 89 c6 31 c9 48 c1 e6 0c ba 00 10 00 00 4c 89 f7 e8 ba 37 01 00 8b 43 0c 85 c0 0f 88 2e ff ff ff <0f> 0b 0f 1f 44 00 00 48 89 df e8 30 39 ff ff 8b 85 50 ff ff ff
> Nov 30 15:24:55 elektra kernel: [ 6604.259394] RIP  [<ffffffff810ee5e1>] invalidate_inode_pages2_range+0x271/0x350
> Nov 30 15:24:55 elektra kernel: [ 6604.259412]  RSP <ffff8800774d5b58>
> Nov 30 15:24:55 elektra kernel: [ 6604.265642] ---[ end trace 019ef068b5f8e921 ]---

BUG_ON(page_mapped(page)) in invalidate_inode_pages2_range():
that's interesting, it may relate to another BUG_ON(page_mapped(page))
that's been reported recently.

This is a 2.6.36.1 kernel you're running: any idea what was the first
kernel on which you started seeing such errors?  and what was the last
good kernel on which you ran the same kind of load but saw no problems?

Thanks,
Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
