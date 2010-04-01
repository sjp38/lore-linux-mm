Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 790D76B01F0
	for <linux-mm@kvack.org>; Thu,  1 Apr 2010 13:52:47 -0400 (EDT)
Date: Thu, 1 Apr 2010 19:52:25 +0200
From: Heinz Diehl <htd@fancy-poultry.org>
Subject: 2.6.34-rc3, BUG at mm/slab.c:2989
Message-ID: <20100401175225.GA6581@fancy-poultry.org>
Reply-To: linux-kernel@vger.kernel.org
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org
Cc: Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

about an half hour ago, one of my machines froze completely, nothing
worked (no m-sysrq either) and I had to hardreset and reboot.=20

/var/log/warn says:

[....]
Apr  1 17:25:15 liesel kernel: sd 8:0:0:1: [sdd] Assuming drive cache: writ=
e through
Apr  1 17:25:15 liesel kernel: sd 8:0:0:1: [sdd] Assuming drive cache: writ=
e through
Apr  1 17:25:15 liesel kernel: sd 8:0:0:1: [sdd] Assuming drive cache: writ=
e through
Apr  1 17:25:17 liesel kernel: sd 8:0:0:0: [sdc] Assuming drive cache: writ=
e through
Apr  1 17:25:17 liesel kernel: sd 8:0:0:0: [sdc] Assuming drive cache: writ=
e through
Apr  1 17:45:35 liesel squid[5637]: WARNING: Very large maximum_object_size=
_in_memory settings can have negative impact on performance
Apr  1 17:45:37 liesel squid[5637]: WARNING: Very large maximum_object_size=
_in_memory settings can have negative impact on performance
Apr  1 18:20:33 liesel kernel: kernel BUG at mm/slab.c:2989!
Apr  1 18:20:33 liesel kernel: CPU 0=20
Apr  1 18:20:33 liesel kernel: Modules linked in: nls_iso8859_1 nls_cp437 v=
fat fat usb_storage xt_pkttype ipt_LOG xt_limit aes_x86_64 aes_generic af_p=
acket it87 hwmon_vid binfmt_misc snd_pcm_oss snd_mixer_oss snd_seq snd_seq_=
device cpufreq_conservative cpufreq_ondemand cpufreq_userspace cpufreq_powe=
rsave powernow_k8 freq_table mperf(P) xt_NOTRACK xt_state iptable_raw nf_co=
nntrack_netbios_ns nf_conntrack_ipv4 nf_conntrack nf_defrag_ipv4 ip6_tables=
 ipt_REJECT iptable_filter ip_tables uhci_hcd rt73usb rt2x00usb snd_hda_cod=
ec_realtek snd_hda_intel rt2x00lib snd_hda_codec led_class snd_pcm i2c_piix=
4 snd_timer ppdev k10temp sr_mod hwmon snd cdrom mac80211 i2c_core r8169 bu=
tton soundcore joydev cfg80211 snd_page_alloc sg pcspkr parport_pc mii parp=
ort rfkill xts usbhid sd_mod ohci_hcd ehci_hcd pata_atiixp rtc_cmos rtc_cor=
e rtc_lib ahci usbcore hmac dm_snapshot dm_crypt dm_mod gf128mul sha512_gen=
eric sha256_generic twofish_x86_64 twofish_common serpent cbc tgr192 loop e=
cb arc4 fuse edd ide_pci_generic amd74xx ide_core fa
Apr  1 18:20:33 liesel kernel:=20
Apr  1 18:20:33 liesel kernel: Pid: 10452, comm: gnome-panel Tainted: P    =
       2.6.34-rc3 #1 GA-MA770-UD3/GA-MA770-UD3
