Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 52ABC6B0069
	for <linux-mm@kvack.org>; Tue, 13 Sep 2016 10:09:16 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id e1so356549594itb.0
        for <linux-mm@kvack.org>; Tue, 13 Sep 2016 07:09:16 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTP id h35si14230426otb.237.2016.09.13.07.09.02
        for <linux-mm@kvack.org>;
        Tue, 13 Sep 2016 07:09:03 -0700 (PDT)
Message-ID: <57D806C5.8070305@huawei.com>
Date: Tue, 13 Sep 2016 22:01:41 +0800
From: zhong jiang <zhongjiang@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: fix oom work when memory is under pressure
References: <1473173226-25463-1-git-send-email-zhongjiang@huawei.com> <20160909114410.GG4844@dhcp22.suse.cz> <57D67A8A.7070500@huawei.com> <20160912111327.GG14524@dhcp22.suse.cz> <57D6B0C4.6040400@huawei.com> <20160912174445.GC14997@dhcp22.suse.cz> <57D7FB71.9090102@huawei.com> <20160913132854.GB6592@dhcp22.suse.cz>
In-Reply-To: <20160913132854.GB6592@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: akpm@linux-foundation.org, vbabka@suse.cz, rientjes@google.com, linux-mm@kvack.org, Xishi Qiu <qiuxishi@huawei.com>, Hanjun Guo <guohanjun@huawei.com>

On 2016/9/13 21:28, Michal Hocko wrote:
> On Tue 13-09-16 21:13:21, zhong jiang wrote:
>> On 2016/9/13 1:44, Michal Hocko wrote:
> [...]
>>> If you want to solve this problem properly then you would have to give
>>> tasks which are looping in the page allocator access to some portion of
>>> memory reserves. This is quite tricky to do right, though.
>> To use some portion of memory reserves is almost no effect in a so
>> starvation scenario.  I think the hungtask still will occur. it can
>> not solve the problem primarily.
> Granting an access to memory reserves is of course no full solution but
> it raises chances for a forward progress. Other solutions would have to
> guarantee that the memory reclaimed on behalf of the requester will be
> given to the requester. Not an easy task
>
>>> Retry counters with the fail path have been proposed in the past and not
>>> accepted.
>> The above patch have been tested by runing the trinity.  The question
>> is fixed.  Is there any reasonable reason oppose to the patch ? or it
>> will bring in any side-effect.
> Sure there is. Low order allocations have been traditionally non failing
> and changing that behavior is a major obstacle because it opens up a
> door to many bugs. I've tried to do something similar in the past and
> there was a strong resistance against it. Believe me been there done
> that...
>
  That sounds resonable.  but So starvation scenario should unavoidable failed. In any case
  you mean  we need allow to allocate the low order.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
