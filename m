Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 181EC6B0011
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 11:40:18 -0400 (EDT)
Received: by fxm18 with SMTP id 18so2791888fxm.14
        for <linux-mm@kvack.org>; Thu, 28 Apr 2011 08:40:15 -0700 (PDT)
Date: Thu, 28 Apr 2011 17:40:12 +0200
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH] percpu: preemptless __per_cpu_counter_add
Message-ID: <20110428154012.GG16552@htj.dyndns.org>
References: <alpine.DEB.2.00.1104280904240.15775@router.home>
 <20110428142331.GA16552@htj.dyndns.org>
 <alpine.DEB.2.00.1104280935460.16323@router.home>
 <20110428144446.GC16552@htj.dyndns.org>
 <alpine.DEB.2.00.1104280951480.16323@router.home>
 <20110428145657.GD16552@htj.dyndns.org>
 <alpine.DEB.2.00.1104281003000.16323@router.home>
 <20110428151203.GE16552@htj.dyndns.org>
 <alpine.DEB.2.00.1104281017240.16323@router.home>
 <20110428153101.GF16552@htj.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110428153101.GF16552@htj.dyndns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Shaohua Li <shaohua.li@intel.com>, Eric Dumazet <eric.dumazet@gmail.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Thu, Apr 28, 2011 at 05:31:01PM +0200, Tejun Heo wrote:
> > The hugely expensive _sum() is IMHO pretty useless given the above. It is
> > a function that is called with the *hope* of getting a more accurate
> > result.
...
> Christoph, I'm sorry but I really can't explain it any better and am
> out of this thread.  If you still wanna proceed, you'll need to route
> the patches yourself.  Please keep me cc'd.

Oh, another way to proceed would be, if _sum() is as useless as you
suggested above, remove _sum() first and see how that goes.  If that
flies, there will be no reason to argue over anything, right?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
