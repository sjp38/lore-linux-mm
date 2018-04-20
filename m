Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id D29596B0005
	for <linux-mm@kvack.org>; Thu, 19 Apr 2018 20:18:39 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id f19-v6so757774plr.20
        for <linux-mm@kvack.org>; Thu, 19 Apr 2018 17:18:39 -0700 (PDT)
Received: from out30-133.freemail.mail.aliyun.com (out30-133.freemail.mail.aliyun.com. [115.124.30.133])
        by mx.google.com with ESMTPS id 7-v6si4486240pll.132.2018.04.19.17.18.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Apr 2018 17:18:38 -0700 (PDT)
Subject: Re: [RFC PATCH] fs: introduce ST_HUGE flag and set it to tmpfs and
 hugetlbfs
References: <1523999293-94152-1-git-send-email-yang.shi@linux.alibaba.com>
 <20180418102744.GA10397@infradead.org>
 <73090d4b-6831-805b-8b9d-5dff267428d9@linux.alibaba.com>
 <20180419082810.GA8624@infradead.org>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <9d8c9198-46c4-fd34-3546-c6f9b3fef0fb@linux.alibaba.com>
Date: Thu, 19 Apr 2018 17:18:20 -0700
MIME-Version: 1.0
In-Reply-To: <20180419082810.GA8624@infradead.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: viro@zeniv.linux.org.uk, nyc@holomorphy.com, mike.kravetz@oracle.com, kirill.shutemov@linux.intel.com, hughd@google.com, akpm@linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 4/19/18 1:28 AM, Christoph Hellwig wrote:
> On Wed, Apr 18, 2018 at 11:18:25AM -0700, Yang Shi wrote:
>> Yes, thanks for the suggestion. I did think about it before I went with the
>> new flag. Not like hugetlb, THP will *not* guarantee huge page is used all
>> the time, it may fallback to regular 4K page or may get split. I'm not sure
>> how the applications use f_bsize field, it might break existing applications
>> and the value might be abused by applications to have counter optimization.
>> So, IMHO, a new flag may sound safer.
> But st_blksize isn't the block size, that is why I suggested it.  It is
> the preferred I/O size, and various file systems can report way
> larger values than the block size already.

Thanks. If it is safe to applications, It definitely can return huge 
page size via st_blksize.

Is it safe to return huge page size via statfs->f_bsize? It sounds it 
has not to be the physical block size too. The man page says it is 
"Optimal transfer block size".

Yang
