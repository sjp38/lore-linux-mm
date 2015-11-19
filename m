Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id C8CD16B0253
	for <linux-mm@kvack.org>; Thu, 19 Nov 2015 07:35:57 -0500 (EST)
Received: by pabfh17 with SMTP id fh17so82958776pab.0
        for <linux-mm@kvack.org>; Thu, 19 Nov 2015 04:35:57 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id um10si11614451pab.110.2015.11.19.04.35.56
        for <linux-mm@kvack.org>;
        Thu, 19 Nov 2015 04:35:57 -0800 (PST)
Date: Thu, 19 Nov 2015 20:35:46 +0800
From: Fengguang Wu <lkp@intel.com>
Subject: Re: [kbuild-all] [patch -mm] mm, vmalloc: remove VM_VPAGES
Message-ID: <20151119123546.GA25179@wfg-t540p.sh.intel.com>
References: <201511190854.Z8lkE4h1%fengguang.wu@intel.com>
 <alpine.DEB.2.10.1511181659290.8399@chino.kir.corp.google.com>
 <20151119113300.GA22395@wfg-t540p.sh.intel.com>
 <201511192123.DHI75684.FFHOOQSVMLOFJt@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201511192123.DHI75684.FFHOOQSVMLOFJt@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: rientjes@google.com, linux-mm@kvack.org, akpm@linux-foundation.org, kbuild-all@01.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>

On Thu, Nov 19, 2015 at 09:23:41PM +0900, Tetsuo Handa wrote:
> Fengguang Wu wrote:
> > Hi David,
> > 
> > On Wed, Nov 18, 2015 at 05:00:07PM -0800, David Rientjes wrote:
> > > On Thu, 19 Nov 2015, kbuild test robot wrote:
> > > 
> > > > Hi David,
> > > > 
> > > > [auto build test ERROR on: next-20151118]
> > > > [also build test ERROR on: v4.4-rc1]
> > > > 
> > > 
> > > You need to teach your bot what patches I'm proposing for the -mm tree 
> > > (notice the patch title) instead of your various trees.
> > 
> > Per my understanding linux-next is the -mm tree.
> > Or do you mean some standalone -mm git tree?
> > 
> > Thanks,
> > Fengguang
> > 
> 
> This build error will be gone when
> "[PATCH] tree wide: Use kvfree() than conditional kfree()/vfree()"
> (currently in -mm tree) is applied.

Got it. I can find that patch in the mmotm tree:

        git://git.cmpxchg.org/linux-mmotm.git

I'll teach the robot to use it instead of linux-next for [-mm] patches.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
