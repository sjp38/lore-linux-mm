Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 58A936B000E
	for <linux-mm@kvack.org>; Tue,  3 Jul 2018 12:26:49 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id e5-v6so1260435wro.2
        for <linux-mm@kvack.org>; Tue, 03 Jul 2018 09:26:49 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p74-v6sor616661wmd.19.2018.07.03.09.26.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 03 Jul 2018 09:26:47 -0700 (PDT)
Subject: Re: [lkp-robot] ee410f15b1 BUG: kernel hang in boot stage
References: <20180703025155.GD32173@nfs>
From: Thierry Escande <thierry.escande@linaro.org>
Message-ID: <a96b7164-244f-a5a3-2940-3a9d82a76630@linaro.org>
Date: Tue, 3 Jul 2018 18:26:46 +0200
MIME-Version: 1.0
In-Reply-To: <20180703025155.GD32173@nfs>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kernel test robot <lkp@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-kernel@vger.kernel.org, LKP <lkp@01.org>

On 03/07/2018 04:51, kernel test robot wrote:
> 
> Greetings,
> 
> 0day kernel testing robot got the below dmesg and the first bad commit is
> 
> https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git master
> 
> commit ee410f15b1418f2f4428e79980674c979081bcb7
> Author:     Thierry Escande <thierry.escande@linaro.org>
> AuthorDate: Thu Jun 14 15:28:15 2018 -0700
> Commit:     Linus Torvalds <torvalds@linux-foundation.org>
> CommitDate: Fri Jun 15 07:55:25 2018 +0900
> 
>      lib/test_printf.c: call wait_for_random_bytes() before plain %p tests

This patch is already reverted in Linus tree. It's also been superseded 
in linux-next by a new version.

Regards,
Thierry

