Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id C32B06B0031
	for <linux-mm@kvack.org>; Wed, 25 Jun 2014 05:55:00 -0400 (EDT)
Received: by mail-pa0-f45.google.com with SMTP id rd3so1512033pab.18
        for <linux-mm@kvack.org>; Wed, 25 Jun 2014 02:55:00 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id dk1si4365244pbb.213.2014.06.25.02.54.59
        for <linux-mm@kvack.org>;
        Wed, 25 Jun 2014 02:55:00 -0700 (PDT)
Date: Wed, 25 Jun 2014 17:54:44 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [cpufreq] kernel BUG at kernel/irq_work.c:175!
Message-ID: <20140625095444.GA1635@localhost>
References: <20140625093650.GD27280@localhost>
 <CAKohpo=qmJktRviycErY205xo=-MJ1NZG-uGidRXjO+aAEczEg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAKohpo=qmJktRviycErY205xo=-MJ1NZG-uGidRXjO+aAEczEg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Viresh Kumar <viresh.kumar@linaro.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Stephen Rothwell <sfr@canb.auug.org.au>, Jet Chen <jet.chen@intel.com>, Yuanhan Liu <yuanhan.liu@intel.com>, LKP <lkp@01.org>, "Su, Tao" <tao.su@intel.com>, "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, Stephen Warren <swarren@wwwdotorg.org>

> Nothing specific to my tree, its there in linux-next and PeterZ is
> already working on it:
> 
> https://lkml.org/lkml/2014/6/25/25

That's great! Sorry I should have googled LKML before reporting this error.

Fengguang

> Last diff from him:
> 
> ---
>  kernel/irq_work.c |   12 +-----------
>  1 file changed, 1 insertion(+), 11 deletions(-)
> 
> Index: linux-2.6/kernel/irq_work.c
> ===================================================================
> --- linux-2.6.orig/kernel/irq_work.c
> +++ linux-2.6/kernel/irq_work.c
> @@ -160,21 +160,11 @@ static void irq_work_run_list(struct lli
>         }
>  }
> 
> -static void __irq_work_run(void)
> +static void irq_work_run(void)
>  {
>         irq_work_run_list(&__get_cpu_var(raised_list));
>         irq_work_run_list(&__get_cpu_var(lazy_list));
>  }
> -
> -/*
> - * Run the irq_work entries on this cpu. Requires to be ran from hardirq
> - * context with local IRQs disabled.
> - */
> -void irq_work_run(void)
> -{
> -       BUG_ON(!in_irq());
> -       __irq_work_run();
> -}
>  EXPORT_SYMBOL_GPL(irq_work_run);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