Apr  1 18:20:33 liesel kernel: RIP: 0010:[<ffffffff810d063a>]  [<ffffffff81=
0d063a>] cache_alloc_refill+0x1ea/0x270
Apr  1 18:20:33 liesel kernel: RSP: 0018:ffff880177151d20  EFLAGS: 00010046
Apr  1 18:20:33 liesel kernel: RAX: 0000000000000090 RBX: ffff88022f797800 =
RCX: 0000000000000020
Apr  1 18:20:33 liesel kernel: RDX: ffff880009ff3000 RSI: ffff88000ab8d000 =
RDI: 000000000000001c
Apr  1 18:20:33 liesel kernel: RBP: 000000000000001c R08: ffff88022f742c50 =
R09: ffff88022f742c60
Apr  1 18:20:33 liesel kernel: R10: dead000000200200 R11: dead000000100100 =
R12: ffff88022f7d0b00
Apr  1 18:20:33 liesel kernel: R13: ffff88022f742c40 R14: 0000000000000000 =
R15: ffff88022f799000
Apr  1 18:20:33 liesel kernel: FS:  00007f24fe2e07d0(0000) GS:ffff880005e00=
000(0000) knlGS:00000000f741f6d0
Apr  1 18:20:33 liesel kernel: CS:  0010 DS: 0000 ES: 0000 CR0: 00000000800=
5003b
Apr  1 18:20:33 liesel kernel: CR2: 00007f24f6d08c00 CR3: 0000000174157000 =
CR4: 00000000000006f0
Apr  1 18:20:33 liesel kernel: DR0: 0000000000000000 DR1: 0000000000000000 =
DR2: 0000000000000000
Apr  1 18:20:33 liesel kernel: DR3: 0000000000000000 DR6: 00000000ffff0ff0 =
DR7: 0000000000000400
Apr  1 18:20:33 liesel kernel: Process gnome-panel (pid: 10452, threadinfo =
ffff880177150000, task ffff88022a3aa080)
Apr  1 18:20:33 liesel kernel:  ffff88022b0d2b48 00000000000412d0 ffff88022=
f742c80 ffff88000abba818
Apr  1 18:20:33 liesel kernel: <0> 00000000000000d0 0000000000000202 ffff88=
022f7d0b00 ffff88017fbd3978
Apr  1 18:20:33 liesel kernel: <0> 000000000000000a ffffffff810d0992 ffff88=
000abba818 ffff88000abba818
Apr  1 18:20:33 liesel kernel:  [<ffffffff810d0992>] ? kmem_cache_alloc+0x1=
22/0x150
Apr  1 18:20:33 liesel kernel:  [<ffffffff810bce73>] ? anon_vma_fork+0x53/0=
xa0
Apr  1 18:20:33 liesel kernel:  [<ffffffff8103d3b8>] ? dup_mm+0x238/0x510
Apr  1 18:20:33 liesel kernel:  [<ffffffff8103dfbb>] ? copy_process+0x8eb/0=
x1000
Apr  1 18:20:33 liesel kernel:  [<ffffffff8103e762>] ? do_fork+0x92/0x3c0
Apr  1 18:20:33 liesel kernel:  [<ffffffff81028727>] ? do_page_fault+0x167/=
0x380
Apr  1 18:20:33 liesel kernel:  [<ffffffff81003053>] ? stub_clone+0x13/0x20
Apr  1 18:20:33 liesel kernel:  [<ffffffff81002d6b>] ? system_call_fastpath=
+0x16/0x1b
Apr  1 18:20:33 liesel kernel:  RSP <ffff880177151d20>
Apr  1 18:20:33 liesel kernel: ---[ end trace 294065aff98fa970 ]---
Apr  1 18:20:33 liesel kernel: BUG: scheduling while atomic: gnome-panel/10=
452/0x00000002
Apr  1 18:20:33 liesel kernel: Modules linked in: nls_iso8859_1 nls_cp437 v=
fat fat usb_storage xt_pkttype ipt_LOG xt_limit aes_x86_64 aes_generic af_p=
acket it87 hwmon_vid binfmt_misc snd_pcm_oss snd_mixer_oss snd_seq snd_seq_=
device cpufreq_conservative cpufreq_ondemand cpufreq_userspace cpufreq_powe=
rsave powernow_k8 freq_table mperf(P) xt_NOTRACK xt_state iptable_raw nf_co=
nntrack_netbios_ns nf_conntrack_ipv4 nf_conntrack nf_defrag_ipv4 ip6_tables=
 ipt_REJECT iptable_filter ip_tables uhci_hcd rt73usb rt2x00usb snd_hda_cod=
ec_realtek snd_hda_intel rt2x00lib snd_hda_codec led_class snd_pcm i2c_piix=
4 snd_timer ppdev k10temp sr_mod hwmon snd cdrom mac80211 i2c_core r8169 bu=
tton soundcore joydev cfg80211 snd_page_alloc sg pcspkr parport_pc mii parp=
ort rfkill xts usbhid sd_mod ohci_hcd ehci_hcd pata_atiixp rtc_cmos rtc_cor=
e rtc_lib ahci usbcore hmac dm_snapshot dm_crypt dm_mod gf128mul sha512_gen=
eric sha256_generic twofish_x86_64 twofish_common serpent cbc tgr192 loop e=
cb arc4 fuse edd ide_pci_generic amd74xx ide_core fa
Apr  1 18:20:33 liesel kernel: Pid: 10452, comm: gnome-panel Tainted: P    =
  D    2.6.34-rc3 #1
