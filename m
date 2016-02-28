Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 7C9746B0005
	for <linux-mm@kvack.org>; Sun, 28 Feb 2016 10:25:27 -0500 (EST)
Received: by mail-pa0-f52.google.com with SMTP id fy10so77370133pac.1
        for <linux-mm@kvack.org>; Sun, 28 Feb 2016 07:25:27 -0800 (PST)
Received: from us-alimail-mta2.hst.scl.en.alidc.net (mail113-250.mail.alibaba.com. [205.204.113.250])
        by mx.google.com with ESMTP id n88si35917024pfb.139.2016.02.28.07.25.24
        for <linux-mm@kvack.org>;
        Sun, 28 Feb 2016 07:25:25 -0800 (PST)
Message-ID: <56D3122F.1000802@emindsoft.com.cn>
Date: Sun, 28 Feb 2016 23:28:47 +0800
From: Chen Gang <chengang@emindsoft.com.cn>
MIME-Version: 1.0
Subject: Re: [PATCH trivial] include/linux/gfp.h: Improve the coding styles
References: <20160225092752.GU2854@techsingularity.net> <56CF1202.2020809@emindsoft.com.cn> <20160225160707.GX2854@techsingularity.net> <56CF8043.1030603@emindsoft.com.cn> <CAHz2CGWqndOZQPveuXJaGZQg_YHX+4OmSAB3rtN05RsHk440DA@mail.gmail.com> <56D06E8A.9070106@emindsoft.com.cn> <20160227024548.GP1215@thunk.org> <56D1B364.8050209@emindsoft.com.cn> <20160227165301.GA9506@thunk.org> <56D23D94.50707@emindsoft.com.cn> <20160228132717.GD2854@techsingularity.net>
In-Reply-To: <20160228132717.GD2854@techsingularity.net>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Theodore Ts'o <tytso@mit.edu>, Jianyu Zhan <nasa4836@gmail.com>, trivial@kernel.org, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, rientjes@google.com, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, vdavydov@virtuozzo.com, Dan Williams <dan.j.williams@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Chen Gang <gang.chen.5i5j@gmail.com>


On 2/28/16 21:27, Mel Gorman wrote:
> On Sun, Feb 28, 2016 at 08:21:40AM +0800, Chen Gang wrote:
>>
>> For me, NAK also needs reasons.
>>
> 
> You already got the reasons. Not only does a patch of this type interfere
> with git blame which is important even in headers but I do not think the
> patch actually improves the readability of the code. For example, the
> comments move to the line after the defintions which to my eye at least
> looks clumsy and weird.
>

For me, in local headers, they may be often modified, and also may be
complex, so the code analyzing maybe also be used often. But in common
shared headers in ./include (e.g. gfp.h), most of them are simple enough.

 - Since common shared headers are usually simple, code analyzing is
   still useful, but not like the body files or local headers (code
   analyzing are very useful for body files and local headers).
 
 - Common shared headers are quite often read by most programmers, so
   common shared headers need take more care about its coding styles.

 - Then for common shared headers, the coding style is 1st.

And for __GFP_MOVABLE definition (with ZONE_MOVABLE), I guess, we can
keep it no touch (like what I originally said: if the related member
stick to, we can keep it no touch).

And for me, the other macro definitions which out of 80 columns, can be
fixed in normal ways (let the related comments ahead of macro definition
), does this change also have negative effect?


>> I guess they are related with this patch, and their NAKs' reason are: mm
>> and trivial don't care about this coding style issue, is it correct?
>>
> 
> No. Coding style is important but it's a guideline not a law.

Yes.

For me, vertical split window in vim is very useful, I almost always use
this feature when read source code in full screen under Macbook client,
when columns are 86+, it will be wrapped (I feel really not quite good).

And occasionally (really not often), we may copy/past part of contents
in the header files (e.g. constant definition) to the pdf file as
appendix.

So except the string broken, or "grep -rn xxx * | grep yyy", 80 columns
limitation is always helpful to me.

>                                                               There are
> cases where breaking it results in perfectly readable code. At least one
> my my own recent patches was flagged by checkpatch as having style issues
> but fixing the style was considerably harder to read so I left it. If the
> definitions in that header need to change again in the future and there
> are style issues then they can be fixed in the context of a functional
> change instead of patching style just for the sake of it.
> 

For me, except just modify the related contents, usually, we need devide
the patch into 2: one for real modification, the other for coding styles.

And in some of common, base, shared headers in ./include (e.g. gfp.h), I
guess, most of contents *should* not be changed quite often, so the bad
coding styles probably will be alive in a long term.


Thanks.
-- 
Chen Gang (e??a??)

Managing Natural Environments is the Duty of Human Beings.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
