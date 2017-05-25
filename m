Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1147A6B02C3
	for <linux-mm@kvack.org>; Thu, 25 May 2017 18:43:32 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id a66so246323050pfl.6
        for <linux-mm@kvack.org>; Thu, 25 May 2017 15:43:32 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id o20si7318089pli.216.2017.05.25.15.43.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 May 2017 15:43:31 -0700 (PDT)
Date: Thu, 25 May 2017 15:43:28 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v6 05/10] mm: thp: enable thp migration in generic path
Message-Id: <20170525154328.61a2b2ceef37183895d5ce43@linux-foundation.org>
In-Reply-To: <138B8C07-2A41-40AA-9B4C-5F85FEFD6F0D@cs.rutgers.edu>
References: <201705260111.PCjyEyr4%fengguang.wu@intel.com>
	<138B8C07-2A41-40AA-9B4C-5F85FEFD6F0D@cs.rutgers.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zi Yan <zi.yan@cs.rutgers.edu>
Cc: kbuild test robot <lkp@intel.com>, kbuild-all@01.org, n-horiguchi@ah.jp.nec.com, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, minchan@kernel.org, vbabka@suse.cz, mgorman@techsingularity.net, mhocko@kernel.org, khandual@linux.vnet.ibm.com, dnellans@nvidia.com, dave.hansen@intel.com

On Thu, 25 May 2017 13:19:54 -0400 "Zi Yan" <zi.yan@cs.rutgers.edu> wrote:

> On 25 May 2017, at 13:06, kbuild test robot wrote:
> 
> > Hi Zi,
> >
> > [auto build test WARNING on mmotm/master]
> > [also build test WARNING on v4.12-rc2 next-20170525]
> > [if your patch is applied to the wrong git tree, please drop us a note to help improve the system]
> >
> > url:    https://github.com/0day-ci/linux/commits/Zi-Yan/mm-page-migration-enhancement-for-thp/20170526-003749
> > base:   git://git.cmpxchg.org/linux-mmotm.git master
> > config: i386-randconfig-x016-201721 (attached as .config)
> > compiler: gcc-6 (Debian 6.2.0-3) 6.2.0 20160901
> > reproduce:
> >         # save the attached .config to linux build tree
> >         make ARCH=i386
> >
> > All warnings (new ones prefixed by >>):
> >
> >    In file included from fs/proc/task_mmu.c:15:0:
> >    include/linux/swapops.h: In function 'swp_entry_to_pmd':
> >>> include/linux/swapops.h:222:16: warning: missing braces around initializer [-Wmissing-braces]
> >      return (pmd_t){{ 0 }};
> >                    ^
> 
> The braces are added to eliminate the warning from "m68k-linux-gcc (GCC) 4.9.0",
> which has the bug: https://gcc.gnu.org/bugzilla/show_bug.cgi?id=53119.

I think we'd prefer to have a warning on m68k than on i386!  Is there
something smarter we can do here?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
