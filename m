Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 487AE6B0005
	for <linux-mm@kvack.org>; Fri,  6 Jul 2018 04:23:51 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id l11-v6so167001wrf.21
        for <linux-mm@kvack.org>; Fri, 06 Jul 2018 01:23:51 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j9-v6sor871744wrq.66.2018.07.06.01.23.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 06 Jul 2018 01:23:49 -0700 (PDT)
Date: Fri, 6 Jul 2018 10:23:48 +0200
From: Oscar Salvador <osalvador@techadventures.net>
Subject: Re: [PATCH] mm: do not bug_on on incorrect lenght in __mm_populate
Message-ID: <20180706082348.GB8235@techadventures.net>
References: <20180706053545.GD32658@dhcp22.suse.cz>
 <201807061427.cYcp5ef9%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201807061427.cYcp5ef9%fengguang.wu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <lkp@intel.com>
Cc: Michal Hocko <mhocko@kernel.org>, kbuild-all@01.org, Zi Yan <zi.yan@cs.rutgers.edu>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, syzbot <syzbot+5dcb560fe12aa5091c06@syzkaller.appspotmail.com>, akpm@linux-foundation.org, aneesh.kumar@linux.vnet.ibm.com, dan.j.williams@intel.com, kirill.shutemov@linux.intel.com, linux-mm@kvack.org, mst@redhat.com, syzkaller-bugs@googlegroups.com, viro@zeniv.linux.org.uk, ying.huang@intel.com

On Fri, Jul 06, 2018 at 03:50:53PM +0800, kbuild test robot wrote:
> Hi Michal,
> 
> I love your patch! Yet something to improve:
> 
> [auto build test ERROR on linus/master]
> [also build test ERROR on v4.18-rc3 next-20180705]
> [if your patch is applied to the wrong git tree, please drop us a note to help improve the system]
> 
> url:    https://github.com/0day-ci/linux/commits/Michal-Hocko/mm-do-not-bug_on-on-incorrect-lenght-in-__mm_populate/20180706-134850
> config: x86_64-randconfig-x015-201826 (attached as .config)
> compiler: gcc-7 (Debian 7.3.0-16) 7.3.0
> reproduce:
>         # save the attached .config to linux build tree
>         make ARCH=x86_64 
> 
> All errors (new ones prefixed by >>):
> 
>    mm/mmap.c: In function 'do_brk_flags':
> >> mm/mmap.c:2936:16: error: 'len' redeclared as different kind of symbol
>      unsigned long len;
>                    ^~~
>    mm/mmap.c:2932:59: note: previous definition of 'len' was here
>     static int do_brk_flags(unsigned long addr, unsigned long len, unsigned long flags, struct list_head *uf)

Somehow I missed that.
Maybe some remains from yesterday.

The local variable "len" must be dropped.
-- 
Oscar Salvador
SUSE L3
