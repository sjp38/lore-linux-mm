Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5D0D7280266
	for <linux-mm@kvack.org>; Sun, 25 Sep 2016 09:52:22 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id fi2so58778443pad.3
        for <linux-mm@kvack.org>; Sun, 25 Sep 2016 06:52:22 -0700 (PDT)
Received: from out4441.biz.mail.alibaba.com (out4441.biz.mail.alibaba.com. [47.88.44.41])
        by mx.google.com with ESMTP id n125si19583033pfn.267.2016.09.25.06.52.17
        for <linux-mm@kvack.org>;
        Sun, 25 Sep 2016 06:52:18 -0700 (PDT)
Message-ID: <57E7D84D.30903@emindsoft.com.cn>
Date: Sun, 25 Sep 2016 21:59:41 +0800
From: Chen Gang <chengang@emindsoft.com.cn>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: migrate: Return false instead of -EAGAIN for dummy
 functions
References: <1474096836-31045-1-git-send-email-chengang@emindsoft.com.cn> <20160917154659.GA29145@dhcp22.suse.cz> <57E05CD2.5090408@emindsoft.com.cn> <20160920080923.GE5477@dhcp22.suse.cz> <57E1B2F4.5070009@emindsoft.com.cn> <20160921081149.GE10300@dhcp22.suse.cz>
In-Reply-To: <20160921081149.GE10300@dhcp22.suse.cz>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: akpm@linux-foundation.org, minchan@kernel.org, vbabka@suse.cz, mgorman@techsingularity.net, gi-oh.kim@profitbricks.com, opensource.ganesh@gmail.com, hughd@google.com, kirill.shutemov@linux.intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Chen Gang <gang.chen.5i5j@gmail.com>


Firstly, excuse me for replying late -- since I also agree, this patch
is not urgent ;-)
 
On 9/21/16 16:11, Michal Hocko wrote:
> On Wed 21-09-16 06:06:44, Chen Gang wrote:
>> On 9/20/16 16:09, Michal Hocko wrote:
> [...]
> 
> skipping the large part of the email because I do not have a spare time
> to discuss this.
>

I agree, they are not urgent, so if we have no time on it, just leave
it.

But for me, they are still important (not urgent != not important), so
every member can continue to discuss about it, when he/she have time,
e.g. Do we have another better solving way for this issue?

>>> So what is the point of this whole exercise? Do not take me wrong, this
>>> area could see some improvements but I believe that doing int->bool
>>> change is not just the right thing to do and worth spending both your
>>> and reviewers time.
>>>
>>
>> I am not quite sure about that.
> 
> Maybe you should listen to the feedback your are getting. I do not think
> I am not the first one here.
> 

OK, for me, normally, when a mailing list contents 100+ members, every
feedback has not only one member (especially, we have about 10K members).

> Look, MM surely needs some man power. There are issues to be solved,
> patches to review. Doing the cleanups is really nice but there are more
> serious problems to solve first.

OK, we really need a task management, for me, we need notice about the
urgent and important. If the patch or issue is either urgent nor
important, we can just drop it.

If they are not urgent, but still important, just discuss about it when
have time, but do not forget it (I guess, quite a few of volunteers can
not for urgent things -- their time resources are not stable, e.g. me).

>                                  If you want to help then starting
> with review would be much much more helpful and hugely appreciated. We
> are really lacking people there a _lot_.

I guess, I can try (at least, I want to try). But excuse me, in honest,
I am not quite familiar with mm, and my time resources are not stable
enough, either. So I am not quite sure I can do.

>                                          Just generating more work for
> reviewers with something that doesn't make any real difference in the
> runtime is far less helpful IMHO.
> 

For urgent things, really it is less helpful (in fact, it will generate
negative effect).

But if it is related with important things, we need discuss about it
when we have time (do not treat it as urgent thing).

For me, all issues in public header files are important, at least. When
a developer want to put or modify something in public header files, they
need think more -- since the members outside of mm may see them.


Thanks.
-- 
Chen Gang (e??a??)

Managing Natural Environments is the Duty of Human Beings.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
