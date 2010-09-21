Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 7180C6B004A
	for <linux-mm@kvack.org>; Tue, 21 Sep 2010 03:32:02 -0400 (EDT)
Message-ID: <31aed4ad96866a97dc791186303c5719.squirrel@www.firstfloor.org>
In-Reply-To: <20100921162316.3C03.A69D9226@jp.fujitsu.com>
References: <20100921022112.GA10336@localhost>
    <20100921061310.GA11526@localhost>
    <20100921162316.3C03.A69D9226@jp.fujitsu.com>
Date: Tue, 21 Sep 2010 09:31:58 +0200
Subject: Re: Problem with debugfs
From: "Andi Kleen" <andi@firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain;charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Kenneth <liguozhu@huawei.com>, greg@kroah.com, linux-kernel@vger.kernel.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andi Kleen <andi@firstfloor.org>, linux-mm <linux-mm@kvack.org>, fengguang.wu@intel.com
List-ID: <linux-mm.kvack.org>

x

>> I'm sorry I had not checked the git before sending my last mail.
>>
>> For the problem I mention, consider this scenarios:
>>
>> 1. mm/hwpoinson-inject.c create a debugfs file with
>>    debugfs_create_u64("corrupt-filter-flags-mask", ...,
>>    &hwpoison_filter_flags_mask)
>> 2. hwpoison_filter_flags_mask is supposed to be protected by
>> filp->priv->mutex
>>    of this file when it is accessed from user space.
>> 3. but when it is accessed from
>> mm/memory-failure.c:hwpoison_filter_flags,
>>    there is no way for the function to protect the operation (so it
>> simply
>>    ignore it). This may create a competition problem.
>>
>> It should be a problem.
>>
>> I'm sorry from my poor English skill.
>
> I think your english is very clear :)
> Let's cc hwpoison folks.

Thanks for the report.
Copying Fengguang who wrote that code.

-Andi


>  - kosaki
>
>
>>
>> Best Regards
>> Kenneth Lee
>>
>> On Tue, Sep 21, 2010 at 10:21:12AM +0800, kenny wrote:
>> > Hi, there,
>> >
>> > I do not know who is the maintainer for debugfs now. But I think there
>> is
>> > problem with its API: It uses filp->priv->mutex to protect the
>> read/write (to
>> > the file) for the value of its attribute, but the mutex is not
>> exported to the
>> > API user.  Therefore, there is no way to protect its value when you
>> directly
>> > use the value in your module.
>> >
>> > Is my understanding correct?
>> >
>> > Thanks
>> >
>> >
>> > Best Regards
>> > Kenneth Lee
>>
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-kernel"
>> in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>> Please read the FAQ at  http://www.tux.org/lkml/
>
>
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
