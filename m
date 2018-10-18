Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1ACE36B0003
	for <linux-mm@kvack.org>; Thu, 18 Oct 2018 10:10:13 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id c26-v6so18488950eda.7
        for <linux-mm@kvack.org>; Thu, 18 Oct 2018 07:10:13 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v50-v6sor15933327edm.6.2018.10.18.07.10.11
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 18 Oct 2018 07:10:11 -0700 (PDT)
Date: Thu, 18 Oct 2018 14:10:08 +0000
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH] mm: get pfn by page_to_pfn() instead of save in
 page->private
Message-ID: <20181018141008.lcyttmp7bb42uigi@master>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20181018130429.37837-1-richard.weiyang@gmail.com>
 <20181018131504.GC18839@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181018131504.GC18839@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: Wei Yang <richard.weiyang@gmail.com>, akpm@linux-foundation.org, mgorman@techsingularity.net, linux-mm@kvack.org

On Thu, Oct 18, 2018 at 03:15:04PM +0200, Michal Hocko wrote:
>On Thu 18-10-18 21:04:29, Wei Yang wrote:
>> This is not necessary to save the pfn to page->private.
>> 
>> The pfn could be retrieved by page_to_pfn() directly.
>
>Yes it can, but a cursory look at the commit which has introduced this
>suggests that this is a micro-optimization. Mel would know more of
>course. There are some memory models where page_to_pfn is close to free.
>
>If that is the case I am not really sure it is measurable or worth it.
>In any case any change to this code should have a proper justification.
>In other words, is this change really needed? Does it help in any
>aspect? Possibly readability? The only thing I can guess from this
>changelog is that you read the code and stumble over this. If that is
>the case I would recommend asking author for the motivation and
>potentially add a comment to explain it better rather than shoot a patch
>rightaway.
>

Your are right. I am really willing to understand why we want to use
this mechanisum.

So the correct procedure is to send a mail to the mail list to query the
reason?
