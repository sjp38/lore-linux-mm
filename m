Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 916B16B0010
	for <linux-mm@kvack.org>; Fri,  6 Jul 2018 05:02:21 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id r9-v6so642853edh.14
        for <linux-mm@kvack.org>; Fri, 06 Jul 2018 02:02:21 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p21-v6si8192193edm.136.2018.07.06.02.02.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Jul 2018 02:02:20 -0700 (PDT)
Date: Fri, 6 Jul 2018 11:02:17 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: do not bug_on on incorrect lenght in __mm_populate
Message-ID: <20180706090217.GI32658@dhcp22.suse.cz>
References: <20180706053545.GD32658@dhcp22.suse.cz>
 <201807061427.cYcp5ef9%fengguang.wu@intel.com>
 <20180706082348.GB8235@techadventures.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180706082348.GB8235@techadventures.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oscar Salvador <osalvador@techadventures.net>
Cc: kbuild test robot <lkp@intel.com>, kbuild-all@01.org, Zi Yan <zi.yan@cs.rutgers.edu>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, syzbot <syzbot+5dcb560fe12aa5091c06@syzkaller.appspotmail.com>, akpm@linux-foundation.org, aneesh.kumar@linux.vnet.ibm.com, dan.j.williams@intel.com, kirill.shutemov@linux.intel.com, linux-mm@kvack.org, mst@redhat.com, syzkaller-bugs@googlegroups.com, viro@zeniv.linux.org.uk, ying.huang@intel.com

On Fri 06-07-18 10:23:48, Oscar Salvador wrote:
> On Fri, Jul 06, 2018 at 03:50:53PM +0800, kbuild test robot wrote:
> > Hi Michal,
> > 
> > I love your patch! Yet something to improve:
> > 
> > [auto build test ERROR on linus/master]
> > [also build test ERROR on v4.18-rc3 next-20180705]
> > [if your patch is applied to the wrong git tree, please drop us a note to help improve the system]
> > 
> > url:    https://github.com/0day-ci/linux/commits/Michal-Hocko/mm-do-not-bug_on-on-incorrect-lenght-in-__mm_populate/20180706-134850
> > config: x86_64-randconfig-x015-201826 (attached as .config)
> > compiler: gcc-7 (Debian 7.3.0-16) 7.3.0
> > reproduce:
> >         # save the attached .config to linux build tree
> >         make ARCH=x86_64 
> > 
> > All errors (new ones prefixed by >>):
> > 
> >    mm/mmap.c: In function 'do_brk_flags':
> > >> mm/mmap.c:2936:16: error: 'len' redeclared as different kind of symbol
> >      unsigned long len;
> >                    ^~~
> >    mm/mmap.c:2932:59: note: previous definition of 'len' was here
> >     static int do_brk_flags(unsigned long addr, unsigned long len, unsigned long flags, struct list_head *uf)
> 
> Somehow I missed that.
> Maybe some remains from yesterday.
> 
> The local variable "len" must be dropped.

Of course. This is what it looks like when you post patches in hurry
before leaving. Mea culpa. Sorry about that. Refreshed
