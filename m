Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 806766B02C4
	for <linux-mm@kvack.org>; Tue,  2 May 2017 16:13:23 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id o4so35267596qkb.5
        for <linux-mm@kvack.org>; Tue, 02 May 2017 13:13:23 -0700 (PDT)
Received: from scorn.kernelslacker.org (scorn.kernelslacker.org. [2600:3c03::f03c:91ff:fe59:ec69])
        by mx.google.com with ESMTPS id a41si18282993qte.176.2017.05.02.13.13.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 May 2017 13:13:22 -0700 (PDT)
Date: Tue, 2 May 2017 16:13:21 -0400
From: Dave Jones <davej@codemonkey.org.uk>
Subject: WARNING: CPU: 2 PID: 23409 at mm/filemap.c:260
 __delete_from_page_cache+0x5fc/0x610
Message-ID: <20170502201321.vfqmsb5ncsxaypoe@codemonkey.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Linux Kernel <linux-kernel@vger.kernel.org>

Just hit this on Linus tree pulled this afternoon.

WARNING: CPU: 2 PID: 23409 at mm/filemap.c:260 __delete_from_page_cache+0x5fc/0x610
CPU: 2 PID: 23409 Comm: trinity-c1 Not tainted 4.11.0-think+ #4 
Call Trace:
 dump_stack+0x68/0x93
 __warn+0xcb/0xf0
 warn_slowpath_null+0x1d/0x20
 __delete_from_page_cache+0x5fc/0x610
 delete_from_page_cache+0x57/0x150
 truncate_inode_page+0x9f/0x140
 shmem_undo_range+0x4c5/0xcd0
 shmem_truncate_range+0x16/0x40
 shmem_fallocate+0x22a/0x610
 vfs_fallocate+0x135/0x250
 SyS_madvise+0x211/0xa90
 ? get_lock_stats+0x19/0x50
 do_syscall_64+0x66/0x1d0
 ? do_syscall_64+0x66/0x1d0
 entry_SYSCALL64_slow_path+0x25/0x25
RIP: 0033:0x7f596e520099
RSP: 002b:00007fff1b76d928 EFLAGS: 00000246
 ORIG_RAX: 000000000000001c
RAX: ffffffffffffffda RBX: 000000000000001c RCX: 00007f596e520099
RDX: 0000000000000009 RSI: 00000000000fc000 RDI: 00007f596c88b000
RBP: 00007fff1b76d9d0 R08: 0000000000001d1d R09: 0000c1c1c1c1c1c1
R10: 759e2c3076d8be38 R11: 0000000000000246 R12: 0000000000000002
R13: 00007f596ebe8048 R14: 00007f596ebf6ad8 R15: 00007f596ebe8000



 260         if (WARN_ON_ONCE(PageDirty(page)))
 261                 account_page_cleaned(page, mapping, inode_to_wb(mapping->host));


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
