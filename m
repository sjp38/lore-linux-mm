Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f50.google.com (mail-bk0-f50.google.com [209.85.214.50])
	by kanga.kvack.org (Postfix) with ESMTP id 3F5AE6B0031
	for <linux-mm@kvack.org>; Sat,  5 Apr 2014 01:57:00 -0400 (EDT)
Received: by mail-bk0-f50.google.com with SMTP id w10so370966bkz.37
        for <linux-mm@kvack.org>; Fri, 04 Apr 2014 22:56:59 -0700 (PDT)
Received: from mail-bk0-x22a.google.com (mail-bk0-x22a.google.com [2a00:1450:4008:c01::22a])
        by mx.google.com with ESMTPS id ur10si3818422bkb.66.2014.04.04.22.56.57
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 04 Apr 2014 22:56:57 -0700 (PDT)
Received: by mail-bk0-f42.google.com with SMTP id mx12so379195bkb.1
        for <linux-mm@kvack.org>; Fri, 04 Apr 2014 22:56:56 -0700 (PDT)
Message-ID: <533E571C.4080902@gmail.com>
Date: Fri, 04 Apr 2014 08:54:20 +0200
From: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: msync: require either MS_ASYNC or MS_SYNC
References: <533B04A9.6090405@bbn.com> <20140402111032.GA27551@infradead.org> <1396439119.2726.29.camel@menhir> <533CA0F6.2070100@bbn.com> <CAKgNAki8U+j0mvYCg99j7wJ2Z7ve-gxusVbM3zdog=hKGPdidQ@mail.gmail.com> <533D4B42.4040600@codeaurora.org>
In-Reply-To: <533D4B42.4040600@codeaurora.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Covington <cov@codeaurora.org>
Cc: mtk.manpages@gmail.com, Richard Hansen <rhansen@bbn.com>, Steven Whitehouse <swhiteho@redhat.com>, Christoph Hellwig <hch@infradead.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, Greg Troxel <gdt@ir.bbn.com>, Peter Zijlstra <peterz@infradead.org>

On 04/03/2014 01:51 PM, Christopher Covington wrote:
> On 04/03/2014 04:25 AM, Michael Kerrisk (man-pages) wrote:
> 
>> I think the only reasonable solution is to better document existing
>> behavior and what the programmer should do. With that in mind, I've
>> drafted the following text for the msync(2) man page:
>>
>>     NOTES
>>        According to POSIX, exactly one of MS_SYNC and MS_ASYNC  must  be
>>        specified  in  flags.   However,  Linux permits a call to msync()
>>        that specifies neither of these flags, with  semantics  that  are
>>        (currently)  equivalent  to  specifying  MS_ASYNC.   (Since Linux
>>        2.6.19, MS_ASYNC is in fact a no-op, since  the  kernel  properly
>>        tracks  dirty  pages  and  flushes them to storage as necessary.)
>>        Notwithstanding the Linux behavior, portable, future-proof applia??
>>        cations  should  ensure  that they specify exactly one of MS_SYNC
>>        and MS_ASYNC in flags.
> 
> Nit: MS_SYNC or MS_ASYNC

Thanks. Reworded.

Cheers,

Michael

-- 
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
Linux/UNIX System Programming Training: http://man7.org/training/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
