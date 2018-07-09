Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2C25A6B02AF
	for <linux-mm@kvack.org>; Mon,  9 Jul 2018 06:26:25 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id ba8-v6so9864230plb.4
        for <linux-mm@kvack.org>; Mon, 09 Jul 2018 03:26:25 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c198-v6sor3259007pga.143.2018.07.09.03.26.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 09 Jul 2018 03:26:23 -0700 (PDT)
Date: Mon, 9 Jul 2018 13:15:58 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: kernel BUG at mm/memory.c:LINE!
Message-ID: <20180709101558.63vkwppwcgzcv3dg@kshutemo-mobl1>
References: <0000000000004a7da505708a9915@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0000000000004a7da505708a9915@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: syzbot <syzbot+3f84280d52be9b7083cc@syzkaller.appspotmail.com>
Cc: akpm@linux-foundation.org, dan.j.williams@intel.com, jglisse@redhat.com, kirill.shutemov@linux.intel.com, ldufour@linux.vnet.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.com, minchan@kernel.org, ross.zwisler@linux.intel.com, syzkaller-bugs@googlegroups.com, willy@infradead.org, ying.huang@intel.com

On Sun, Jul 08, 2018 at 10:51:03PM -0700, syzbot wrote:
> Hello,
> 
> syzbot found the following crash on:
> 
> HEAD commit:    b2d44d145d2a Merge tag '4.18-rc3-smb3fixes' of git://git.s..
> git tree:       upstream
> console output: https://syzkaller.appspot.com/x/log.txt?x=11d07748400000
> kernel config:  https://syzkaller.appspot.com/x/.config?x=2ca6c7a31d407f86
> dashboard link: https://syzkaller.appspot.com/bug?extid=3f84280d52be9b7083cc
> compiler:       gcc (GCC) 8.0.1 20180413 (experimental)
> 
> Unfortunately, I don't have any reproducer for this crash yet.
> 
> IMPORTANT: if you fix the bug, please add the following tag to the commit:
> Reported-by: syzbot+3f84280d52be9b7083cc@syzkaller.appspotmail.com
> 
> next ffff8801ce5e7040 prev ffff8801d20eca50 mm ffff88019c1e13c0
> prot 27 anon_vma ffff88019680cdd8 vm_ops 0000000000000000
> pgoff 0 file ffff8801b2ec2d00 private_data 0000000000000000
> flags: 0xff(read|write|exec|shared|mayread|maywrite|mayexec|mayshare)
> ------------[ cut here ]------------
> kernel BUG at mm/memory.c:1422!

Looks like vma_is_anonymous() false-positive.

Any clues what file is it? I would guess some kind of socket, but it's not
clear from log which exactly.

-- 
 Kirill A. Shutemov
