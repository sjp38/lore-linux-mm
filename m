From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [3.10-rc1 SLUB?] kmemcheck reports read from freed/unallocated memory
Date: Tue, 14 May 2013 21:06:06 +0900
Message-ID: <201305142106.AAG35418.JOSFOLFMHOFVQt@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-Id: linux-mm.kvack.org

I got below warning. The problem might be in SLUB code.

  WARNING: kmemcheck: Caught 64-bit read from freed memory (ffff88007a1297a0)
  6098127a0088ffff0000000001000000c0c6fe790088ffff0800000000000000
   f f f f f f f f f f f f f f f f f f f f f f f f f f f f f f f f
   ^
  RIP: 0010:[<ffffffff8113e023>]  [<ffffffff8113e023>] __kmalloc+0xb3/0x1a0
  RSP: 0018:ffff880079a17be8  EFLAGS: 00010246
  RAX: 0000000000000000 RBX: 0000000000000010 RCX: ffff88007b9d5580
  RDX: 0000000000000427 RSI: ffffffff81c23600 RDI: 00000000001d5580
  RBP: ffff880079a17c18 R08: ffff880079a16000 R09: 0000000000000001
  R10: 0000000000000000 R11: 0000000000000004 R12: ffff88007ac03c80
  R13: 00000000000000d0 R14: ffff88007a1297a0 R15: ffffffff8119a5bd
  FS:  00007f1b62687700(0000) GS:ffff88007b200000(0000) knlGS:0000000000000000
  CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
  CR2: ffff88007a6346c8 CR3: 0000000073cc0000 CR4: 00000000000407f0
  DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
  DR3: 0000000000000000 DR6: 00000000ffff4ff0 DR7: 0000000000000400
   [<ffffffff8119a5bd>] load_elf_binary+0x29d/0xe70
   [<ffffffff8114dd9f>] search_binary_handler+0x1af/0x400
   [<ffffffff811989fc>] load_script+0x24c/0x290
   [<ffffffff8114dd9f>] search_binary_handler+0x1af/0x400
   [<ffffffff8114fd16>] do_execve_common+0x2a6/0x370
   [<ffffffff8114fde9>] do_execve+0x9/0x10
   [<ffffffff8114fe28>] SyS_execve+0x38/0x60
   [<ffffffff817a7b09>] stub_execve+0x69/0xa0
   [<ffffffffffffffff>] 0xffffffffffffffff

Kernel config is at http://I-love.SAKURA.ne.jp/tmp/config-3.10-rc1-kmemcheck
Full dmesg is at http://I-love.SAKURA.ne.jp/tmp/dmesg-3.10-rc1-kmemcheck.txt

Regards.