Apr  1 18:20:33 liesel kernel: Call Trace:
Apr  1 18:20:33 liesel kernel:  [<ffffffff8142a2e0>] ? schedule+0x520/0x840
Apr  1 18:20:33 liesel kernel:  [<ffffffff8103f52b>] ? __call_console_drive=
rs+0x6b/0x80
Apr  1 18:20:33 liesel kernel:  [<ffffffff8105bc56>] ? up+0x16/0x50
Apr  1 18:20:33 liesel kernel:  [<ffffffff8142c22d>] ? rwsem_down_failed_co=
mmon+0xcd/0x200
Apr  1 18:20:33 liesel kernel:  [<ffffffff8142c3b2>] ? rwsem_down_read_fail=
ed+0x22/0x2b
Apr  1 18:20:33 liesel kernel:  [<ffffffff8129edd4>] ? call_rwsem_down_read=
_failed+0x14/0x30
Apr  1 18:20:33 liesel kernel:  [<ffffffff8142b86e>] ? down_read+0xe/0x10
Apr  1 18:20:33 liesel kernel:  [<ffffffff810759e2>] ? acct_collect+0x42/0x=
1a0
Apr  1 18:20:33 liesel kernel:  [<ffffffff810435f4>] ? do_exit+0x6d4/0x820
Apr  1 18:20:33 liesel kernel:  [<ffffffff8142994d>] ? printk+0x40/0x4b
Apr  1 18:20:33 liesel kernel:  [<ffffffff810403cd>] ? kmsg_dump+0x7d/0x140
Apr  1 18:20:33 liesel kernel:  [<ffffffff81007391>] ? oops_end+0xe1/0xf0
Apr  1 18:20:33 liesel kernel:  [<ffffffff81004904>] ? do_invalid_op+0x84/0=
xa0
Apr  1 18:20:33 liesel kernel:  [<ffffffff810d063a>] ? cache_alloc_refill+0=
x1ea/0x270
Apr  1 18:20:33 liesel kernel:  [<ffffffff8142a1a7>] ? schedule+0x3e7/0x840
Apr  1 18:20:33 liesel kernel:  [<ffffffff81003995>] ? invalid_op+0x15/0x20
Apr  1 18:20:33 liesel kernel:  [<ffffffff810d063a>] ? cache_alloc_refill+0=
x1ea/0x270
Apr  1 18:20:33 liesel kernel:  [<ffffffff810d0992>] ? kmem_cache_alloc+0x1=
22/0x150
Apr  1 18:20:33 liesel kernel:  [<ffffffff810bce73>] ? anon_vma_fork+0x53/0=
xa0
Apr  1 18:20:33 liesel kernel:  [<ffffffff8103d3b8>] ? dup_mm+0x238/0x510
Apr  1 18:20:33 liesel kernel:  [<ffffffff8103dfbb>] ? copy_process+0x8eb/0=
x1000
Apr  1 18:20:33 liesel kernel:  [<ffffffff8103e762>] ? do_fork+0x92/0x3c0
Apr  1 18:20:33 liesel kernel:  [<ffffffff81028727>] ? do_page_fault+0x167/=
0x380
Apr  1 18:20:33 liesel kernel:  [<ffffffff81003053>] ? stub_clone+0x13/0x20
Apr  1 18:20:33 liesel kernel:  [<ffffffff81002d6b>] ? system_call_fastpath=
+0x16/0x1b
Apr  1 19:03:57 liesel rpcbind: cannot create socket for udp6
Apr  1 19:03:57 liesel rpcbind: cannot create socket for tcp6
Apr  1 19:04:01 liesel kernel: nf_conntrack version 0.5.0 (16384 buckets, 6=
5536 max)
Apr  1 19:04:01 liesel kernel: CONFIG_NF_CT_ACCT is deprecated and will be =
removed soon. Please use
Apr  1 19:04:01 liesel kernel: nf_conntrack.acct=3D1 kernel parameter, acct=
=3D1 nf_conntrack module option or
Apr  1 19:04:01 liesel kernel: sysctl net.netfilter.nf_conntrack_acct=3D1 t=
o enable it.
[....]

Feel free to drop me a note if you need more information.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
