Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9117B6B48B0
	for <linux-mm@kvack.org>; Tue, 28 Aug 2018 19:31:10 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id 132-v6so2064786pga.18
        for <linux-mm@kvack.org>; Tue, 28 Aug 2018 16:31:10 -0700 (PDT)
Received: from sonic302-49.consmr.mail.gq1.yahoo.com (sonic302-49.consmr.mail.gq1.yahoo.com. [98.137.68.175])
        by mx.google.com with ESMTPS id j19-v6si2292667pgb.623.2018.08.28.16.31.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Aug 2018 16:31:09 -0700 (PDT)
From: Gao Xiang <hsiangkao@aol.com>
Subject: Re: Tagged pointers in the XArray
References: <20180828222727.GD11400@bombadil.infradead.org>
Message-ID: <8f565135-ffe4-e8a6-8a6f-4b74cedd4209@aol.com>
Date: Wed, 29 Aug 2018 07:26:57 +0800
MIME-Version: 1.0
In-Reply-To: <20180828222727.GD11400@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
Cc: Matthew Wilcox <willy@infradead.org>, Gao Xiang <gaoxiang25@huawei.com>, zhong jiang <zhongjiang@huawei.com>, Chao Yu <yuchao0@huawei.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>

Hi,

On 2018/8/29 6:27, Matthew Wilcox wrote:
> I find myself caught between two traditions.
>
> On the one hand, the radix tree has been calling the page cache dirty &
> writeback bits "tags" for over a decade.
>
> On the other hand, using some of the bits _in a pointer_ as a tag has been
> common practice since at least the 1960s.
> https://en.wikipedia.org/wiki/Tagged_pointer and
> https://en.wikipedia.org/wiki/31-bit

Personally I think this topic makes sense. These two `tags' are totally
different actually.

> EROFS wants to use tagged pointers in the radix tree / xarray.  Right now,
> they're building them by hand, which is predictably grotty-looking.
> I think it's reasonable to provide this functionality as part of the
> XArray API, _but_ it's confusing to have two different things called tags.
>
> I've done my best to document my way around this, but if we want to rename
> the things that the radix tree called tags to avoid the problem entirely,
> now is the time to do it.  Anybody got a Good Idea?

As Matthew pointed out, it is a good chance to rename one of them.


In addition to that, I am also looking forward to a better general
tagged pointer
implementation to wrap up operations for all these tags and restrict the
number of tag bits
at compile time. It is also useful to mark its usage and clean up these
magic masks
though the implementation could look a bit simple.

If you folks think the general tagged pointer is meaningless, please
ignore my words....
However according to my EROFS coding experience, code with different
kind of tagged
pointers by hand (directly use magic masks) will be in a mess, but it
also seems
unnecessary to introduce independent operations for each kind of tagged
pointers.


In the end, I also hope someone interested in this topic and thanks in
advance... :)


Thanks,
Gao Xiang
