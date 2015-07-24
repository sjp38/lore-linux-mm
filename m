Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f50.google.com (mail-la0-f50.google.com [209.85.215.50])
	by kanga.kvack.org (Postfix) with ESMTP id 559EF9003C7
	for <linux-mm@kvack.org>; Fri, 24 Jul 2015 02:57:56 -0400 (EDT)
Received: by laah7 with SMTP id h7so8632328laa.0
        for <linux-mm@kvack.org>; Thu, 23 Jul 2015 23:57:55 -0700 (PDT)
Received: from mail-lb0-x22b.google.com (mail-lb0-x22b.google.com. [2a00:1450:4010:c04::22b])
        by mx.google.com with ESMTPS id zl2si6692087lbb.55.2015.07.23.23.57.53
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Jul 2015 23:57:54 -0700 (PDT)
Received: by lbbyj8 with SMTP id yj8so9231814lbb.0
        for <linux-mm@kvack.org>; Thu, 23 Jul 2015 23:57:53 -0700 (PDT)
MIME-Version: 1.0
Reply-To: mtk.manpages@gmail.com
In-Reply-To: <alpine.DEB.2.10.1507231349080.31024@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1507211736300.24133@chino.kir.corp.google.com>
 <55B027D3.4020608@oracle.com> <alpine.DEB.2.10.1507221646100.14953@chino.kir.corp.google.com>
 <55B0E900.8090207@gmail.com> <alpine.DEB.2.10.1507231349080.31024@chino.kir.corp.google.com>
From: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Date: Fri, 24 Jul 2015 08:57:34 +0200
Message-ID: <CAKgNAkj+FvuXh0sjx6A_RD9_0BaYm_xsyXS6Ym5svcmXtBVKmg@mail.gmail.com>
Subject: Re: [patch] mmap.2: document the munmap exception for underlying page size
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Mike Kravetz <mike.kravetz@oracle.com>, Hugh Dickins <hughd@google.com>, Davide Libenzi <davidel@xmailserver.org>, Eric B Munson <emunson@akamai.com>, lkml <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-man <linux-man@vger.kernel.org>

Hello David,

On 23 July 2015 at 22:52, David Rientjes <rientjes@google.com> wrote:
> On Thu, 23 Jul 2015, Michael Kerrisk (man-pages) wrote:
>
>> >> Should we also add a similar comment for the mmap offset?  Currently
>> >> the man page says:
>> >>
>> >> "offset must be a multiple of the page size as returned by
>> >>  sysconf(_SC_PAGE_SIZE)."
>> >>
>> >> For hugetlbfs, I beieve the offset must be a multiple of the
>> >> hugetlb page size.  A similar comment/exception about using
>> >> the "underlying page size" would apply here as well.
>> >>
>> >
>> > Yes, that makes sense, thanks.  We should also explicitly say that mmap(2)
>> > automatically aligns length to be hugepage aligned if backed by hugetlbfs.
>>
>> And, surely, it also does something similar for mmap()'s 'addr'
>> argument?
>>
>> I suggest we add a subsection to describe the HugeTLB differences. How
>> about something like:
>>
>>    Huge page (Huge TLB) mappings
>>        For  mappings  that  employ  huge pages, the requirements for the
>>        arguments  of  mmap()  and  munmap()  differ  somewhat  from  the
>>        requirements for mappings that use the native system page size.
>>
>>        For mmap(), offset must be a multiple of the underlying huge page
>>        size.  The system automatically aligns length to be a multiple of
>>        the underlying huge page size.
>>
>>        For  munmap(),  addr  and  length  must both be a multiple of the
>>        underlying huge page size.
>> ?
>>
>
> Looks good, please add my acked-by.

Done. Thanks for checking the text.

> The commit that expanded on the
> documentation of this behavior was
> 80d6b94bd69a7a49b52bf503ef6a841f43cf5bbb.
>
> Answering from your other email, no, this behavior in the kernel has not
> changed recently but we found it wasn't properly documented so we wanted
> to fix that both in the kernel tree and in the man-pages to make it
> explicit.

Okay -- thanks for the clarification.

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
