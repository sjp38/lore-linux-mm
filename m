Date: Sun, 22 Apr 2007 02:57:10 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 00/10] per device dirty throttling -v5
Message-Id: <20070422025710.60dc9378.akpm@linux-foundation.org>
In-Reply-To: <20070420155154.898600123@chello.nl>
References: <20070420155154.898600123@chello.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, miklos@szeredi.hu, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com
List-ID: <linux-mm.kvack.org>

So after a cheerful five hours making all the new crap with which they have
inflicted me actually compile, first up is powerpc:

initcall 0xc0000000006dc650: .scsi_complete_async_scans+0x0/0x1dc() returned 0.
initcall 0xc0000000006dc650 ran for 0 msecs: .scsi_complete_async_scans+0x0/0x1dc()
Calling initcall 0xc0000000006ea1d0: .tcp_congestion_default+0x0/0x18()
initcall 0xc0000000006ea1d0: .tcp_congestion_default+0x0/0x18() returned 0.
initcall 0xc0000000006ea1d0 ran for 0 msecs: .tcp_congestion_default+0x0/0x18()
Freeing unused kernel memory: 292k freed
EXT3-fs: INFO: recovery required on readonly filesystem.
EXT3-fs: write access will be enabled during recovery.
Unable to handle kernel paging request for data at address 0x0000000f
Faulting instruction address: 0xc0000000001d060c
Oops: Kernel access of bad area, sig: 11 [#1]
SMP NR_CPUS=4 PowerMac
Modules linked in:
NIP: c0000000001d060c LR: c0000000000aaecc CTR: 0000000000000000
REGS: c0000000080f70c0 TRAP: 0300   Tainted: G      D  (2.6.21-rc7-mm1)
MSR: 9000000000009032 <EE,ME,IR,DR>  CR: 24024028  XER: 000fffff
DAR: 000000000000000f, DSISR: 0000000040000000
TASK = c0000000080e47f0[1] 'init' THREAD: c0000000080f4000 CPU: 2
GPR00: c0000000000aaecc c0000000080f7340 c0000000006f69f8 c00000000c45d768 
GPR04: 0000000000000001 0000000000000000 c00000000064e700 c00000000064e030 
GPR08: 0000000000000030 ffffffffffffffff 0000000000000013 0000000000000010 
GPR12: 0000000024024024 c000000000628980 0000000000000000 c0000000090090d8 
GPR16: c0000000090090c0 c0000000090090a8 0000000000000000 0000000000000000 
GPR20: 0000000000000000 c000000000733cd0 0000000000000000 0000000000000002 
GPR24: c0000000080f7630 000000000007ccde c000000009858908 c00000000984400c 
GPR28: c00000000c45d768 c00000000bc2bcb0 c000000000658aa0 c000000002372818 
NIP [c0000000001d060c] .percpu_counter_mod+0x2c/0xd8
LR [c0000000000aaecc] .__set_page_dirty_nobuffers+0x14c/0x17c
Call Trace:
[c0000000080f7340] [c0000000001088e4] .alloc_page_buffers+0x58/0x100 (unreliable)
[c0000000080f73d0] [c0000000000aaecc] .__set_page_dirty_nobuffers+0x14c/0x17c
[c0000000080f7460] [c000000000106328] .mark_buffer_dirty+0x5c/0x70
[c0000000080f74e0] [c00000000015efb8] .do_one_pass+0x55c/0x6a8
[c0000000080f75c0] [c00000000015f3f8] .journal_recover+0x1c0/0x1c8
[c0000000080f7670] [c000000000164178] .journal_load+0xcc/0x178
[c0000000080f7700] [c000000000151134] .ext3_fill_super+0xfc0/0x1a44
[c0000000080f7840] [c0000000000d8554] .get_sb_bdev+0x200/0x260
[c0000000080f7920] [c000000000152454] .ext3_get_sb+0x20/0x38
[c0000000080f79a0] [c0000000000d8900] .vfs_kern_mount+0x80/0x108
[c0000000080f7a40] [c0000000000f7a94] .do_mount+0x2e4/0x930
[c0000000080f7d60] [c00000000011a4f4] .compat_sys_mount+0xf4/0x2b0
[c0000000080f7e30] [c00000000000872c] syscall_exit+0x0/0x40
Instruction dump:
4bffff00 7c0802a6 fb81ffe0 fbe1fff8 fba1ffe8 7c7c1b78 f8010010 f821ff71 
a16d000a e9230010 796b1f24 7d2948f8 <7fab482a> 801d0000 7c002214 7c1f07b4 
DART table allocated at: c00000007f000000

I'll drop 'em.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
