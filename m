Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f41.google.com (mail-oi0-f41.google.com [209.85.218.41])
	by kanga.kvack.org (Postfix) with ESMTP id 484CD6B0009
	for <linux-mm@kvack.org>; Thu, 25 Feb 2016 21:33:40 -0500 (EST)
Received: by mail-oi0-f41.google.com with SMTP id w5so53361979oie.3
        for <linux-mm@kvack.org>; Thu, 25 Feb 2016 18:33:40 -0800 (PST)
Received: from mail-ob0-x241.google.com (mail-ob0-x241.google.com. [2607:f8b0:4003:c01::241])
        by mx.google.com with ESMTPS id x192si8988679oif.66.2016.02.25.18.33.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Feb 2016 18:33:39 -0800 (PST)
Received: by mail-ob0-x241.google.com with SMTP id u2so4454548obz.3
        for <linux-mm@kvack.org>; Thu, 25 Feb 2016 18:33:39 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <56CF8043.1030603@emindsoft.com.cn>
References: <1456352791-2363-1-git-send-email-chengang@emindsoft.com.cn>
 <20160225092752.GU2854@techsingularity.net> <56CF1202.2020809@emindsoft.com.cn>
 <20160225160707.GX2854@techsingularity.net> <56CF8043.1030603@emindsoft.com.cn>
From: Jianyu Zhan <nasa4836@gmail.com>
Date: Fri, 26 Feb 2016 10:32:59 +0800
Message-ID: <CAHz2CGWqndOZQPveuXJaGZQg_YHX+4OmSAB3rtN05RsHk440DA@mail.gmail.com>
Subject: Re: [PATCH trivial] include/linux/gfp.h: Improve the coding styles
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chen Gang <chengang@emindsoft.com.cn>
Cc: Mel Gorman <mgorman@techsingularity.net>, trivial@kernel.org, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, rientjes@google.com, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, vdavydov@virtuozzo.com, Dan Williams <dan.j.williams@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Chen Gang <gang.chen.5i5j@gmail.com>

On Fri, Feb 26, 2016 at 6:29 AM, Chen Gang <chengang@emindsoft.com.cn> wrote:
> git is a tool mainly for analyzing code, but not mainly for normal
> reading main code.
>
> So for me, the coding styles need not consider about git.

For you, maybe yes.

But for most of the developers/learners,  git blame does help a lot.
Kernel code was not as complicated as it is now, it is keeping evolving.

So basically a history chain is indispensable in studying such a complex system.
git blame fits in this role.  I benefited a lot from using it when I
started to learn the code,
And,  a pure coding style fix is sometimes really troublesome as I
have to use git blame
to go another step up along the history chain,  which is time
consuming and boring.

But after all, I bet you will be fond of using it if you dive deeper
into the kernel code studying.
And if you do,  you will know why so many developers in this thread
are so upset and allergic
to such coding-style fix.

As for coding style, actually IMHO this patch is even _not_ a coding
style, more like a code shuffle, indeed.

And for your commit history, I found actually you have already
contributed some quit good patches.
I don't think it is helpful for a non-layman contributor to keep
generating such code churn.



Thanks,
Jianyu Zhan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
