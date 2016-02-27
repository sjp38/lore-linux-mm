Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f170.google.com (mail-ig0-f170.google.com [209.85.213.170])
	by kanga.kvack.org (Postfix) with ESMTP id 089FA6B0005
	for <linux-mm@kvack.org>; Sat, 27 Feb 2016 09:28:45 -0500 (EST)
Received: by mail-ig0-f170.google.com with SMTP id g6so56940274igt.1
        for <linux-mm@kvack.org>; Sat, 27 Feb 2016 06:28:45 -0800 (PST)
Received: from out11.biz.mail.alibaba.com (out11.biz.mail.alibaba.com. [205.204.114.131])
        by mx.google.com with ESMTP id m8si9853404igx.42.2016.02.27.06.28.42
        for <linux-mm@kvack.org>;
        Sat, 27 Feb 2016 06:28:44 -0800 (PST)
Message-ID: <56D1B364.8050209@emindsoft.com.cn>
Date: Sat, 27 Feb 2016 22:32:04 +0800
From: Chen Gang <chengang@emindsoft.com.cn>
MIME-Version: 1.0
Subject: Re: [PATCH trivial] include/linux/gfp.h: Improve the coding styles
References: <1456352791-2363-1-git-send-email-chengang@emindsoft.com.cn> <20160225092752.GU2854@techsingularity.net> <56CF1202.2020809@emindsoft.com.cn> <20160225160707.GX2854@techsingularity.net> <56CF8043.1030603@emindsoft.com.cn> <CAHz2CGWqndOZQPveuXJaGZQg_YHX+4OmSAB3rtN05RsHk440DA@mail.gmail.com> <56D06E8A.9070106@emindsoft.com.cn> <20160227024548.GP1215@thunk.org>
In-Reply-To: <20160227024548.GP1215@thunk.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>, Jianyu Zhan <nasa4836@gmail.com>, Mel Gorman <mgorman@techsingularity.net>, trivial@kernel.org, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, rientjes@google.com, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, vdavydov@virtuozzo.com, Dan Williams <dan.j.williams@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Chen Gang <gang.chen.5i5j@gmail.com>


On 2/27/16 10:45, Theodore Ts'o wrote:
> On Fri, Feb 26, 2016 at 11:26:02PM +0800, Chen Gang wrote:
>>> As for coding style, actually IMHO this patch is even _not_ a coding
>>> style, more like a code shuffle, indeed.
>>>
>>
>> "80 column limitation" is about coding style, I guess, all of us agree
>> with it.
> 
> No, it's been accepted that checkpatch requiring people to reformat
> code to within be 80 columns limitation was actively harmful, and it
> no longer does that.
> 
> Worse, it now complains when you split a printf string across lines,
> so there were patches that split a string across multiple lines to
> make checkpatch shut up.  And now there are patches that join the
> string back together.
> 
> And if you now start submitting patches to split them up again because
> you think the 80 column restriction is so darned important, that would
> be even ***more*** code churn.
> 

I don't think so. Of cause NOT the "CODE CHURN". It is not correct to
make an early decision during discussing.

"80 column limitation" is mentioned in "Documentation/CodingStyle", if
we have very good reason for it, we can break this limitation (for me,
what you said above are really some of good reasons).

But in our case (the patch), can anybody find any "good reasons" for it?
at least, at present, I can not find:

 - It is a common shared base header file, it is almost not used for
   code analyzing (e.g. git diff, git blame).

 - Is it helpful for "grep xxx filename | grep yyy"? Please check the
   patch, I can not find (maybe __GFP_MOVABL definition be? but it is
   still not obvious, if some member stick to, we can keep it no touch).

 - Could anyone find any good reasons for it within this patch?


> Which is one of the reasons why some of us aren't terribly happy with
> people who start running checkpatch -file on other people's code and
> start submitting patches, either through the trivial patch portal or
> not.
> 

For me, as a individual developer, I don't like this way, either. So of
cause, I don't care about this way.

I am just reading the common shared header files about mm. At least, I
can understand some common sense of mm, and also read through the whole
other headers to know what they are.

When I find something valuable more or less, I shall send related patch
for it.

> Mel, as an MM developer, has already NACK'ed the patch, which means
> you should not send the patch to **any** upstream maintainer for
> inclusion.

I don't think I "should not ...". I only care about correctness and
contribution, I don't care about any members ideas and their thinking.
When we have different ideas or thinking, we need discuss.

For common shared header files, for me, we should really take more care
about the coding styles.

 - If the common shared header files don't care about the coding styles,
   I guess any body files will have much more excuses for "do not care
   about coding styles".

 - That means our kernel whole source files need not care about coding
   styles at all!!

 - It is really really VERY BAD!!

If someone only dislike me to send the related patches, I suggest: Let
another member(s) "run checkpatch -file" on the whole "./include" sub-
directory, and fix all coding styles issues.


Thanks.
-- 
Chen Gang (e??a??)

Managing Natural Environments is the Duty of Human Beings.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
