Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2AAF26B0269
	for <linux-mm@kvack.org>; Wed, 10 Oct 2018 11:19:14 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id l19-v6so3388363edq.20
        for <linux-mm@kvack.org>; Wed, 10 Oct 2018 08:19:14 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k11-v6sor5632958ejk.3.2018.10.10.08.19.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 10 Oct 2018 08:19:13 -0700 (PDT)
Date: Wed, 10 Oct 2018 15:19:11 +0000
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH] mm: remove a redundant check in do_munmap()
Message-ID: <20181010151911.uslsfmr5wa3ujdwi@master>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20181010125327.68803-1-richard.weiyang@gmail.com>
 <20181010141320.zxic4ryuzo63utom@kshutemo-mobl1>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181010141320.zxic4ryuzo63utom@kshutemo-mobl1>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Wei Yang <richard.weiyang@gmail.com>, akpm@linux-foundation.org, mhocko@suse.com, linux-mm@kvack.org

On Wed, Oct 10, 2018 at 05:13:20PM +0300, Kirill A. Shutemov wrote:
>On Wed, Oct 10, 2018 at 08:53:27PM +0800, Wei Yang wrote:
>> A non-NULL vma returned from find_vma() implies:
>> 
>>    vma->vm_start <= start
>> Since len != 0, the following condition always hods:
>
>s/hods/holds/
>
>>    vma->vm_start < start + len = end
>> 
>> This means the if check would never be true.
>
>Have you considered overflow?
>

Thanks for your comment.

At the beginning of this function, we make sure (len <= TASK_SIZE - start).


-- 
Wei Yang
Help you, Help me
