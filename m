Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f169.google.com (mail-ig0-f169.google.com [209.85.213.169])
	by kanga.kvack.org (Postfix) with ESMTP id 3A7B16B0037
	for <linux-mm@kvack.org>; Tue, 11 Mar 2014 15:34:07 -0400 (EDT)
Received: by mail-ig0-f169.google.com with SMTP id h18so12441705igc.0
        for <linux-mm@kvack.org>; Tue, 11 Mar 2014 12:34:07 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id pg8si33105702icb.135.2014.03.11.12.34.06
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 11 Mar 2014 12:34:06 -0700 (PDT)
Message-ID: <531F6527.6010508@oracle.com>
Date: Tue, 11 Mar 2014 15:33:59 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH -mm] mm,numa,mprotect: always continue after finding a
 stable thp page
References: <5318E4BC.50301@oracle.com>	<20140306173137.6a23a0b2@cuia.bos.redhat.com>	<5318FC3F.4080204@redhat.com>	<20140307140650.GA1931@suse.de>	<20140307150923.GB1931@suse.de>	<20140307182745.GD1931@suse.de>	<20140311162845.GA30604@suse.de>	<531F3F15.8050206@oracle.com>	<531F4128.8020109@redhat.com>	<531F48CC.303@oracle.com>	<20140311180652.GM10663@suse.de>	<531F616A.7060300@oracle.com> <20140311122859.fb6c1e772d82d9f4edd02f52@linux-foundation.org>
In-Reply-To: <20140311122859.fb6c1e772d82d9f4edd02f52@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, hhuang@redhat.com, knoel@redhat.com, aarcange@redhat.com, Davidlohr Bueso <davidlohr@hp.com>

On 03/11/2014 03:28 PM, Andrew Morton wrote:
> On Tue, 11 Mar 2014 15:18:02 -0400 Sasha Levin <sasha.levin@oracle.com> wrote:
>
>>> 3. Can you test with the following patches reverted please?
>>>
>>> 	e15d25d9c827b4346a36a3a78dd566d5ad353402 mm-per-thread-vma-caching-fix-fix
>>> 	e440e20dc76803cdab616b4756c201d5c72857f2 mm-per-thread-vma-caching-fix
>>> 	0d9ad4220e6d73f63a9eeeaac031b92838f75bb3 mm: per-thread vma caching
>>>
>>> The last patch will not revert cleanly (least it didn't for me) but it
>>> was just a case of git rm the two affected files, remove any include of
>>> vmacache.h and commit the rest.
>>
>> Don't see the issues I've reported before now.
>
> This is foggy.  Do you mean that all the bugs went away when
> per-thread-vma-caching was reverted?

No, sorry, just the vmacache_find and the mm/mmap.c:439 BUGs.


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
