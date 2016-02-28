Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 916586B0005
	for <linux-mm@kvack.org>; Sat, 27 Feb 2016 19:43:59 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id bj10so1130700pad.2
        for <linux-mm@kvack.org>; Sat, 27 Feb 2016 16:43:59 -0800 (PST)
Received: from out11.biz.mail.alibaba.com (out11.biz.mail.alibaba.com. [205.204.114.131])
        by mx.google.com with ESMTP id ah10si13982340pad.118.2016.02.27.16.43.57
        for <linux-mm@kvack.org>;
        Sat, 27 Feb 2016 16:43:58 -0800 (PST)
Message-ID: <56D2439B.2060803@emindsoft.com.cn>
Date: Sun, 28 Feb 2016 08:47:23 +0800
From: Chen Gang <chengang@emindsoft.com.cn>
MIME-Version: 1.0
Subject: Re: [PATCH trivial] include/linux/gfp.h: Improve the coding styles
References: <1456352791-2363-1-git-send-email-chengang@emindsoft.com.cn> <20160225092752.GU2854@techsingularity.net> <56CF1202.2020809@emindsoft.com.cn> <20160225160707.GX2854@techsingularity.net> <56CF8043.1030603@emindsoft.com.cn> <CAHz2CGWqndOZQPveuXJaGZQg_YHX+4OmSAB3rtN05RsHk440DA@mail.gmail.com> <56D06E8A.9070106@emindsoft.com.cn> <20160227024548.GP1215@thunk.org> <56D1B364.8050209@emindsoft.com.cn> <alpine.LNX.2.00.1602280009110.22700@cbobk.fhfr.pm>
In-Reply-To: <alpine.LNX.2.00.1602280009110.22700@cbobk.fhfr.pm>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiri Kosina <jikos@kernel.org>
Cc: Theodore Ts'o <tytso@mit.edu>, Jianyu Zhan <nasa4836@gmail.com>, Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, rientjes@google.com, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, vdavydov@virtuozzo.com, Dan Williams <dan.j.williams@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Chen Gang <gang.chen.5i5j@gmail.com>


On 2/28/16 07:14, Jiri Kosina wrote:
> On Sat, 27 Feb 2016, Chen Gang wrote:
> 
>>> Mel, as an MM developer, has already NACK'ed the patch, which means
>>> you should not send the patch to **any** upstream maintainer for
>>> inclusion.
>>
>> I don't think I "should not ...". I only care about correctness and
>> contribution, I don't care about any members ideas and their thinking.
>> When we have different ideas or thinking, we need discuss.
> 
> If by "discuss" you mean "30+ email thread about where to put a line 
> break", please drop me from CC next time this discussion is going to 
> happen. Thanks.
> 

Excuse me, when I sent this patch, I did not know who I shall send to, I
have to reference to "./scripts/get_maintainer.pl".

If any members have no time to care about it (every members' time are
really expensive), please let me know (can reply directly).

Thanks.

>> For common shared header files, for me, we should really take more care
>> about the coding styles.
>>
>>  - If the common shared header files don't care about the coding styles,
>>    I guess any body files will have much more excuses for "do not care
>>    about coding styles".
>>
>>  - That means our kernel whole source files need not care about coding
>>    styles at all!!
>>
>>  - It is really really VERY BAD!!
>>
>> If someone only dislike me to send the related patches, I suggest: Let
>> another member(s) "run checkpatch -file" on the whole "./include" sub-
>> directory, and fix all coding styles issues.
> 
> Which is exactly what you shouldn't do.
> 

For me, I also guess, I am not the suitable member to do that (in fact,
I dislike to do like that - "run checkpath -file" on "./include").

> The ultimate goal of the Linux kernel is not 100% strict complicance to 
> the CodingStyle document no matter what. The ultimate goal is to have a 
> kernel that is under control. By polluting git blame, you are taking on 
> aspect of the "under control" away.
> 

Yes, the ultimate goal of CodingStyle is to have a kernel that is under
control.

For me, most of files in "./include" are common, simple, and shared
files, which are not quite related with code analyzing (e.g. git log -p,
or git blame), but they are read by others in most times. Is it correct?


> Common sense needs to be used; horribly terrible coding style needs to be 
> fixed, sure. Is 82-characters long line horribly terrible coding style? 
> No, it's not.
> 

For me, what you said above have effect on body files (in kernel, at
least, more than 95% source files are body files, I guess).

But in "./include", most of files are the interface inside and outside
of our kernel, we need take more care about their coding styles.

I often use vertical split window in vim in full screen mode to reading
source code, when I read c source files, I often split window vertically
for the related header files as reference.


Thanks.
-- 
Chen Gang (e??a??)

Managing Natural Environments is the Duty of Human Beings.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
