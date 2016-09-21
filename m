Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 381E66B0263
	for <linux-mm@kvack.org>; Wed, 21 Sep 2016 04:13:59 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id t83so103464124oie.0
        for <linux-mm@kvack.org>; Wed, 21 Sep 2016 01:13:59 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e75si31290420wmg.2.2016.09.21.01.13.58
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 21 Sep 2016 01:13:58 -0700 (PDT)
Subject: Re: [PATCH] mm: migrate: Return false instead of -EAGAIN for dummy
 functions
References: <1474096836-31045-1-git-send-email-chengang@emindsoft.com.cn>
 <20160917154659.GA29145@dhcp22.suse.cz> <57E05CD2.5090408@emindsoft.com.cn>
 <20160920080923.GE5477@dhcp22.suse.cz> <57E1B2F4.5070009@emindsoft.com.cn>
 <20160921081149.GE10300@dhcp22.suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <000418bb-d513-136f-e3bb-f99b119c942a@suse.cz>
Date: Wed, 21 Sep 2016 10:13:55 +0200
MIME-Version: 1.0
In-Reply-To: <20160921081149.GE10300@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Chen Gang <chengang@emindsoft.com.cn>
Cc: akpm@linux-foundation.org, minchan@kernel.org, mgorman@techsingularity.net, gi-oh.kim@profitbricks.com, opensource.ganesh@gmail.com, hughd@google.com, kirill.shutemov@linux.intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Chen Gang <gang.chen.5i5j@gmail.com>

On 09/21/2016 10:11 AM, Michal Hocko wrote:
> On Wed 21-09-16 06:06:44, Chen Gang wrote:
>> On 9/20/16 16:09, Michal Hocko wrote:
> [...]
>
> skipping the large part of the email because I do not have a spare time
> to discuss this.
>
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
> Look, MM surely needs some man power. There are issues to be solved,
> patches to review. Doing the cleanups is really nice but there are more
> serious problems to solve first. If you want to help then starting
> with review would be much much more helpful and hugely appreciated. We
> are really lacking people there a _lot_. Just generating more work for
> reviewers with something that doesn't make any real difference in the
> runtime is far less helpful IMHO.

Agreed, thanks.

> Thanks.
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
