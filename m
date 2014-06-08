Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f50.google.com (mail-yh0-f50.google.com [209.85.213.50])
	by kanga.kvack.org (Postfix) with ESMTP id 92EF26B0031
	for <linux-mm@kvack.org>; Sat,  7 Jun 2014 23:33:53 -0400 (EDT)
Received: by mail-yh0-f50.google.com with SMTP id 29so1665605yhl.9
        for <linux-mm@kvack.org>; Sat, 07 Jun 2014 20:33:53 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id u74si16394154yha.48.2014.06.07.20.33.52
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sat, 07 Jun 2014 20:33:52 -0700 (PDT)
Message-ID: <5393D995.8010805@oracle.com>
Date: Sat, 07 Jun 2014 23:33:41 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: mm,x86: warning at arch/x86/mm/pat.c:781 untrack_pfn+0x65/0xb0()
References: <5347E4FB.2090705@oracle.com>
In-Reply-To: <5347E4FB.2090705@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <koct9i@gmail.com>, suresh.b.siddha@intel.com, Ingo Molnar <mingo@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, LKML <linux-kernel@vger.kernel.org>, Dave Jones <davej@redhat.com>

On 04/11/2014 08:50 AM, Sasha Levin wrote:
> Hi all,
> 
> While fuzzing with trinity inside a KVM tools guest running the latest -next
> kernel I've stumbled on the following:

Ping? Still happening (rarely on -next):

[ 5818.038245] WARNING: CPU: 4 PID: 22726 at arch/x86/mm/pat.c:781 untrack_pfn+0x65/0xb0()
[ 5818.044203] Modules linked in:
[ 5818.045172] CPU: 4 PID: 22726 Comm: trinity-c239 Tainted: G        W     3.15.0-rc8-next-20140606-sasha-00021-ga9d3a0b-dirty #596
[ 5818.048317]  0000000000000009 ffff8800024d3be8 ffffffff9e50fe6b 0000000000000001
[ 5818.050516]  0000000000000000 ffff8800024d3c28 ffffffff9b15f96c ffff8800024d3c38
[ 5818.052567]  ffff88000203f400 0000000000000000 ffff8800024d3d68 ffff8800024d3d68
[ 5818.053785] Call Trace:
[ 5818.054483] dump_stack (lib/dump_stack.c:52)
[ 5818.055586] warn_slowpath_common (kernel/panic.c:430)
[ 5818.056763] warn_slowpath_null (kernel/panic.c:465)
[ 5818.057789] untrack_pfn (arch/x86/mm/pat.c:781 (discriminator 3))
[ 5818.059412] unmap_single_vma (mm/memory.c:1327)
[ 5818.061530] ? pagevec_lru_move_fn (include/linux/pagevec.h:44 mm/swap.c:435)
[ 5818.063412] unmap_vmas (mm/memory.c:1377 (discriminator 1))
[ 5818.064610] unmap_region (mm/mmap.c:2363 (discriminator 3))
[ 5818.065453] ? validate_mm_rb (mm/mmap.c:404)
[ 5818.066422] ? vma_rb_erase (mm/mmap.c:449 include/linux/rbtree_augmented.h:219 include/linux/rbtree_augmented.h:227 mm/mmap.c:488)
[ 5818.067316] do_munmap (mm/mmap.c:3359 mm/mmap.c:2561)
[ 5818.068126] move_vma (mm/mremap.c:313)
[ 5818.069000] SyS_mremap (mm/mremap.c:446 mm/mremap.c:508 mm/mremap.c:477)
[ 5818.069839] tracesys (arch/x86/kernel/entry_64.S:542)


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
