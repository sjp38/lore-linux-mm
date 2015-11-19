Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id AA6DD6B0255
	for <linux-mm@kvack.org>; Thu, 19 Nov 2015 05:10:45 -0500 (EST)
Received: by padhx2 with SMTP id hx2so76822477pad.1
        for <linux-mm@kvack.org>; Thu, 19 Nov 2015 02:10:45 -0800 (PST)
Received: from mail-pa0-x22f.google.com (mail-pa0-x22f.google.com. [2607:f8b0:400e:c03::22f])
        by mx.google.com with ESMTPS id fu6si10873314pac.175.2015.11.19.02.10.44
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Nov 2015 02:10:44 -0800 (PST)
Received: by pacdm15 with SMTP id dm15so76847450pac.3
        for <linux-mm@kvack.org>; Thu, 19 Nov 2015 02:10:44 -0800 (PST)
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.0 \(3094\))
Subject: Re: kernel oops on mmotm-2015-10-15-15-20
From: yalin wang <yalin.wang2010@gmail.com>
In-Reply-To: <20151119065827.GA26601@node.shutemov.name>
Date: Thu, 19 Nov 2015 18:10:37 +0800
Content-Transfer-Encoding: quoted-printable
Message-Id: <AA499405-278E-430F-80E0-E19877FBCA87@gmail.com>
References: <20151105001922.GD7357@bbox> <20151108225522.GA29600@node.shutemov.name> <20151112003614.GA5235@bbox> <20151116014521.GA7973@bbox> <20151116084522.GA9778@node.shutemov.name> <20151116103220.GA32578@bbox> <20151116105452.GA10575@node.shutemov.name> <20151117073539.GB32578@bbox> <20151117093213.GA16243@node.shutemov.name> <20151119021221.GA15540@bbox> <20151119065827.GA26601@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Minchan Kim <minchan@kernel.org>, Hugh Dickins <hughd@google.com>, Sasha Levin <sasha.levin@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>


> On Nov 19, 2015, at 14:58, Kirill A. Shutemov <kirill@shutemov.name> =
wrote:
>=20
> uncharged
i also encounter this crash ,

also  i encounter a crash like this in qemu:


[    2.703436] [<ffffffc0001d4d2c>] =
do_execveat_common.isra.36+0x4f0/0x630
[    2.703624] [<ffffffc0001d4e90>] do_execve+0x24/0x30
[    2.703767] [<ffffffc0001d50e0>] SyS_execve+0x1c/0x2c
[    2.703923] BUG: Bad page map in process init  pte:6000004837ebd3 =
pmd:b29e7003
[    2.704140] page:ffffffc07f00af80 count:2 mapcount:-1 mapping:        =
  (null) index:0x1
[    2.704414] flags: 0x400000000014(referenced|dirty)
[    2.704563] page dumped because: bad pte
[    2.704666] addr:0000007fafb7e000 vm_flags:00100073 =
anon_vma:ffffffc0729bdb90 mapping:          (null) index:7fafb7e
[    2.704906] file:          (null) fault:          (null) mmap:        =
  (null) readpage:          (null)
[    2.705117] CPU: 0 PID: 84 Comm: init Tainted: G    B           =
4.2.0ajb-00005-g11a9bf3 #80
[    2.705315] Hardware name: ranchu (DT)
[    2.705408] Call trace:
[    2.705488] [<ffffffc000089ea0>] dump_backtrace+0x0/0x124
[    2.705657] [<ffffffc000089fd4>] show_stack+0x10/0x1c
[    2.705797] [<ffffffc0005f1df0>] dump_stack+0x78/0x98
[    2.705971] [<ffffffc00018a8d4>] print_bad_pte+0x154/0x1f0
[    2.706102] [<ffffffc00018c5f4>] unmap_single_vma+0x574/0x704
[    2.706236] [<ffffffc00018d0a4>] unmap_vmas+0x54/0x70
[    2.706354] [<ffffffc000195e70>] exit_mmap+0x88/0xfc
[    2.706473] [<ffffffc000097af4>] mmput+0x48/0xe8
[    2.706584] [<ffffffc0001d3b64>] flush_old_exec+0x30c/0x79c
[    2.706719] [<ffffffc000225fa4>] load_elf_binary+0x21c/0x1098
[    2.706856] [<ffffffc0001d4330>] search_binary_handler+0xa8/0x224
[    2.706995] [<ffffffc0001d4d2c>] =
do_execveat_common.isra.36+0x4f0/0x630
[    2.707144] [<ffffffc0001d4e90>] do_execve+0x24/0x30
[    2.707263] [<ffffffc0001d50e0>] SyS_execve+0x1c/0x2c
[    2.707392] BUG: Bad page map in process init  pte:6000004837fbd3 =
pmd:b29e7003
[    2.707752] page:ffffffc07f00afc0 count:2 mapcount:-1 mapping:        =
  (null) index:0x1
[    2.708167] flags: 0x400000000014(referenced|dirty)
[    2.708333] page dumped because: bad pte
[    2.708501] addr:0000007fafb7f000 vm_flags:00100073 =
anon_vma:ffffffc0729bdb90 mapping:          (null) index:7fafb7f
[    2.709084] file:          (null) fault:          (null) mmap:        =
  (null) readpage:          (null)
[    2.709306] CPU: 0 PID: 84 Comm: init Tainted: G    B           =
4.2.0ajb-00005-g11a9bf3 #80
[    2.709494] Hardware name: ranchu (DT)

seems the page map count is not correct ..
i build is based on mmotm-2015-10-21-14-41

Thanks



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
