Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id D327E6B00DA
	for <linux-mm@kvack.org>; Mon, 18 Oct 2010 19:59:17 -0400 (EDT)
Subject: Re: [UnifiedV4 00/16] The Unified slab allocator (V4)
From: "Alex,Shi" <alex.shi@intel.com>
In-Reply-To: <alpine.DEB.2.00.1010181249540.2092@router.home>
References: <20101005185725.088808842@linux.com>
	 <AANLkTinPU4T59PvDH1wX2Rcy7beL=TvmHOZh_wWuBU-T@mail.gmail.com>
	 <20101006123753.GA17674@localhost> <1286936472.31597.50.camel@debian>
	 <alpine.DEB.2.00.1010181249540.2092@router.home>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 19 Oct 2010 08:01:44 +0800
Message-ID: <1287446504.24927.4.camel@debian>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>
Cc: "Wu, Fengguang" <fengguang.wu@intel.com>, Pekka Enberg <penberg@kernel.org>, Pekka Enberg <penberg@cs.helsinki.fi>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, David Rientjes <rientjes@google.com>, Mel Gorman <mel@csn.ul.ie>, "npiggin@kernel.dk" <npiggin@kernel.dk>, "yanmin_zhang@linux.intel.com" <yanmin_zhang@linux.intel.com>, "Chen, Tim C" <tim.c.chen@intel.com>, "Li, Shaohua" <shaohua.li@intel.com>
List-ID: <linux-mm.kvack.org>

On Tue, 2010-10-19 at 02:00 +0800, Christoph Lameter wrote:
> On Wed, 13 Oct 2010, Alex,Shi wrote:
> 
> > I got the code from
> > git://git.kernel.org/pub/scm/linux/kernel/git/christoph/slab.git unified
> > on branch "origin/unified" and do a patch base on 36-rc7 kernel. Then I
> > tested the patch on our 2P/4P core2 machines and 2P NHM, 2P WSM
> > machines. Most of benchmark have no clear improvement or regression. The
> > testing benchmarks is listed here.
> > http://kernel-perf.sourceforge.net/about_tests.php
> 
> Ah. Thanks. The tests needs to show a clear benefit for this to be a
> viable solution. They did earlier without all the NUMA queuing on SMP.
> 
> > BTW, I save several time kernel panic in fio testing:
> > ===================
> > > Pid: 776, comm: kswapd0 Not tainted 2.6.36-rc7-unified #1 X8DTN/X8DTN
> > > > RIP: 0010:[<ffffffff810cc21c>]  [<ffffffff810cc21c>] slab_alloc
> > > > +0x562/0x6f2
> 
> Cannot see the error message? I guess this is the result of a BUG_ON()?
> I'll try to run that fio test first.
> 
Can not see error messages since the machine hang when any ops appear.
And the panic ops just pop up randomly, don't know how to reproduce it
now. 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
