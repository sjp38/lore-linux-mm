Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 30E7E6B0069
	for <linux-mm@kvack.org>; Fri, 14 Oct 2016 06:10:06 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id z54so75397279qtz.0
        for <linux-mm@kvack.org>; Fri, 14 Oct 2016 03:10:06 -0700 (PDT)
Received: from mail-qk0-x22f.google.com (mail-qk0-x22f.google.com. [2607:f8b0:400d:c09::22f])
        by mx.google.com with ESMTPS id m82si9200132qki.283.2016.10.14.03.10.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Oct 2016 03:10:05 -0700 (PDT)
Received: by mail-qk0-x22f.google.com with SMTP id z190so138938195qkc.2
        for <linux-mm@kvack.org>; Fri, 14 Oct 2016 03:10:05 -0700 (PDT)
MIME-Version: 1.0
Reply-To: mtk.manpages@gmail.com
In-Reply-To: <alpine.DEB.2.20.1610131314020.3176@east.gentwo.org>
References: <f3c4ca9d-a880-5244-e06e-db4725e4d945@gmail.com> <alpine.DEB.2.20.1610131314020.3176@east.gentwo.org>
From: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Date: Fri, 14 Oct 2016 12:09:44 +0200
Message-ID: <CAKgNAkiMo-AMZ2PUm3A8NqfiNa+GOnRFn4NrFwjRJa8Z7xNsPw@mail.gmail.com>
Subject: Re: Rewording language in mbind(2) to "threads" not "processes"
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Piotr Kwapulinski <kwapulinski.piotr@gmail.com>, mhocko@kernel.org, mgorman@techsingularity.net, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, linux-man <linux-man@vger.kernel.org>, Brice Goglin <Brice.Goglin@inria.fr>

Hi Christoph,

On 13 October 2016 at 20:16, Christoph Lameter <cl@linux.com> wrote:
> On Thu, 13 Oct 2016, Michael Kerrisk (man-pages) wrote:
>
>> @@ -100,7 +100,10 @@ If, however, the shared memory region was created with the
>>  .B SHM_HUGETLB
>>  flag,
>>  the huge pages will be allocated according to the policy specified
>> -only if the page allocation is caused by the process that calls
>> +only if the page allocation is caused by the thread that calls
>> +.\"
>> +.\" ??? Is it correct to change "process" to "thread" in the preceding line?
>
> No leave it as process. Pages get one map refcount per page table
> that references them (meaning a process). More than one map refcount means
> that multiple processes have mapped the page.
>
>> @@ -300,7 +303,10 @@ is specified in
>>  .IR flags ,
>>  then the kernel will attempt to move all the existing pages
>>  in the memory range so that they follow the policy.
>> -Pages that are shared with other processes will not be moved.
>> +Pages that are shared with other threads will not be moved.
>> +.\"
>> +.\" ??? Is it correct to change "processes" to "threads" in the preceding line?
>> +.\"
>
> Leave it. Same as before.
>
>>  If
>>  then the kernel will attempt to move all existing pages in the memory range
>> -regardless of whether other processes use the pages.
>> -The calling process must be privileged
>> +regardless of whether other threads use the pages.
>> +.\"
>> +.\" ??? Is it correct to change "processes" to "threads" in the preceding line?
>> +.\"
>
> Leave as process.

Thanks. So, are all the other cases where I changed "process" to
"thread" okay then?

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
