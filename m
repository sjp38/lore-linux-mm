Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 46AF16B026C
	for <linux-mm@kvack.org>; Thu, 31 May 2018 21:22:23 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id x32-v6so14281626pld.16
        for <linux-mm@kvack.org>; Thu, 31 May 2018 18:22:23 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id u6-v6sor6106070plz.37.2018.05.31.18.22.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 31 May 2018 18:22:22 -0700 (PDT)
Subject: Re: Can kfree() sleep at runtime?
References: <30ecafd7-ed61-907b-f924-77fc37dcc753@gmail.com>
 <20180531140808.GA30221@bombadil.infradead.org>
 <01000163b68a8026-56fb6a35-040b-4af9-8b73-eb3b4a41c595-000000@email.amazonses.com>
 <20180531141452.GC30221@bombadil.infradead.org>
 <01000163b69b6b62-6c5ac940-d6c1-419a-9dc9-697908020c53-000000@email.amazonses.com>
From: Jia-Ju Bai <baijiaju1990@gmail.com>
Message-ID: <066df211-4d1e-787b-b89d-31b8827ea7a5@gmail.com>
Date: Fri, 1 Jun 2018 09:22:00 +0800
MIME-Version: 1.0
In-Reply-To: <01000163b69b6b62-6c5ac940-d6c1-419a-9dc9-697908020c53-000000@email.amazonses.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>, Matthew Wilcox <willy@infradead.org>
Cc: penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>



On 2018/5/31 22:30, Christopher Lameter wrote:
> On Thu, 31 May 2018, Matthew Wilcox wrote:
>
>>> Freeing a page in the page allocator also was traditionally not sleeping.
>>> That has changed?
>> No.  "Your bug" being "The bug in your static analysis tool".  It probably
>> isn't following the data flow correctly (or deeply enough).
> Well ok this is not going to trigger for kfree(), this is x86 specific and
> requires CONFIG_DEBUG_PAGEALLOC and a free of a page in a huge page.
>
> Ok that is a very contorted situation but how would a static checker deal
> with that?

I admit that my tool does not follow the data flow well, and I need to 
improve it.
In this case of kfree(), I want know how the data flow leads to my mistake.


Best wishes,
Jia-Ju Bai
