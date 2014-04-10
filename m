Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f45.google.com (mail-pb0-f45.google.com [209.85.160.45])
	by kanga.kvack.org (Postfix) with ESMTP id 3D3066B0037
	for <linux-mm@kvack.org>; Thu, 10 Apr 2014 12:53:45 -0400 (EDT)
Received: by mail-pb0-f45.google.com with SMTP id uo5so4199876pbc.4
        for <linux-mm@kvack.org>; Thu, 10 Apr 2014 09:53:44 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id tv5si2539032pbc.158.2014.04.10.09.53.43
        for <linux-mm@kvack.org>;
        Thu, 10 Apr 2014 09:53:44 -0700 (PDT)
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] mm/vmalloc: Introduce DEBUG_VMALLOCINFO to reduce spinlock contention
References: <1397148058-8737-1-git-send-email-ryao@gentoo.org>
Date: Thu, 10 Apr 2014 09:51:57 -0700
In-Reply-To: <1397148058-8737-1-git-send-email-ryao@gentoo.org> (Richard Yao's
	message of "Thu, 10 Apr 2014 12:40:58 -0400")
Message-ID: <87txa1i0uq.fsf@tassilo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Richard Yao <ryao@gentoo.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Zhang Yanfei <zhangyanfei.yes@gmail.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, HATAYAMA Daisuke <d.hatayama@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel@gentoo.org, Matthew Thode <mthode@mthode.org>

Richard Yao <ryao@gentoo.org> writes:

> Performance analysis of software compilation by Gentoo portage on an
> Intel E5-2620 with 64GB of RAM revealed that a sizeable amount of time,
> anywhere from 5% to 15%, was spent in get_vmalloc_info(), with at least
> 40% of that time spent in the _raw_spin_lock() invoked by it.

I don't think that's the right fix. We want to be able 
to debug kernels without having to recompile them.

And switching locking around dynamically like this is very
ugly and hard to maintain.

Besides are you sure the spin lock is not needed elsewhere?

How are writers to the list protected?

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
