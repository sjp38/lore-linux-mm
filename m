Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5DD046B0069
	for <linux-mm@kvack.org>; Tue, 26 Sep 2017 11:37:53 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id b43so1967025wrg.5
        for <linux-mm@kvack.org>; Tue, 26 Sep 2017 08:37:53 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r70si7502837wrb.45.2017.09.26.08.37.51
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 26 Sep 2017 08:37:51 -0700 (PDT)
From: Luis Henriques <lhenriques@suse.com>
Subject: percpu allocation failures
Date: Tue, 26 Sep 2017 16:37:49 +0100
Message-ID: <87efqttqr6.fsf@hermes>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>, Dennis Zhou <dennisszhou@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi,

Probably already reported, but I couldn't find anything so here it
goes:

starting with 4.14-rc1 I see the following during boot:

[   25.199053] percpu: allocation failed, size=16 align=16 atomic=0, alloc from reserved chunk failed
[   25.200195] CPU: 5 PID: 723 Comm: modprobe Tainted: G            E   4.14.0-rc2 #103
[   25.201290] Hardware name: Dell Inc. Precision 5510/0N8J4R, BIOS 1.2.25 05/07/2017
[   25.202430] Call Trace:
[   25.203509]  dump_stack+0x63/0x89
[   25.204364]  pcpu_alloc+0x5cd/0x5f0
[   25.205302]  __alloc_reserved_percpu+0x18/0x20
[   25.206355]  load_module+0x733/0x2c00
[   25.207444]  ? kernel_read_file+0x1a3/0x1d0
[   25.208596]  SYSC_finit_module+0xfc/0x120
[   25.209634]  ? SYSC_finit_module+0xfc/0x120
[   25.210733]  SyS_finit_module+0xe/0x10
[   25.211747]  entry_SYSCALL_64_fastpath+0x1e/0xa9
[   25.212763] RIP: 0033:0x7f70d9e86219
[   25.213508] RSP: 002b:00007ffcd3ff8f38 EFLAGS: 00000246 ORIG_RAX: 0000000000000139
[   25.214391] RAX: ffffffffffffffda RBX: 0000000000000000 RCX: 00007f70d9e86219
[   25.215107] RDX: 0000000000000000 RSI: 00005642ddf158cc RDI: 0000000000000000
[   25.215949] RBP: 00007ffcd3ff7f30 R08: 0000000000000000 R09: 0000000000000001
[   25.216592] R10: 0000000000000000 R11: 0000000000000246 R12: 0000000000000005
[   25.217194] R13: 00005642de3d65f0 R14: 00007ffcd3ff7f10 R15: 0000000000000005
[   25.217812] nft_meta: Could not allocate 16 bytes percpu data

A few more failures follow.

A bisect ended up with the merge commit a7cbfd05f427 ("Merge branch
'for-4.14' of git://git.kernel.org/pub/scm/linux/kernel/git/tj/percpu").

Cheers,
-- 
Luis

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
