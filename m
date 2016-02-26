Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f178.google.com (mail-ig0-f178.google.com [209.85.213.178])
	by kanga.kvack.org (Postfix) with ESMTP id 1AF616B0009
	for <linux-mm@kvack.org>; Fri, 26 Feb 2016 10:22:38 -0500 (EST)
Received: by mail-ig0-f178.google.com with SMTP id xg9so36533740igb.1
        for <linux-mm@kvack.org>; Fri, 26 Feb 2016 07:22:38 -0800 (PST)
Received: from us-alimail-mta2.hst.scl.en.alidc.net (mail113-249.mail.alibaba.com. [205.204.113.249])
        by mx.google.com with ESMTP id qh1si5080554igb.79.2016.02.26.07.22.35
        for <linux-mm@kvack.org>;
        Fri, 26 Feb 2016 07:22:37 -0800 (PST)
Message-ID: <56D06E8A.9070106@emindsoft.com.cn>
Date: Fri, 26 Feb 2016 23:26:02 +0800
From: Chen Gang <chengang@emindsoft.com.cn>
MIME-Version: 1.0
Subject: Re: [PATCH trivial] include/linux/gfp.h: Improve the coding styles
References: <1456352791-2363-1-git-send-email-chengang@emindsoft.com.cn> <20160225092752.GU2854@techsingularity.net> <56CF1202.2020809@emindsoft.com.cn> <20160225160707.GX2854@techsingularity.net> <56CF8043.1030603@emindsoft.com.cn> <CAHz2CGWqndOZQPveuXJaGZQg_YHX+4OmSAB3rtN05RsHk440DA@mail.gmail.com>
In-Reply-To: <CAHz2CGWqndOZQPveuXJaGZQg_YHX+4OmSAB3rtN05RsHk440DA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jianyu Zhan <nasa4836@gmail.com>
Cc: Mel Gorman <mgorman@techsingularity.net>, trivial@kernel.org, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, rientjes@google.com, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, vdavydov@virtuozzo.com, Dan Williams <dan.j.williams@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Chen Gang <gang.chen.5i5j@gmail.com>

On 2/26/16 10:32, Jianyu Zhan wrote:
> On Fri, Feb 26, 2016 at 6:29 AM, Chen Gang <chengang@emindsoft.com.cn> wrote:
>> git is a tool mainly for analyzing code, but not mainly for normal
>> reading main code.
>>
>> So for me, the coding styles need not consider about git.
> 
> For you, maybe yes.
> 
> But for most of the developers/learners,  git blame does help a lot.
> Kernel code was not as complicated as it is now, it is keeping evolving.
> 

Yes.

> So basically a history chain is indispensable in studying such a complex system.
> git blame fits in this role.  I benefited a lot from using it when I
> started to learn the code,
> And,  a pure coding style fix is sometimes really troublesome as I
> have to use git blame
> to go another step up along the history chain,  which is time
> consuming and boring.
> 
> But after all, I bet you will be fond of using it if you dive deeper
> into the kernel code studying.
> And if you do,  you will know why so many developers in this thread
> are so upset and allergic
> to such coding-style fix.
> 

For me, for discussion, I don't care about "so many developers", I only
focus on the proof and the contribution.


> As for coding style, actually IMHO this patch is even _not_ a coding
> style, more like a code shuffle, indeed.
> 

"80 column limitation" is about coding style, I guess, all of us agree
with it.

> And for your commit history, I found actually you have already
> contributed some quit good patches.

For me, I don't care about my history -- except some members find issues
related with my original patches, I have duty to analyze the related
issues together with the finders.

> I don't think it is helpful for a non-layman contributor to keep
> generating such code churn.
> 

For me, we are discussing, so it is not quite suitable to make an early
conclusion (code churn).

For me, I don't care about layman or non-layman, I only focus on the
proof and the contribution.

Thanks.
-- 
Chen Gang (e??a??)

Managing Natural Environments is the Duty of Human Beings.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
