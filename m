Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0F4DB6B033C
	for <linux-mm@kvack.org>; Tue,  2 May 2017 01:35:28 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id m13so52896633pgd.12
        for <linux-mm@kvack.org>; Mon, 01 May 2017 22:35:28 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id 71si16281303pfk.131.2017.05.01.22.35.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 May 2017 22:35:27 -0700 (PDT)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH -mm -v3] mm, swap: Sort swap entries before free
References: <87tw5idjv9.fsf@yhuang-dev.intel.com>
	<20170424045213.GA11287@bbox> <87y3un2vdp.fsf@yhuang-dev.intel.com>
	<20170427043545.GA1726@bbox> <87r30dz6am.fsf@yhuang-dev.intel.com>
	<20170428074257.GA19510@bbox> <871ssdvtx5.fsf@yhuang-dev.intel.com>
	<20170428090049.GA26460@bbox> <87h918vjlr.fsf@yhuang-dev.intel.com>
	<878tmkvemu.fsf@yhuang-dev.intel.com> <20170502050228.GA27176@bbox>
Date: Tue, 02 May 2017 13:35:24 +0800
In-Reply-To: <20170502050228.GA27176@bbox> (Minchan Kim's message of "Tue, 2
	May 2017 14:02:28 +0900")
Message-ID: <87fugng6sj.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: "Huang, Ying" <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Rik van Riel <riel@redhat.com>

Hi, Minchan,

Minchan Kim <minchan@kernel.org> writes:

> On Fri, Apr 28, 2017 at 09:35:37PM +0800, Huang, Ying wrote:
>> In fact, during the test, I found the overhead of sort() is comparable
>> with the performance difference of adding likely()/unlikely() to the
>> "if" in the function.
>
> Huang,
>
> This discussion is started from your optimization code:
>
>         if (nr_swapfiles > 1)
>                 sort();
>
> I don't have such fast machine so cannot test it. However, you added
> such optimization code in there so I guess it's *worth* to review so
> with spending my time, I pointed out what you are missing and
> suggested a idea to find a compromise.

Sorry for wasting your time and Thanks a lot for your review and
suggestion!

When I started talking this with you, I found there is some measurable
overhead of sort().  But later when I done more tests, I found the
measurable overhead is at the same level of likely()/unlikely() compiler
notation.  So you help me to find that, Thanks again!

> Now you are saying sort is so fast so no worth to add more logics
> to avoid the overhead?
> Then, please just drop that if condition part and instead, sort
> it unconditionally.

Now, because we found the overhead of sort() is low, I suggest to put
minimal effort to avoid it.  Like the original implementation,

         if (nr_swapfiles > 1)
                 sort();

Or, we can make nr_swapfiles more correct as Tim suggested (tracking
the number of the swap devices during swap on/off).

Best Regards,
Huang, Ying

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
