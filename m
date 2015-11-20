Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 14C6A6B0253
	for <linux-mm@kvack.org>; Thu, 19 Nov 2015 20:46:32 -0500 (EST)
Received: by pacdm15 with SMTP id dm15so99212845pac.3
        for <linux-mm@kvack.org>; Thu, 19 Nov 2015 17:46:31 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id c10si15384658pat.36.2015.11.19.17.46.31
        for <linux-mm@kvack.org>;
        Thu, 19 Nov 2015 17:46:31 -0800 (PST)
Date: Fri, 20 Nov 2015 09:46:21 +0800
From: Fengguang Wu <lkp@intel.com>
Subject: Re: [kbuild-all] [patch -mm] mm, vmalloc: remove VM_VPAGES
Message-ID: <20151120014621.GA28477@wfg-t540p.sh.intel.com>
References: <201511190854.Z8lkE4h1%fengguang.wu@intel.com>
 <alpine.DEB.2.10.1511181659290.8399@chino.kir.corp.google.com>
 <20151119113300.GA22395@wfg-t540p.sh.intel.com>
 <201511192123.DHI75684.FFHOOQSVMLOFJt@I-love.SAKURA.ne.jp>
 <20151119123546.GA25179@wfg-t540p.sh.intel.com>
 <20151119183745.GA2555@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151119183745.GA2555@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kbuild-all@01.org, rientjes@google.com, akpm@linux-foundation.org

On Thu, Nov 19, 2015 at 01:37:45PM -0500, Johannes Weiner wrote:
> Hi Fengguang,
> 
> On Thu, Nov 19, 2015 at 08:35:46PM +0800, Fengguang Wu wrote:
> > 
> >         git://git.cmpxchg.org/linux-mmotm.git
> > 
> > I'll teach the robot to use it instead of linux-next for [-mm] patches.
> 
> Yup, that seems like a more suitable base.
> 
> But you might even consider putting them on top of linux-mmots.git,

Yes, sure. I'll apply [-mm] LKML patches onto linux-mmots.git.

Thanks,
Fengguang

> which is released more frequently than mmotm. Not sure what other MM
> hackers do, but I tend to develop against mmots, and there could be
> occasional breakage when dependencies haven't yet trickled into mmotm.
> _______________________________________________
> kbuild-all mailing list
> kbuild-all@lists.01.org
> https://lists.01.org/mailman/listinfo/kbuild-all

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
