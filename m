Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1DF026B02EA
	for <linux-mm@kvack.org>; Mon,  9 Jul 2018 10:36:13 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id p91-v6so10173009plb.12
        for <linux-mm@kvack.org>; Mon, 09 Jul 2018 07:36:13 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id p3-v6si14583716plr.131.2018.07.09.07.36.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 09 Jul 2018 07:36:11 -0700 (PDT)
Date: Mon, 9 Jul 2018 07:36:10 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: kernel BUG at mm/shmem.c:LINE!
Message-ID: <20180709143610.GD2662@bombadil.infradead.org>
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
> Hello,
> 
> syzbot found the following crash on:
> 
> HEAD commit:    526674536360 Add linux-next specific files for 20180706
> git tree:       linux-next
> console output: https://syzkaller.appspot.com/x/log.txt?x=116d16fc400000
> kernel config:  https://syzkaller.appspot.com/x/.config?x=c8d1cfc0cb798e48
> dashboard link: https://syzkaller.appspot.com/bug?extid=b8e0dfee3fd8c9012771
> compiler:       gcc (GCC) 8.0.1 20180413 (experimental)
> syzkaller repro:https://syzkaller.appspot.com/x/repro.syz?x=170e462c400000
> C reproducer:   https://syzkaller.appspot.com/x/repro.c?x=15f1ba2c400000
> 
> IMPORTANT: if you fix the bug, please add the following tag to the commit:
> Reported-by: syzbot+b8e0dfee3fd8c9012771@syzkaller.appspotmail.com

#syz fix: shmem: Convert shmem_add_to_page_cache to XArray
