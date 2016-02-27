Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 8E7366B0005
	for <linux-mm@kvack.org>; Sat, 27 Feb 2016 18:14:31 -0500 (EST)
Received: by mail-wm0-f44.google.com with SMTP id p65so26842134wmp.1
        for <linux-mm@kvack.org>; Sat, 27 Feb 2016 15:14:31 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ly10si23808601wjb.9.2016.02.27.15.14.29
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 27 Feb 2016 15:14:30 -0800 (PST)
Date: Sun, 28 Feb 2016 00:14:19 +0100 (CET)
From: Jiri Kosina <jikos@kernel.org>
Subject: Re: [PATCH trivial] include/linux/gfp.h: Improve the coding styles
In-Reply-To: <56D1B364.8050209@emindsoft.com.cn>
Message-ID: <alpine.LNX.2.00.1602280009110.22700@cbobk.fhfr.pm>
References: <1456352791-2363-1-git-send-email-chengang@emindsoft.com.cn> <20160225092752.GU2854@techsingularity.net> <56CF1202.2020809@emindsoft.com.cn> <20160225160707.GX2854@techsingularity.net> <56CF8043.1030603@emindsoft.com.cn>
 <CAHz2CGWqndOZQPveuXJaGZQg_YHX+4OmSAB3rtN05RsHk440DA@mail.gmail.com> <56D06E8A.9070106@emindsoft.com.cn> <20160227024548.GP1215@thunk.org> <56D1B364.8050209@emindsoft.com.cn>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chen Gang <chengang@emindsoft.com.cn>
Cc: Theodore Ts'o <tytso@mit.edu>, Jianyu Zhan <nasa4836@gmail.com>, Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, rientjes@google.com, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, vdavydov@virtuozzo.com, Dan Williams <dan.j.williams@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Chen Gang <gang.chen.5i5j@gmail.com>

On Sat, 27 Feb 2016, Chen Gang wrote:

> > Mel, as an MM developer, has already NACK'ed the patch, which means
> > you should not send the patch to **any** upstream maintainer for
> > inclusion.
> 
> I don't think I "should not ...". I only care about correctness and
> contribution, I don't care about any members ideas and their thinking.
> When we have different ideas or thinking, we need discuss.

If by "discuss" you mean "30+ email thread about where to put a line 
break", please drop me from CC next time this discussion is going to 
happen. Thanks.

> For common shared header files, for me, we should really take more care
> about the coding styles.
> 
>  - If the common shared header files don't care about the coding styles,
>    I guess any body files will have much more excuses for "do not care
>    about coding styles".
> 
>  - That means our kernel whole source files need not care about coding
>    styles at all!!
> 
>  - It is really really VERY BAD!!
> 
> If someone only dislike me to send the related patches, I suggest: Let
> another member(s) "run checkpatch -file" on the whole "./include" sub-
> directory, and fix all coding styles issues.

Which is exactly what you shouldn't do.

The ultimate goal of the Linux kernel is not 100% strict complicance to 
the CodingStyle document no matter what. The ultimate goal is to have a 
kernel that is under control. By polluting git blame, you are taking on 
aspect of the "under control" away.

Common sense needs to be used; horribly terrible coding style needs to be 
fixed, sure. Is 82-characters long line horribly terrible coding style? 
No, it's not.

Thanks,

-- 
Jiri Kosina
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
