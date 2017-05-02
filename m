Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id E75046B02E1
	for <linux-mm@kvack.org>; Tue,  2 May 2017 01:02:30 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id k11so52796899pgc.17
        for <linux-mm@kvack.org>; Mon, 01 May 2017 22:02:30 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id f80si16457038pfd.394.2017.05.01.22.02.29
        for <linux-mm@kvack.org>;
        Mon, 01 May 2017 22:02:29 -0700 (PDT)
Date: Tue, 2 May 2017 14:02:28 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH -mm -v3] mm, swap: Sort swap entries before free
Message-ID: <20170502050228.GA27176@bbox>
References: <87tw5idjv9.fsf@yhuang-dev.intel.com>
 <20170424045213.GA11287@bbox>
 <87y3un2vdp.fsf@yhuang-dev.intel.com>
 <20170427043545.GA1726@bbox>
 <87r30dz6am.fsf@yhuang-dev.intel.com>
 <20170428074257.GA19510@bbox>
 <871ssdvtx5.fsf@yhuang-dev.intel.com>
 <20170428090049.GA26460@bbox>
 <87h918vjlr.fsf@yhuang-dev.intel.com>
 <878tmkvemu.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <878tmkvemu.fsf@yhuang-dev.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Rik van Riel <riel@redhat.com>

On Fri, Apr 28, 2017 at 09:35:37PM +0800, Huang, Ying wrote:
> In fact, during the test, I found the overhead of sort() is comparable
> with the performance difference of adding likely()/unlikely() to the
> "if" in the function.

Huang,

This discussion is started from your optimization code:

        if (nr_swapfiles > 1)
                sort();

I don't have such fast machine so cannot test it. However, you added
such optimization code in there so I guess it's *worth* to review so
with spending my time, I pointed out what you are missing and
suggested a idea to find a compromise.

Now you are saying sort is so fast so no worth to add more logics
to avoid the overhead?
Then, please just drop that if condition part and instead, sort
it unconditionally.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
