Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id A218D6B00ED
	for <linux-mm@kvack.org>; Wed, 18 Apr 2012 09:54:36 -0400 (EDT)
Date: Wed, 18 Apr 2012 09:54:32 -0400
From: Dave Jones <davej@redhat.com>
Subject: bdi_debug_stats_show oops.
Message-ID: <20120418135432.GA4622@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux Kernel <linux-kernel@vger.kernel.org>
Cc: linux-mm@kvack.org

Hit this during an overnight run of my syscall fuzzer.

	Dave


general protection fault: 0000 [#1] PREEMPT SMP=20
CPU 1=20
Modules linked in: tun ipt_ULOG dccp_ipv6 dccp_ipv4 dccp l2tp_ppp l2tp_netl=
ink l2tp_core nfnetlink scsi_transport_iscsi hidp ip_queue binfmt_misc bnep=
 rfcomm sctp libcrc32c caif_socket caif af_802154 phonet bluetooth can pppo=
e pppox ppp_generic slhc irda crc_ccitt rds af_key rose ax25 x25 atm applet=
alk ipx p8022 psnap llc p8023 tcp_lp fuse nfs fscache auth_rpcgss nfs_acl l=
ockd ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6 nf_conntrack_ipv4 nf_defr=
ag_ipv4 ip6table_filter xt_state nf_conntrack ip6_tables xts gf128mul dm_cr=
ypt arc4 iwlwifi coretemp mac80211 dell_wmi sparse_keymap snd_hda_codec_hdm=
i snd_hda_codec_idt uvcvideo snd_hda_intel videobuf2_core snd_hda_codec vid=
eodev snd_hwdep media snd_seq videobuf2_vmalloc cdc_ether videobuf2_memops =
usbnet snd_seq_device cdc_acm mii cdc_wdm snd_pcm microcode cfg80211 joydev=
 snd_timer tg3 pcspkr i2c_i801 snd rfkill iTCO_wdt iTCO_vendor_support soun=
dcore snd_page_alloc wmi sunrpc i915 drm_kms_helper drm i2c_algo_bit i2c_co=
re video [last unloaded: scsi_wait_scan]

Pid: 562, comm: trinity Not tainted 3.4.0-rc3+ #83 Dell Inc. Adamo 13   /0N=
70T0
RIP: 0010:[<ffffffff81177fd0>]  [<ffffffff81177fd0>] bdi_debug_stats_show+0=
x60/0x1f0
RSP: 0018:ffff8801028b3838  EFLAGS: 00010296
RAX: ffff88010fa45a70 RBX: ffff88004ff91da8 RCX: 48535441e58946ad
RDX: 48535441e5894855 RSI: ffff88010fa45a40 RDI: 0000000000000246
RBP: ffff8801028b38e8 R08: 0000000000000002 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000000 R12: 0000000000000001
R13: 0000000000000001 R14: 0000000000000000 R15: ffff88010fa456b0
FS:  00007f5430ee9700(0000) GS:ffff88013b400000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 00007f5430ecaff8 CR3: 00000001087be000 CR4: 00000000000407e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process trinity (pid: 562, threadinfo ffff8801028b2000, task ffff88000b034d=
40)
Stack:
 ffff8801028b3858 ffffffff810e0fd3 ffff88004ff91e30 ffffffff811e9cdf
 ffff88004ff91e58 ffff88013ffdac00 0000000000000000 0000000000000002
 2222222222222222 2222222222222222 2222222222222222 ffff88010fa45a70
Call Trace:
 [<ffffffff810e0fd3>] ? is_module_text_address+0x33/0x60
 [<ffffffff811e9cdf>] ? seq_read+0x3f/0x420
 [<ffffffff811e9e11>] seq_read+0x171/0x420
 [<ffffffff811e9ca0>] ? seq_lseek+0x120/0x120
 [<ffffffff811c4c59>] do_loop_readv_writev+0x59/0x90
 [<ffffffff811c4f76>] do_readv_writev+0x1b6/0x1d0
 [<ffffffff811c502c>] vfs_readv+0x3c/0x50
 [<ffffffff811f5f36>] default_file_splice_read+0x236/0x360
 [<ffffffff8108a180>] ? __kernel_text_address+0x60/0x90
 [<ffffffff816a45b9>] ? sub_preempt_count+0xa9/0xe0
 [<ffffffff816a01d5>] ? _raw_spin_unlock+0x35/0x60
 [<ffffffff811a98ec>] ? deactivate_slab+0x54c/0x5f0
 [<ffffffff811cfd7d>] ? alloc_pipe_info+0x4d/0xd0
 [<ffffffff811cfd7d>] ? alloc_pipe_info+0x4d/0xd0
 [<ffffffff811a6e7c>] ? set_track+0xac/0x1a0
 [<ffffffff811cfd7d>] ? alloc_pipe_info+0x4d/0xd0
 [<ffffffff810d14ed>] ? trace_hardirqs_on+0xd/0x10
 [<ffffffff811f4a20>] ? page_cache_pipe_buf_release+0x30/0x30
 [<ffffffff811f4dde>] do_splice_to+0x7e/0xa0
 [<ffffffff811f5097>] splice_direct_to_actor+0xa7/0x1c0
 [<ffffffff811f4d30>] ? do_splice_from+0xb0/0xb0
 [<ffffffff811f67dd>] do_splice_direct+0x4d/0x60
 [<ffffffff811c44dd>] do_sendfile+0x18d/0x220
 [<ffffffff811c544c>] sys_sendfile64+0x5c/0xb0
 [<ffffffff816a8569>] system_call_fastpath+0x16/0x1b
Code: 97 7a 52 00 49 8b 97 90 03 00 00 49 8d b7 90 03 00 00 48 8b 45 a8 48 =
39 d6 48 8d 8a 58 fe ff ff 74 20 66 0f 1f 84 00 00 00 00 00 <48> 8b 91 a8 0=
1 00 00 49 83 c4 01 48 39 d6 48 8d 8a 58 fe ff ff=20
RIP  [<ffffffff81177fd0>] bdi_debug_stats_show+0x60/0x1f0
 RSP <ffff8801028b3838>
---[ end trace 1e51b66fb215a455 ]---

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
