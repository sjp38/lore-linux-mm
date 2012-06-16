Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id E6BDC6B0068
	for <linux-mm@kvack.org>; Sat, 16 Jun 2012 04:14:27 -0400 (EDT)
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <glkm-linux-mm-2@m.gmane.org>)
	id 1Sfo9F-0008Vk-Ma
	for linux-mm@kvack.org; Sat, 16 Jun 2012 10:14:21 +0200
Received: from 117.69.231.147 ([117.69.231.147])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Sat, 16 Jun 2012 10:14:21 +0200
Received: from xiyou.wangcong by 117.69.231.147 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Sat, 16 Jun 2012 10:14:21 +0200
From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH 02.5] mm: sl[au]b: first remove PFMEMALLOC flag then
 SLAB flag
Date: Sat, 16 Jun 2012 08:14:10 +0000 (UTC)
Message-ID: <jrhf8i$rj4$1@dough.gmane.org>
References: <1337266231-8031-1-git-send-email-mgorman@suse.de>
 <1337266231-8031-3-git-send-email-mgorman@suse.de>
 <20120615155432.GA5498@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org

On Fri, 15 Jun 2012 at 15:54 GMT, Sebastian Andrzej Siewior <sebastian@breakpoint.cc> wrote:
> From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
>
> If we first remove the SLAB flag followed by the PFMEMALLOC flag then the
> removal of the latter will trigger the VM_BUG_ON() as it can be seen in
>| kernel BUG at include/linux/page-flags.h:474!
>| invalid opcode: 0000 [#1] PREEMPT SMP
>| Call Trace:
>|  [<c10e2d77>] slab_destroy+0x27/0x70
>|  [<c10e3285>] drain_freelist+0x55/0x90
>|  [<c10e344e>] __cache_shrink+0x6e/0x90
>|  [<c14e3211>] ? acpi_sleep_init+0xcf/0xcf
>|  [<c10e349d>] kmem_cache_shrink+0x2d/0x40
>
> because the SLAB flag is gone. This patch simply changes the order.
>

It would be nicer if we add some comments in the code. ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