>      
>      If the test_printf module is loaded before the crng is initialized, the
>      plain 'p' tests will fail because the printed address will not be hashed
>      and the buffer will contain '(ptrval)' instead.
>      
>      This patch adds a call to wait_for_random_bytes() before plain 'p' tests
>      to make sure the crng is initialized.
>      
>      Link: http://lkml.kernel.org/r/20180604113708.11554-1-thierry.escande@linaro.org
>      Signed-off-by: Thierry Escande <thierry.escande@linaro.org>
>      Acked-by: Tobin C. Harding <me@tobin.cc>
>      Reviewed-by: Andrew Morton <akpm@linux-foundation.org>
>      Cc: David Miller <davem@davemloft.net>
>      Cc: Rasmus Villemoes <linux@rasmusvillemoes.dk>
>      Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
>      Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
> 
> 608dbdfb1f  hexagon: drop the unused variable zero_page_mask
> ee410f15b1  lib/test_printf.c: call wait_for_random_bytes() before plain %p tests
> 883c9ab9eb  Merge branch 'parisc-4.18-1' of git://git.kernel.org/pub/scm/linux/kernel/git/deller/parisc-linux
> e3c7283c19  Add linux-next specific files for 20180629
> +-------------------------------+------------+------------+------------+---------------+
> |                               | 608dbdfb1f | ee410f15b1 | 883c9ab9eb | next-20180629 |
> +-------------------------------+------------+------------+------------+---------------+
> | boot_successes                | 35         | 0          | 19         | 13            |
> | boot_failures                 | 0          | 15         |            |               |
> | BUG:kernel_hang_in_boot_stage | 0          | 15         |            |               |
> +-------------------------------+------------+------------+------------+---------------+
> 
> [    9.488584] -------------
> [    9.491008] Testing concurrent rhashtable access from 10 threads
> [   21.577749] test 3125 add/delete pairs into rhlist
> [   21.734553] test 3125 random rhlist add/delete operations
> [   21.813107] Started 10 threads, 0 failed, rhltable test returns 0
> BUG: kernel hang in boot stage
> 
> 
>                                                            # HH:MM RESULT GOOD BAD GOOD_BUT_DIRTY DIRTY_NOT_BAD
> git bisect start 7daf201d7fe8334e2d2364d4e8ed3394ec9af819 v4.17 --
> git bisect good a16afaf7928b74c30a4727cdcaa67bd10675a55d  # 08:00  G     11     0    0   0  Merge tag 'for-v4.18' of git://git.kernel.org/pub/scm/linux/kernel/git/sre/linux-power-supply
> git bisect good dc594c39f7a9dcdfd5dbb1a446ac6d06182e2472  # 08:13  G     11     0    0   0  Merge tag 'ceph-for-4.18-rc1' of git://github.com/ceph/ceph-client
> git bisect  bad 81e97f01371f4e1701feeafe484665112cd9ddc2  # 08:33  B      0     1   15   0  Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/jikos/hid
> git bisect  bad 35773c93817c5f2df264d013978e7551056a063a  # 08:55  B      0     1   15   0  Merge branch 'afs-proc' of git://git.kernel.org/pub/scm/linux/kernel/git/viro/vfs
> git bisect  bad 8949170cf48e91da7e4e69a59e2842d81d9a5885  # 09:26  B      0     1   15   0  Merge tag 'for-linus' of git://git.kernel.org/pub/scm/virt/kvm/kvm
> git bisect  bad becfc5e97cbab00b25a592aabc36838ec7217d1f  # 09:49  B      0    10   24   0  Merge tag 'drm-next-2018-06-15' of git://anongit.freedesktop.org/drm/drm
> git bisect good 7a932516f55cdf430c7cce78df2010ff7db6b874  # 10:21  G     11     0    0   0  Merge tag 'vfs-timespec64' of git://git.kernel.org/pub/scm/linux/kernel/git/arnd/playground
> git bisect  bad b5d903c2d656e9bc54bc76554a477d796a63120d  # 10:44  B      0     1   15   0  Merge branch 'akpm' (patches from Andrew)
> git bisect good 3fb3894b84c2e0f83cb1e4f4e960243742e6b3a6  # 11:06  G     10     0    0   0  kernel/relay.c: change return type to vm_fault_t
> git bisect good 14f28f5776927be30717986f86b765d49eec392c  # 11:20  G     10     0    0   0  ipc: use new return type vm_fault_t
> git bisect good fe6bdfc8e1e131720abbe77a2eb990c94c9024cb  # 11:44  G     10     0    0   0  mm: fix oom_kill event handling
> git bisect good 608dbdfb1f0299f4500e56d62b0d84c44dcfa3be  # 11:56  G     11     0    0   0  hexagon: drop the unused variable zero_page_mask
> git bisect  bad ee410f15b1418f2f4428e79980674c979081bcb7  # 12:16  B      0     1   15   0  lib/test_printf.c: call wait_for_random_bytes() before plain %p tests
> # first bad commit: [ee410f15b1418f2f4428e79980674c979081bcb7] lib/test_printf.c: call wait_for_random_bytes() before plain %p tests
> git bisect good 608dbdfb1f0299f4500e56d62b0d84c44dcfa3be  # 12:42  G     30     0    0   0  hexagon: drop the unused variable zero_page_mask
> # extra tests with debug options
> git bisect  bad ee410f15b1418f2f4428e79980674c979081bcb7  # 13:00  B      0    11   25   0  lib/test_printf.c: call wait_for_random_bytes() before plain %p tests
> # extra tests on HEAD of linux-devel/devel-catchup-201807010645
> git bisect  bad 52e245677317cd2f35888d20fbdf8f72f1b62841  # 13:00  B      0    33   50   0  0day head guard for 'devel-catchup-201807010645'
> # extra tests on tree/branch linus/master
> git bisect good 883c9ab9eb595f8542d01e55d29a346c8d96862e  # 13:12  G     11     0    0   0  Merge branch 'parisc-4.18-1' of git://git.kernel.org/pub/scm/linux/kernel/git/deller/parisc-linux
> # extra tests on tree/branch linux-next/master
> git bisect good e3c7283c19cd9ba999794f38007389ac83408a78  # 13:42  G     11     0    0   0  Add linux-next specific files for 20180629
> 
> ---
> 0-DAY kernel test infrastructure                Open Source Technology Center
> https://lists.01.org/pipermail/lkp                          Intel Corporation
> 
