Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id 072B46B0032
	for <linux-mm@kvack.org>; Wed, 24 Apr 2013 23:43:21 -0400 (EDT)
Date: Wed, 24 Apr 2013 23:43:20 -0400 (EDT)
From: CAI Qian <caiqian@redhat.com>
Message-ID: <825854245.2071098.1366861400988.JavaMail.root@redhat.com>
In-Reply-To: <84952911.2068510.1366860446300.JavaMail.root@redhat.com>
Subject: WARNING: at fs/ext4/inode.c:3222
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-ext4@vger.kernel.org
Cc: linux-mm <linux-mm@kvack.org>, Steve Best <sbest@redhat.com>

OK, this is to test the latest ext4 dev tree on power 7 systems running xfstests,
http://people.redhat.com/qcai/console.log

[16276.692220] ------------[ cut here ]------------ 
[16276.692235] WARNING: at fs/ext4/inode.c:3222 
[16276.692238] Modules linked in: binfmt_misc(F) tun(F) nfnetlink(F) ipt_ULOG(F) pppoe(F) pppox(F) ppp_generic(F) slhc(F) bluetooth(F) rfkill(F) nfc(F) atm(F) af_key(F) rds(F) af_802154(F) btrfs(F) raid6_pq(F) xor(F) vfat(F) fat(F) lockd(F) sunrpc(F) nf_conntrack_netbios_ns(F) nf_conntrack_broadcast(F) ipt_MASQUERADE(F) ip6table_mangle(F) ip6t_REJECT(F) nf_conntrack_ipv6(F) nf_defrag_ipv6(F) iptable_nat(F) nf_nat_ipv4(F) nf_nat(F) iptable_mangle(F) ipt_REJECT(F) nf_conntrack_ipv4(F) nf_defrag_ipv4(F) xt_conntrack(F) nf_conntrack(F) ebtable_filter(F) ebtables(F) ip6table_filter(F) ip6_tables(F) iptable_filter(F) ip_tables(F) sg(F) ehea(F) xfs(F) libcrc32c(F) sd_mod(F) crc_t10dif(F) ibmvscsi(F) scsi_transport_srp(F) scsi_tgt(F) dm_mirror(F) dm_region_hash(F) dm_log(F) dm_mod(F) [last unloaded: brd] 
[16276.692325] NIP: c0000000002bcdd4 LR: c0000000002bcc1c CTR: c0000000002bcec0 
[16276.692329] REGS: c0000000e8a03570 TRAP: 0700   Tainted: GF       W     (3.9.0-rc5+) 
[16276.692333] MSR: 8000000000029032 <SF,EE,ME,IR,DR,RI>  CR: 24824484  XER: 20000001 
[16276.692342] SOFTE: 1 
[16276.692344] CFAR: c0000000002bcc24 
[16276.692347] TASK = c00000012d9e5a40[7601] 'aio-dio-invalid' THREAD: c0000000e8a00000 CPU: 40 
GPR00: c0000000002bcc1c c0000000e8a037f0 c0000000010f3d98 0000000000000000  
GPR04: c00000010c3b4100 c00000010c3b4100 0000000000000001 00000000000007ae  
GPR08: 00000000000007ad 0000000000000001 0000000000000000 0000000000265174  
GPR12: 0000000024824482 c00000000edea000 0000000000000000 0000000000000000  
GPR16: 0000000000000000 6db6db6db6db6db7 c000000000273d98 0000000000000000  
GPR20: 00003ffffed6baf0 0000000000000001 0000000000000000 c00000010c3b4080  
GPR24: 0000000000000001 c00000010c11b900 0000000000000000 0000000000000001  
GPR28: fffffffffffffe00 c0000001171f68d0 c0000001171f68d0 c00000010c11b988  
[16276.692394] NIP [c0000000002bcdd4] .ext4_direct_IO+0x464/0x550 
[16276.692398] LR [c0000000002bcc1c] .ext4_direct_IO+0x2ac/0x550 
[16276.692401] Call Trace: 
[16276.692403] [c0000000e8a037f0] [c0000000002bcc1c] .ext4_direct_IO+0x2ac/0x550 (unreliable) 
[16276.692409] [c0000000e8a038d0] [c000000000191e54] .generic_file_direct_write+0x114/0x230 
[16276.692414] [c0000000e8a03990] [c00000000019225c] .__generic_file_aio_write+0x2ec/0x380 
[16276.692418] [c0000000e8a03a60] [c0000000002b7d10] .ext4_file_write+0x310/0x4b0 
[16276.692424] [c0000000e8a03b70] [c000000000270a58] .aio_rw_vect_retry+0xa8/0x250 
[16276.692428] [c0000000e8a03c00] [c000000000271c28] .aio_run_iocb+0x98/0x1b0 
[16276.692432] [c0000000e8a03c90] [c0000000002731e8] .do_io_submit+0x4f8/0xb40 
[16276.692437] [c0000000e8a03e30] [c000000000009e54] syscall_exit+0x0/0x98 
[16276.692441] Instruction dump: 
[16276.692443] 409effcc e93dffa0 792a6fe3 4082fd34 4bffff0c 2fbcfdef 419e0030 e9390060  
[16276.692450] 7ee94a78 7d290074 7929d182 69290001 <0b090000> 7ee3bb78 48009b15 60000000  
[16276.692457] ---[ end trace 7cbfec9a80d76711 ]---

