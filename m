Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f45.google.com (mail-bk0-f45.google.com [209.85.214.45])
	by kanga.kvack.org (Postfix) with ESMTP id 9C8D06B0035
	for <linux-mm@kvack.org>; Fri,  4 Apr 2014 03:11:27 -0400 (EDT)
Received: by mail-bk0-f45.google.com with SMTP id na10so255340bkb.32
        for <linux-mm@kvack.org>; Fri, 04 Apr 2014 00:11:27 -0700 (PDT)
Received: from mail-bk0-x236.google.com (mail-bk0-x236.google.com [2a00:1450:4008:c01::236])
        by mx.google.com with ESMTPS id k5si3060698bko.274.2014.04.04.00.11.26
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 04 Apr 2014 00:11:26 -0700 (PDT)
Received: by mail-bk0-f54.google.com with SMTP id 6so254587bkj.41
        for <linux-mm@kvack.org>; Fri, 04 Apr 2014 00:11:26 -0700 (PDT)
Message-ID: <533E5B17.8010804@gmail.com>
Date: Fri, 04 Apr 2014 09:11:19 +0200
From: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: msync: require either MS_ASYNC or MS_SYNC
References: <533B04A9.6090405@bbn.com> <20140402111032.GA27551@infradead.org>	<1396439119.2726.29.camel@menhir> <533CA0F6.2070100@bbn.com>	<CAKgNAki8U+j0mvYCg99j7wJ2Z7ve-gxusVbM3zdog=hKGPdidQ@mail.gmail.com> <rmivbuqy3hr.fsf@fnord.ir.bbn.com>
In-Reply-To: <rmivbuqy3hr.fsf@fnord.ir.bbn.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Troxel <gdt@ir.bbn.com>
Cc: mtk.manpages@gmail.com, Richard Hansen <rhansen@bbn.com>, Steven Whitehouse <swhiteho@redhat.com>, Christoph Hellwig <hch@infradead.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, Peter Zijlstra <peterz@infradead.org>

Hi Greg,

On 04/03/2014 02:57 PM, Greg Troxel wrote:
> 
> "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com> writes:
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
>>
>> Comments on this draft welcome.
> 
> I think it's a step backwards to document unspecified behavior.  If
> anything, the man page should make it clear that providing neither flag
> results in undefined behavior and will lead to failure on systems on
> than Linux.  While I can see the point of not changing the previous
> behavior to protect buggy code, there's no need to document it in the
> man page and further enshrine it.

The Linux behavior is what it is. For the reasons I mentioned already,
it's unlikely to change. And, when the man pages omit to explain what
Linux actually does, there will one day come a request to actually
document the behavior. So, I don't think it's quite enough to say the 
behavior is undefined. On the other hand, it does not hurt to further
expand the portability warning. I made the text now:

    NOTES
       According to POSIX, either MS_SYNC or MS_ASYNC must be  specified
       in  flags, and  indeed failure to include one of these flags will
       cause msync() to fail on some systems.  However, Linux permits  a
       call  to  msync()  that  specifies  neither  of these flags, with
       semantics that are (currently) equivalent to specifying MS_ASYNC.
       (Since  Linux 2.6.19, MS_ASYNC is in fact a no-op, since the kera??
       nel properly tracks dirty pages and flushes them  to  storage  as
       necessary.)    Notwithstanding   the  Linux  behavior,  portable,
       future-proof applications should ensure that they specify  either
       MS_SYNC or MS_ASYNC in flags.




-- 
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
Linux/UNIX System Programming Training: http://man7.org/training/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
