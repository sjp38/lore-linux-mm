Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id F038F6B0253
	for <linux-mm@kvack.org>; Tue, 28 Jul 2015 17:15:45 -0400 (EDT)
Received: by padck2 with SMTP id ck2so75604131pad.0
        for <linux-mm@kvack.org>; Tue, 28 Jul 2015 14:15:45 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id pj10si3790105pac.162.2015.07.28.14.15.44
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Jul 2015 14:15:45 -0700 (PDT)
Subject: Re: hugetlb pages not accounted for in rss
References: <55B6BE37.3010804@oracle.com>
 <20150728183248.GB1406@Sligo.logfs.org>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <55B7F0F8.8080909@oracle.com>
Date: Tue, 28 Jul 2015 14:15:36 -0700
MIME-Version: 1.0
In-Reply-To: <20150728183248.GB1406@Sligo.logfs.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?Q?J=c3=b6rn_Engel?= <joern@purestorage.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

On 07/28/2015 11:32 AM, Jorn Engel wrote:
> On Mon, Jul 27, 2015 at 04:26:47PM -0700, Mike Kravetz wrote:
>> I started looking at the hugetlb self tests.  The test hugetlbfstest
>> expects hugetlb pages to be accounted for in rss.  However, there is
>> no code in the kernel to do this accounting.
>>
>> It looks like there was an effort to add the accounting back in 2013.
>> The test program made it into tree, but the accounting code did not.
>
> My apologies.  Upstream work always gets axed first when I run out of
> time - which happens more often than not.

No worries, I just noticed the inconsistency of the test program and
no supporting code in the kernel.

>> The easiest way to resolve this issue would be to remove the test and
>> perhaps document that hugetlb pages are not accounted for in rss.
>> However, it does seem like a big oversight that hugetlb pages are not
>> accounted for in rss.  From a quick scan of the code it appears THP
>> pages are properly accounted for.
>>
>> Thoughts?
>
> Unsurprisingly I agree that hugepages should count towards rss.  Keeping
> the test in keeps us honest.  Actually fixing the issue would make us
> honest and correct.
>
> Increasingly we have tiny processes (by rss) that actually consume large
> fractions of total memory.  Makes rss somewhat useless as a measure of
> anything.

I'll take a look at what it would take to get the accounting in place.
-- 
Mike Kravetz

>
> Jorn
>
> --
> Consensus is no proof!
> -- John Naisbitt
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