Then test case 224 triggered OOM and start to kill random processes,

[16346.626132] 224 invoked oom-killer: gfp_mask=0x200da, order=0, oom_score_adj=0 
[16346.626169] 224 cpuset=/ mems_allowed=0-1 
[16346.626174] Call Trace: 
[16346.626190] [c00000011000f430] [c000000000015238] .show_stack+0x78/0x1e0 (unreliable) 
[16346.626204] [c00000011000f500] [c000000000746eb8] .dump_header+0xb4/0x224 
[16346.626215] [c00000011000f5d0] [c000000000194988] .oom_kill_process+0x378/0x530 
[16346.626224] [c00000011000f6c0] [c000000000195394] .out_of_memory+0x524/0x560 
[16346.626232] [c00000011000f7a0] [c00000000019b66c] .__alloc_pages_nodemask+0x9dc/0xa10 
[16346.626243] [c00000011000f950] [c0000000001e98c8] .alloc_pages_vma+0xc8/0x1f0 
[16346.626254] [c00000011000fa10] [c0000000001bfd90] .do_wp_page+0x140/0xd70 
[16346.626262] [c00000011000fb00] [c0000000001c2a60] .handle_pte_fault+0x350/0xc80 
[16346.626271] [c00000011000fc00] [c00000000073c210] .do_page_fault+0x440/0x860 
[16346.626280] [c00000011000fe30] [c000000000009268] handle_page_fault+0x10/0x30 

Eventually, the system became deadlocked.

