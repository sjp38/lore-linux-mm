Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3420D6B0643
	for <linux-mm@kvack.org>; Wed,  2 Aug 2017 19:34:39 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id w187so65526480pgb.10
        for <linux-mm@kvack.org>; Wed, 02 Aug 2017 16:34:39 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id v189si20480277pgv.355.2017.08.02.16.34.37
        for <linux-mm@kvack.org>;
        Wed, 02 Aug 2017 16:34:38 -0700 (PDT)
Date: Thu, 3 Aug 2017 08:34:36 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v6 5/7] mm: make tlb_flush_pending global
Message-ID: <20170802233436.GC32020@bbox>
References: <20170802000818.4760-6-namit@vmware.com>
 <201708022224.e3s8yqcJ%fengguang.wu@intel.com>
 <20170802162758.40760a1e3cbb24b10e1c4144@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170802162758.40760a1e3cbb24b10e1c4144@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kbuild test robot <lkp@intel.com>, Nadav Amit <namit@vmware.com>, kbuild-all@01.org, linux-mm@kvack.org, nadav.amit@gmail.com, linux-kernel@vger.kernel.org

On Wed, Aug 02, 2017 at 04:27:58PM -0700, Andrew Morton wrote:
> On Wed, 2 Aug 2017 22:28:47 +0800 kbuild test robot <lkp@intel.com> wrote:
> 
> > Hi Minchan,
> > 
> > [auto build test WARNING on linus/master]
> > [also build test WARNING on v4.13-rc3]
> > [cannot apply to next-20170802]
> > [if your patch is applied to the wrong git tree, please drop us a note to help improve the system]
> > 
> > url:    https://github.com/0day-ci/linux/commits/Nadav-Amit/mm-migrate-prevent-racy-access-to-tlb_flush_pending/20170802-205715
> > config: sh-allyesconfig (attached as .config)
> > compiler: sh4-linux-gnu-gcc (Debian 6.1.1-9) 6.1.1 20160705
> > reproduce:
> >         wget https://raw.githubusercontent.com/01org/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
> >         chmod +x ~/bin/make.cross
> >         # save the attached .config to linux build tree
> >         make.cross ARCH=sh 
> > 
> > All warnings (new ones prefixed by >>):
> > 
> >    In file included from include/linux/printk.h:6:0,
> >                     from include/linux/kernel.h:13,
> >                     from mm/debug.c:8:
> >    mm/debug.c: In function 'dump_mm':
> > >> include/linux/kern_levels.h:4:18: warning: format '%lx' expects argument of type 'long unsigned int', but argument 40 has type 'int' [-Wformat=]
> >
> > ...
> >
> 
> This?
> 
> From: Andrew Morton <akpm@linux-foundation.org>
> Subject: mm-make-tlb_flush_pending-global-fix
> 
> remove more ifdefs from world's ugliest printk statement
> 
> Cc: Mel Gorman <mgorman@techsingularity.net>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: Nadav Amit <namit@vmware.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

I'm a bit late.
Thanks for the fix, Andrew!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
