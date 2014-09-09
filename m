Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 60AA66B003C
	for <linux-mm@kvack.org>; Tue,  9 Sep 2014 10:25:52 -0400 (EDT)
Received: by mail-pd0-f182.google.com with SMTP id w10so4150381pde.27
        for <linux-mm@kvack.org>; Tue, 09 Sep 2014 07:25:51 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id v9si633931pdp.136.2014.09.09.07.25.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 09 Sep 2014 07:25:51 -0700 (PDT)
Message-ID: <540F0DE7.2070609@oracle.com>
Date: Tue, 09 Sep 2014 10:25:43 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: mm: WARN at mm/vmalloc.c:130 vmap_page_range_noflush
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, liwanp@linux.vnet.ibm.com, Dave Jones <davej@redhat.com>, LKML <linux-kernel@vger.kernel.org>

Hi all,

While fuzzing with trinity inside a KVM tools guest running the latest -next
kernel, I've stumbled on the following spew:

[ 1219.823164] WARNING: CPU: 19 PID: 9384 at mm/vmalloc.c:130 vmap_page_range_noflush+0x2f9/0x3b0()
[ 1219.823170] Modules linked in:
[ 1219.823178] CPU: 19 PID: 9384 Comm: trinity-c349 Not tainted 3.17.0-rc4-next-20140909-sasha-00032-gc16d47b #1131
[ 1219.823184]  0000000000000009 ffff8801bff47d60 ffffffffb24c5ec5 0000000000000000
[ 1219.823190]  ffff8801bff47d98 ffffffffaf16e4fd ffffc90082000000 0000000000037600
[ 1219.823195]  ffff880779badd70 ffffc90009527000 ffffc90081fae000 ffff8801bff47da8
[ 1219.823197] Call Trace:
[ 1219.823211] dump_stack (lib/dump_stack.c:52)
[ 1219.823225] warn_slowpath_common (kernel/panic.c:432)
[ 1219.823232] warn_slowpath_null (kernel/panic.c:466)
[ 1219.823237] vmap_page_range_noflush (mm/vmalloc.c:130 mm/vmalloc.c:149 mm/vmalloc.c:166 mm/vmalloc.c:191)
[ 1219.823245] map_vm_area (mm/vmalloc.c:1281)
[ 1219.823250] __vmalloc_node_range (mm/vmalloc.c:1605 mm/vmalloc.c:1649)
[ 1219.823260] ? SyS_init_module (kernel/module.c:2500 kernel/module.c:3351 kernel/module.c:3338)
[ 1219.823266] vmalloc (mm/vmalloc.c:1724)
[ 1219.823271] ? SyS_init_module (kernel/module.c:2500 kernel/module.c:3351 kernel/module.c:3338)
[ 1219.823276] SyS_init_module (kernel/module.c:2500 kernel/module.c:3351 kernel/module.c:3338)
[ 1219.823285] tracesys (arch/x86/kernel/entry_64.S:542)


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