[16368.868816] Out of memory: Kill process 937 (gdbus) score 0 or sacrifice child 
[16392.024342] BUG: soft lockup - CPU#58 stuck for 23s! [auditd:856] 
[16392.024399] Modules linked in: binfmt_misc(F) tun(F) nfnetlink(F) ipt_ULOG(F) pppoe(F) pppox(F) ppp_generic(F) slhc(F) bluetooth(F) rfkill(F) nfc(F) atm(F) af_key(F) rds(F) af_802154(F) btrfs(F) raid6_pq(F) xor(F) vfat(F) fat(F) lockd(F) sunrpc(F) nf_conntrack_netbios_ns(F) nf_conntrack_broadcast(F) ipt_MASQUERADE(F) ip6table_mangle(F) ip6t_REJECT(F) nf_conntrack_ipv6(F) nf_defrag_ipv6(F) iptable_nat(F) nf_nat_ipv4(F) nf_nat(F) iptable_mangle(F) ipt_REJECT(F) nf_conntrack_ipv4(F) nf_defrag_ipv4(F) xt_conntrack(F) nf_conntrack(F) ebtable_filter(F) ebtables(F) ip6table_filter(F) ip6_tables(F) iptable_filter(F) ip_tables(F) sg(F) ehea(F) xfs(F) libcrc32c(F) sd_mod(F) crc_t10dif(F) ibmvscsi(F) scsi_transport_srp(F) scsi_tgt(F) dm_mirror(F) dm_region_hash(F) dm_log(F) dm_mod(F) [last unloaded: brd] 
[16392.024719] NIP: c000000000194834 LR: c000000000194828 CTR: 0000000000577c64 
[16392.024735] REGS: c00000013590b1f0 TRAP: 0901   Tainted: GF       W     (3.9.0-rc5+) 
[16392.024749] MSR: 8000000000009032 <SF,EE,ME,IR,DR,RI>  CR: 28422228  XER: 00000003 
[16392.024800] SOFTE: 1 
[16392.024806] CFAR: c000000000194918 
[16392.024813] TASK = c0000001358c36c0[856] 'auditd' THREAD: c000000135908000 CPU: 58 
GPR00: c000000000194828 c00000013590b470 c0000000010f3d98 c000000001152080  
GPR04: 0000000000000000 0000000000000000 0000000001f1aba4 0000000000000000  
GPR08: 0000000000000000 0000000000000000 c000000139c83aa8 0000000000003fef  
GPR12: 0000000028422222 c00000000edee800  
[16392.024950] NIP [c000000000194834] .oom_kill_process+0x224/0x530 
[16392.024974] LR [c000000000194828] .oom_kill_process+0x218/0x530 
[16392.024984] Call Trace: 
[16392.025006] [c00000013590b470] [c000000000194828] .oom_kill_process+0x218/0x530 (unreliable) 
[16392.025033] [c00000013590b560] [c000000000195394] .out_of_memory+0x524/0x560 
[16392.025058] [c00000013590b640] [c00000000019b66c] .__alloc_pages_nodemask+0x9dc/0xa10 
[16392.025077] [c00000013590b7f0] [c0000000001e7628] .alloc_pages_current+0xb8/0x1b0 
[16392.025098] [c00000013590b890] [c000000000190b38] .__page_cache_alloc+0x108/0x150 
[16392.025113] [c00000013590b920] [c000000000192fe0] .filemap_fault+0x250/0x500 
[16392.025131] [c00000013590ba00] [c0000000001be4ec] .__do_fault+0xbc/0x7d0 
[16392.025147] [c00000013590bb00] [c0000000001c27cc] .handle_pte_fault+0xbc/0xc80 
[16392.025165] [c00000013590bc00] [c00000000073c210] .do_page_fault+0x440/0x860 
[16392.025188] [c00000013590be30] [c000000000009268] handle_page_fault+0x10/0x30 
[16392.025213] Instruction dump: 
[16392.025229] 915f0a50 3d420006 3aeae2e8 f9010090 7ffbfb78 f9210098 3b200000 7ee3bb78  
[16392.025271] 485a57cd 60000000 e9210098 e9010090 <7f1ac378> ebba0359 7fbae800 3bbdfc98  
[16426.204306] INFO: rcu_sched self-detected stall on CPU { 58}  (t=6001 jiffies g=162056 c=162055 q=63) 
[16426.204382] Call Trace: 
[16426.204411] [c00000013590ab90] [c000000000015238] .show_stack+0x78/0x1e0 (unreliable) 
[16426.204438] [c00000013590ac60] [c00000000014bb7c] .rcu_check_callbacks+0x3dc/0x890 
[16426.204465] [c00000013590ad80] [c00000000009c5c0] .update_process_times+0x40/0x90 
[16426.204488] [c00000013590ae10] [c0000000000f8520] .tick_sched_handle.isra.11+0x20/0xa0 
[16426.204508] [c00000013590ae90] [c0000000000f878c] .tick_sched_timer+0x5c/0xa0 
[16426.204522] [c00000013590af30] [c0000000000ba3ec] .__run_hrtimer+0xac/0x290 
[16426.204546] [c00000013590afd0] [c0000000000bb488] .hrtimer_interrupt+0x138/0x3d0 
[16426.204563] [c00000013590b0d0] [c00000000001d1b4] .timer_interrupt+0x124/0x2f0 
[16426.204581] [c00000013590b180] [c0000000000024d4] decrementer_common+0x154/0x180 
[16426.204603] --- Exception: 901 at .oom_kill_process+0x224/0x530 
[16426.204603]     LR = .oom_kill_process+0x218/0x530 
[16426.204639] [c00000013590b560] [c000000000195394] .out_of_memory+0x524/0x560 
[16426.204671] [c00000013590b640] [c00000000019b66c] .__alloc_pages_nodemask+0x9dc/0xa10 
[16426.204694] [c00000013590b7f0] [c0000000001e7628] .alloc_pages_current+0xb8/0x1b0 
[16426.204712] [c00000013590b890] [c000000000190b38] .__page_cache_alloc+0x108/0x150 
[16426.204741] [c00000013590b920] [c000000000192fe0] .filemap_fault+0x250/0x500 
[16426.204756] [c00000013590ba00] [c0000000001be4ec] .__do_fault+0xbc/0x7d0 
[16426.204774] [c00000013590bb00] [c0000000001c27cc] .handle_pte_fault+0xbc/0xc80 
[16426.204792] [c00000013590bc00] [c00000000073c210] .do_page_fault+0x440/0x860 
[16426.204817] [c00000013590be30] [c000000000009268] handle_page_fault+0x10/0x30

CAI Qian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
