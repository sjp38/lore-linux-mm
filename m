Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f178.google.com (mail-ea0-f178.google.com [209.85.215.178])
	by kanga.kvack.org (Postfix) with ESMTP id 54FB36B00D4
	for <linux-mm@kvack.org>; Mon,  9 Dec 2013 12:12:19 -0500 (EST)
Received: by mail-ea0-f178.google.com with SMTP id d10so1699980eaj.37
        for <linux-mm@kvack.org>; Mon, 09 Dec 2013 09:12:18 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTP id i1si10421185eev.68.2013.12.09.09.12.18
        for <linux-mm@kvack.org>;
        Mon, 09 Dec 2013 09:12:18 -0800 (PST)
Message-ID: <52A5F9EE.4010605@suse.cz>
Date: Mon, 09 Dec 2013 18:12:14 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: kernel BUG in munlock_vma_pages_range
References: <52A3D0C3.1080504@oracle.com> <52A58E8A.3050401@suse.cz> <52A5F83F.4000207@oracle.com>
In-Reply-To: <52A5F83F.4000207@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: joern@logfs.org, mgorman@suse.de, Michel Lespinasse <walken@google.com>, riel@redhat.com, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 12/09/2013 06:05 PM, Sasha Levin wrote:
> On 12/09/2013 04:34 AM, Vlastimil Babka wrote:
>> Hello, I will look at it, thanks.
>> Do you have specific reproduction instructions?
>
> Not really, the fuzzer hit it once and I've been unable to trigger it again. Looking at
> the piece of code involved it might have had something to do with hugetlbfs, so I'll crank
> up testing on that part.

Thanks. Do you have trinity log and the .config file? I'm currently 
unable to even boot linux-next with my config/setup due to a GPF.
Looking at code I wouldn't expect that it could encounter a tail page, 
without first encountering a head page and skipping the whole huge page. 
At least in THP case, as TLB pages should be split when a vma is split. 
As for hugetlbfs, it should be skipped for mlock/munlock operations 
completely. One of these assumptions is probably failing here...

Vlastimil

>
> Thanks,
> Sasha
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
