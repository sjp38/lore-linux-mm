Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 64E136B0006
	for <linux-mm@kvack.org>; Thu, 18 Oct 2018 23:32:35 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id c26-v6so19567204eda.7
        for <linux-mm@kvack.org>; Thu, 18 Oct 2018 20:32:35 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v50-v6sor17148762edm.6.2018.10.18.20.32.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 18 Oct 2018 20:32:34 -0700 (PDT)
Date: Fri, 19 Oct 2018 03:32:32 +0000
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH] mm: get pfn by page_to_pfn() instead of save in
 page->private
Message-ID: <20181019033232.5nvr7yon366uelv6@master>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20181018130429.37837-1-richard.weiyang@gmail.com>
 <20181018131504.GC18839@dhcp22.suse.cz>
 <20181018141008.lcyttmp7bb42uigi@master>
 <20181018163039.GF18839@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181018163039.GF18839@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: Wei Yang <richard.weiyang@gmail.com>, akpm@linux-foundation.org, mgorman@techsingularity.net, linux-mm@kvack.org

On Thu, Oct 18, 2018 at 06:30:39PM +0200, Michal Hocko wrote:
>On Thu 18-10-18 14:10:08, Wei Yang wrote:
>> On Thu, Oct 18, 2018 at 03:15:04PM +0200, Michal Hocko wrote:
>> >On Thu 18-10-18 21:04:29, Wei Yang wrote:
>> >> This is not necessary to save the pfn to page->private.
>> >> 
>> >> The pfn could be retrieved by page_to_pfn() directly.
>> >
>> >Yes it can, but a cursory look at the commit which has introduced this
>> >suggests that this is a micro-optimization. Mel would know more of
>> >course. There are some memory models where page_to_pfn is close to free.
>> >
>> >If that is the case I am not really sure it is measurable or worth it.
>> >In any case any change to this code should have a proper justification.
>> >In other words, is this change really needed? Does it help in any
>> >aspect? Possibly readability? The only thing I can guess from this
>> >changelog is that you read the code and stumble over this. If that is
>> >the case I would recommend asking author for the motivation and
>> >potentially add a comment to explain it better rather than shoot a patch
>> >rightaway.
>> >
>> 
>> Your are right. I am really willing to understand why we want to use
>> this mechanisum.
>
>I am happy to hear that.
>
>> So the correct procedure is to send a mail to the mail list to query the
>> reason?
>
>It is certainly better to ask a question than send a patch without a
>proper justification. I would also encourage to use git blame to see
>which patch has introduced the specific piece of code. Many times it
>helps to understand the motivation. I would also encourage to go back to
>the mailing list archives and the associate discussion to the specific
>patch. In many cases there is Link: tag which can help you to find the
>respective discussion.
>

Sure, thanks for your suggestion.

>Thanks!
>
>-- 
>Michal Hocko
>SUSE Labs

-- 
Wei Yang
Help you, Help me
