Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 97C136B0005
	for <linux-mm@kvack.org>; Tue, 12 Jun 2018 08:36:23 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id x22-v6so6424445wmc.7
        for <linux-mm@kvack.org>; Tue, 12 Jun 2018 05:36:23 -0700 (PDT)
Received: from huawei.com (lhrrgout.huawei.com. [194.213.3.17])
        by mx.google.com with ESMTPS id a66-v6si272651wmc.42.2018.06.12.05.36.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Jun 2018 05:36:21 -0700 (PDT)
Subject: Re: Distinguishing VMalloc pages
References: <20180611121129.GB12912@bombadil.infradead.org>
 <c99d981a-d55e-1759-a14a-4ef856072618@gmail.com>
 <20180612113615.GB19433@bombadil.infradead.org>
From: Igor Stoppa <igor.stoppa@huawei.com>
Message-ID: <bfb6a847-0a8b-b03b-b61f-a16861cb5cb7@huawei.com>
Date: Tue, 12 Jun 2018 15:35:56 +0300
MIME-Version: 1.0
In-Reply-To: <20180612113615.GB19433@bombadil.infradead.org>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>, Igor Stoppa <igor.stoppa@gmail.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org



On 12/06/18 14:36, Matthew Wilcox wrote:
> On Tue, Jun 12, 2018 at 12:54:09PM +0300, Igor Stoppa wrote:

[...]

>> Although, in your case, you noticed a problem with userspace, while I do
>> not care at all about that, so maybe there is some wriggling space there ...
> 
> Yes; if your pages can never be mapped to userspace, then there's no
> problem.  Many other users of struct page use the page->mapping field
> for other purposes.
> 
>> Why not having a reference (either direct or indirect) to the actual
>> vmap area, and then the flag there, instead?
> 
> Because what we're trying to do is find out "Given a random struct page,
> what is it used for".  It might be page cache, it might be slab, it
> might be anything.  We can't go round randomly dereferencing pointers
> and seeing what pot of gold is at the end of that rainbow.

Ah, I had understood that it was already given that it was a vmalloc page.

[...]

> It might be useful to refer to the earlier patch which included that
> information:
> 
> https://www.spinics.net/lists/linux-mm/msg152818.html

thank you,
igor
