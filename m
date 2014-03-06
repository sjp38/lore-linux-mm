Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f44.google.com (mail-yh0-f44.google.com [209.85.213.44])
	by kanga.kvack.org (Postfix) with ESMTP id BC2296B0035
	for <linux-mm@kvack.org>; Wed,  5 Mar 2014 23:44:31 -0500 (EST)
Received: by mail-yh0-f44.google.com with SMTP id f73so2151369yha.3
        for <linux-mm@kvack.org>; Wed, 05 Mar 2014 20:44:31 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id v3si8051158yhv.124.2014.03.05.20.44.31
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 05 Mar 2014 20:44:31 -0800 (PST)
Message-ID: <5317FD2A.9020003@oracle.com>
Date: Wed, 05 Mar 2014 23:44:26 -0500
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: mm: kernel BUG at mm/huge_memory.c:2785!
References: <530F3F0A.5040304@oracle.com> <20140227150313.3BA27E0098@blue.fi.intel.com> <53166881.1020504@oracle.com> <20140305135232.EC420E0098@blue.fi.intel.com>
In-Reply-To: <20140305135232.EC420E0098@blue.fi.intel.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On 03/05/2014 08:52 AM, Kirill A. Shutemov wrote:
> Sasha Levin wrote:
>> On 02/27/2014 10:03 AM, Kirill A. Shutemov wrote:
>>> Sasha Levin wrote:
>>>>> Hi all,
>>>>>
>>>>> While fuzzing with trinity inside a KVM tools guest running latest -next kernel I've stumbled on the
>>>>> following spew:
>>>>>
>>>>> [ 1428.146261] kernel BUG at mm/huge_memory.c:2785!
>>> Hm, interesting.
>>>
>>> It seems we either failed to split huge page on vma split or it
>>> materialized from under us. I don't see how it can happen:
>>>
>>>     - it seems we do the right thing with vma_adjust_trans_huge() in
>>>       __split_vma();
>>>     - we hold ->mmap_sem all the way from vm_munmap(). At least I don't see
>>>       a place where we could drop it;
>>>
>>> Andrea, any ideas?
>>
>> And a somewhat related issue (please correct me if I'm wrong):
>
> Yeah. Looks similar. And I still have no idea how it could happened.
>
> Do you trinity logs for the crash?

I can't get it to reproduce with trinity logging enabled, I guess it makes it harder for
the race to occur.

I'll keep it running through the night but don't really have high hopes.


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
