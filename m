Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id BD1556B003B
	for <linux-mm@kvack.org>; Wed, 17 Apr 2013 02:43:03 -0400 (EDT)
Received: by mail-ia0-f182.google.com with SMTP id u20so1131796iag.41
        for <linux-mm@kvack.org>; Tue, 16 Apr 2013 23:43:03 -0700 (PDT)
Message-ID: <516E446B.5060006@gmail.com>
Date: Wed, 17 Apr 2013 14:42:51 +0800
From: Simon Jeons <simon.jeons@gmail.com>
MIME-Version: 1.0
Subject: Re: [RFC Patch 0/2] mm: Add parameters to make kernel behavior at
 memory error on dirty cache selectable
References: <51662D5B.3050001@hitachi.com> <20130411134915.GH16732@two.firstfloor.org> <1365693788-djsd2ymu-mutt-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1365693788-djsd2ymu-mutt-n-horiguchi@ah.jp.nec.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andi Kleen <andi@firstfloor.org>, Mitsuhiro Tanino <mitsuhiro.tanino.gm@hitachi.com>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>

Hi Naoya,
On 04/11/2013 11:23 PM, Naoya Horiguchi wrote:
> On Thu, Apr 11, 2013 at 03:49:16PM +0200, Andi Kleen wrote:
>>> As a result, if the dirty cache includes user data, the data is lost,
>>> and data corruption occurs if an application uses old data.
>> The application cannot use old data, the kernel code kills it if it
>> would do that. And if it's IO data there is an EIO triggered.
>>
>> iirc the only concern in the past was that the application may miss
>> the asynchronous EIO because it's cleared on any fd access. 
>>
>> This is a general problem not specific to memory error handling, 
>> as these asynchronous IO errors can happen due to other reason
>> (bad disk etc.) 
>>
>> If you're really concerned about this case I think the solution
>> is to make the EIO more sticky so that there is a higher chance
>> than it gets returned.  This will make your data much more safe,
>> as it will cover all kinds of IO errors, not just the obscure memory
>> errors.
> I'm interested in this topic, and in previous discussion, what I was said
> is that we can't expect user applications to change their behaviors when
> they get EIO, so globally changing EIO's stickiness is not a great approach.

The user applications will get EIO firstly or get SIG_KILL firstly?

> I'm working on a new pagecache tag based mechanism to solve this.
> But it needs time and more discussions.
> So I guess Tanino-san suggests giving up on dirty pagecache errors
> as a quick solution.
>
> Thanks,
> Naoya
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
