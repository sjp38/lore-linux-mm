Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7A23E6B0007
	for <linux-mm@kvack.org>; Thu,  1 Feb 2018 23:50:31 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id w10so2662771wrg.2
        for <linux-mm@kvack.org>; Thu, 01 Feb 2018 20:50:31 -0800 (PST)
Received: from ZenIV.linux.org.uk (zeniv.linux.org.uk. [195.92.253.2])
        by mx.google.com with ESMTPS id q61si995608wrb.483.2018.02.01.20.50.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Feb 2018 20:50:30 -0800 (PST)
Date: Fri, 2 Feb 2018 04:50:20 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: possible deadlock in get_user_pages_unlocked
Message-ID: <20180202045020.GF30522@ZenIV.linux.org.uk>
References: <001a113f6344393d89056430347d@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <001a113f6344393d89056430347d@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: syzbot <syzbot+bacbe5d8791f30c9cee5@syzkaller.appspotmail.com>
Cc: akpm@linux-foundation.org, aneesh.kumar@linux.vnet.ibm.com, dan.j.williams@intel.com, james.morse@arm.com, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mingo@kernel.org, syzkaller-bugs@googlegroups.com

On Thu, Feb 01, 2018 at 04:58:00PM -0800, syzbot wrote:
> Hello,
> 
> syzbot hit the following crash on upstream commit
> 7109a04eae81c41ed529da9f3c48c3655ccea741 (Thu Feb 1 17:37:30 2018 +0000)
> Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/ide
> 
> So far this crash happened 2 times on upstream.
> C reproducer is attached.

Umm...  How reproducible that is?

> syzkaller reproducer is attached.
> Raw console output is attached.
> compiler: gcc (GCC) 7.1.1 20170620
> .config is attached.

Can't reproduce with gcc 5.4.1 (same .config, same C reproducer).

It looks like __get_user_pages_locked() returning with *locked zeroed,
but ->mmap_sem not dropped.  I don't see what could've lead to it and
attempts to reproduce had not succeeded so far...

How long does it normally take for lockdep splat to trigger?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
