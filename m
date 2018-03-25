Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6462A6B0007
	for <linux-mm@kvack.org>; Sat, 24 Mar 2018 20:32:35 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id f59-v6so10275209plb.7
        for <linux-mm@kvack.org>; Sat, 24 Mar 2018 17:32:35 -0700 (PDT)
Received: from out30-132.freemail.mail.aliyun.com (out30-132.freemail.mail.aliyun.com. [115.124.30.132])
        by mx.google.com with ESMTPS id a23si8956225pfn.161.2018.03.24.17.32.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 24 Mar 2018 17:32:34 -0700 (PDT)
Subject: Re: [PATCH] mm: introduce arg_lock to protect arg_start|end and
 env_start|end in mm_struct
References: <1521851771-108673-1-git-send-email-yang.shi@linux.alibaba.com>
 <20180324043044.GA22733@bombadil.infradead.org>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <aed7f679-a32f-d8d7-eb59-ec05fc49a70e@linux.alibaba.com>
Date: Sat, 24 Mar 2018 17:32:24 -0700
MIME-Version: 1.0
In-Reply-To: <20180324043044.GA22733@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: adobriyan@gmail.com, mhocko@kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 3/23/18 9:30 PM, Matthew Wilcox wrote:
>> So, introduce a new rwlock in mm_struct to protect the concurrent access
>> to arg_start|end and env_start|end.
> I don't think an rwlock makes much sense here.  There is almost no
> concurrency on the read side, and an rwlock is more expensive than
> a spinlock.  Just use a spinlock.

Thanks for the comment. Yes, actually there is not concurrency on the 
read side, will change to regular spin lock.

Yang
