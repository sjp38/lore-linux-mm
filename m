Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id E98B06B0003
	for <linux-mm@kvack.org>; Sun, 11 Feb 2018 21:28:06 -0500 (EST)
Received: by mail-pl0-f70.google.com with SMTP id h33so5693851plh.19
        for <linux-mm@kvack.org>; Sun, 11 Feb 2018 18:28:06 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t3sor760894pgn.76.2018.02.11.18.28.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 11 Feb 2018 18:28:05 -0800 (PST)
Date: Mon, 12 Feb 2018 11:28:00 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH -mm -v3] mm, swap, frontswap: Fix THP swap if frontswap
 enabled
Message-ID: <20180212022800.GA458@jagdpanzerIV>
References: <20180209084947.22749-1-ying.huang@intel.com>
 <20180209130339.e91c8709e9c46e5b3f941a29@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180209130339.e91c8709e9c46e5b3f941a29@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Huang, Ying" <ying.huang@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <huang.ying.caritas@gmail.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Dan Streetman <ddstreet@ieee.org>, Seth Jennings <sjenning@redhat.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Shaohua Li <shli@kernel.org>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@techsingularity.net>, Shakeel Butt <shakeelb@google.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, stable@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Minchan Kim <minchan@kernel.org>

Hello,

On (02/09/18 13:03), Andrew Morton wrote:
[..]
> > Frontswap has multiple backends, to make it easy for one backend to
> > enable THP support, the THP checking is put in backend frontswap store
> > functions instead of the general interfaces.
> > 
> > Fixes: bd4c82c22c367e068 ("mm, THP, swap: delay splitting THP after swapped out")
> > Reported-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
> > Tested-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
> 
> I don't think Sergey has tested this version and I suspect this is a
> holdover from the earlier patch, so I'll remove this line.

Just tested it (v3) with FRONTSWAP enabled (didn't test XEN tmem).
Works fine.

FWIW
Tested-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com> # frontswap

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
