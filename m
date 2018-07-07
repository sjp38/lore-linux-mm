Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 22EF46B0003
	for <linux-mm@kvack.org>; Fri,  6 Jul 2018 22:57:56 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id m2-v6so5790051plt.14
        for <linux-mm@kvack.org>; Fri, 06 Jul 2018 19:57:56 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id n123-v6si9814111pfn.9.2018.07.06.19.57.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 06 Jul 2018 19:57:54 -0700 (PDT)
Date: Fri, 6 Jul 2018 19:57:51 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: kernel BUG at mm/shmem.c:LINE!
Message-ID: <20180707025751.GA18609@bombadil.infradead.org>
References: <000000000000d624c605705e9010@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <000000000000d624c605705e9010@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: syzbot <syzbot+b8e0dfee3fd8c9012771@syzkaller.appspotmail.com>
Cc: hughd@google.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, syzkaller-bugs@googlegroups.com

On Fri, Jul 06, 2018 at 06:19:02PM -0700, syzbot wrote:
> IMPORTANT: if you fix the bug, please add the following tag to the commit:
> Reported-by: syzbot+b8e0dfee3fd8c9012771@syzkaller.appspotmail.com
> 
> raw: 02fffc0000001028 ffffea0007011dc8 ffffea0007058b48 ffff8801a7576ab8
> raw: 000000000000016e ffff8801a7588930 00000003ffffffff ffff8801d9a44c80
> page dumped because: VM_BUG_ON_PAGE(page_to_pgoff(page) != index)
> page->mem_cgroup:ffff8801d9a44c80
> ------------[ cut here ]------------
> kernel BUG at mm/shmem.c:815!
> invalid opcode: 0000 [#1] SMP KASAN
> CPU: 0 PID: 4429 Comm: syz-executor697 Not tainted 4.18.0-rc3-next-20180706+
> #1
> Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS
> Google 01/01/2011
> RIP: 0010:shmem_undo_range+0xdaa/0x29a0 mm/shmem.c:815

Pretty sure this one's mine.  At least I spotted a codepath earlier
today which could lead to it.  I'll fix it in the morning.
