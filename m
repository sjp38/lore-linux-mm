Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 318136B0031
	for <linux-mm@kvack.org>; Thu,  3 Apr 2014 07:51:34 -0400 (EDT)
Received: by mail-pd0-f180.google.com with SMTP id v10so1668793pde.25
        for <linux-mm@kvack.org>; Thu, 03 Apr 2014 04:51:33 -0700 (PDT)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.11.231])
        by mx.google.com with ESMTPS id zt8si2977252pbc.58.2014.04.03.04.51.32
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Apr 2014 04:51:33 -0700 (PDT)
Message-ID: <533D4B42.4040600@codeaurora.org>
Date: Thu, 03 Apr 2014 07:51:30 -0400
From: Christopher Covington <cov@codeaurora.org>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: msync: require either MS_ASYNC or MS_SYNC
References: <533B04A9.6090405@bbn.com> <20140402111032.GA27551@infradead.org> <1396439119.2726.29.camel@menhir> <533CA0F6.2070100@bbn.com> <CAKgNAki8U+j0mvYCg99j7wJ2Z7ve-gxusVbM3zdog=hKGPdidQ@mail.gmail.com>
In-Reply-To: <CAKgNAki8U+j0mvYCg99j7wJ2Z7ve-gxusVbM3zdog=hKGPdidQ@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mtk.manpages@gmail.com
Cc: Richard Hansen <rhansen@bbn.com>, Steven Whitehouse <swhiteho@redhat.com>, Christoph Hellwig <hch@infradead.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, Greg Troxel <gdt@ir.bbn.com>, Peter Zijlstra <peterz@infradead.org>

On 04/03/2014 04:25 AM, Michael Kerrisk (man-pages) wrote:

> I think the only reasonable solution is to better document existing
> behavior and what the programmer should do. With that in mind, I've
> drafted the following text for the msync(2) man page:
> 
>     NOTES
>        According to POSIX, exactly one of MS_SYNC and MS_ASYNC  must  be
>        specified  in  flags.   However,  Linux permits a call to msync()
>        that specifies neither of these flags, with  semantics  that  are
>        (currently)  equivalent  to  specifying  MS_ASYNC.   (Since Linux
>        2.6.19, MS_ASYNC is in fact a no-op, since  the  kernel  properly
>        tracks  dirty  pages  and  flushes them to storage as necessary.)
>        Notwithstanding the Linux behavior, portable, future-proof applia??
>        cations  should  ensure  that they specify exactly one of MS_SYNC
>        and MS_ASYNC in flags.

Nit: MS_SYNC or MS_ASYNC

Christopher

-- 
Employee of Qualcomm Innovation Center, Inc.
Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum,
hosted by the Linux Foundation.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
