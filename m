Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id D3FC76B0253
	for <linux-mm@kvack.org>; Thu, 19 Nov 2015 06:33:23 -0500 (EST)
Received: by pacej9 with SMTP id ej9so78807247pac.2
        for <linux-mm@kvack.org>; Thu, 19 Nov 2015 03:33:23 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id ie7si11300290pad.155.2015.11.19.03.33.22
        for <linux-mm@kvack.org>;
        Thu, 19 Nov 2015 03:33:22 -0800 (PST)
Date: Thu, 19 Nov 2015 19:33:00 +0800
From: Fengguang Wu <lkp@intel.com>
Subject: Re: [kbuild-all] [patch -mm] mm, vmalloc: remove VM_VPAGES
Message-ID: <20151119113300.GA22395@wfg-t540p.sh.intel.com>
References: <201511190854.Z8lkE4h1%fengguang.wu@intel.com>
 <alpine.DEB.2.10.1511181659290.8399@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1511181659290.8399@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, kbuild-all@01.org, linux-kernel@vger.kernel.org

Hi David,

On Wed, Nov 18, 2015 at 05:00:07PM -0800, David Rientjes wrote:
> On Thu, 19 Nov 2015, kbuild test robot wrote:
> 
> > Hi David,
> > 
> > [auto build test ERROR on: next-20151118]
> > [also build test ERROR on: v4.4-rc1]
> > 
> 
> You need to teach your bot what patches I'm proposing for the -mm tree 
> (notice the patch title) instead of your various trees.

Per my understanding linux-next is the -mm tree.
Or do you mean some standalone -mm git tree?

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
