Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e31.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m92HMngg026569
	for <linux-mm@kvack.org>; Thu, 2 Oct 2008 13:22:49 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m92HMn35212086
	for <linux-mm@kvack.org>; Thu, 2 Oct 2008 11:22:49 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m92HMm2T029436
	for <linux-mm@kvack.org>; Thu, 2 Oct 2008 11:22:48 -0600
Subject: 2.6.27-rc8 hot memory remove panic
From: Badari Pulavarty <pbadari@us.ibm.com>
Content-Type: text/plain
Date: Thu, 02 Oct 2008 10:23:01 -0700
Message-Id: <1222968181.3419.12.camel@badari-desktop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Yasunori Goto <y-goto@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

Ran into this while testing hotplug memory remove on 2.6.27-rc8.
Never saw this earlier.

Any ideas on whats happening.

put_page_bootmem():
        BUG_ON(type >= -1);

Thanks,
Badari


------------[ cut here ]------------
kernel BUG at mm/memory_hotplug.c:78!
Oops: Exception in kernel mode, sig: 5 [#1]
SMP NR_CPUS=32 pSeries
Modules linked in:
NIP: c0000000001015b8 LR: c0000000000f50b8 CTR: c000000000121cbc
REGS: c00000005a5334b0 TRAP: 0700   Not tainted  (2.6.27-rc8)
MSR: 8000000000029032 <EE,ME,IR,DR>  CR: 24008442  XER: 00000010
TASK = c00000006f0655a0[13407] 'drmgr' THREAD: c00000005a530000 CPU: 0
GPR00: 0000000000000001 c00000005a533730 c0000000009f1290 c000000001355930 
GPR04: 0000000001730000 c000000071e00d20 c00000000028c318 0000000000000000 
GPR08: c000000000a62680 6db6db6db6db6db7 c000000000a96020 0000000000000000 
GPR12: 0000000024000482 c000000000a1a400 0000000000000000 0000000000000000 
GPR16: 00000000100d58f8 00000000100d5628 0000000010070000 0000000000000000 
GPR20: 00000000100b0670 00000000ffffffff 0000000000000000 0000000000000000 
GPR24: c0000000008ad000 0000000000000001 0000000000000000 000000000006a000 
GPR28: c000000002a2a000 0000000000000001 c000000000959ed0 c000000001355968 
NIP [c0000000001015b8] .put_page_bootmem+0x24/0x90
LR [c0000000000f50b8] .sparse_remove_one_section+0x1e4/0x21c
Call Trace:
[c00000005a533730] [c00000005a5337c0] 0xc00000005a5337c0 (unreliable)
[c00000005a5337b0] [c0000000000f50b8] .sparse_remove_one_section+0x1e4/0x21c
[c00000005a533850] [c000000000100ef8] .__remove_pages+0xf8/0x160
[c00000005a533900] [c00000000005222c] .pseries_remove_lmb+0x78/0xd0
[c00000005a533980] [c000000000052390] .pseries_memory_notifier+0x10c/0x1f0
[c00000005a533a10] [c0000000000a2874] .notifier_call_chain+0x7c/0xe4
[c00000005a533ab0] [c0000000000a2c84] .__blocking_notifier_call_chain+0x6c/0xa8
[c00000005a533b50] [c000000000049d58] .ofdt_write+0x4f4/0x804
[c00000005a533c60] [c00000000015ae60] .proc_reg_write+0xf4/0x130
[c00000005a533d00] [c000000000106c00] .vfs_write+0xe8/0x1a4
[c00000005a533d90] [c000000000106dc4] .sys_write+0x54/0x98
[c00000005a533e30] [c000000000008748] syscall_exit+0x0/0x40
Instruction dump:
ebe1fff8 7c0803a6 4e800020 7c0802a6 f8010010 f821ff81 8003000c 7c0007b4 
2f80ffff 38000001 409c0008 38000000 <0b000000> 38030008 7c2004ac 7d200028 
---[ end trace 23a803b7faaa91ee ]---


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
