Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id D11006B0260
	for <linux-mm@kvack.org>; Tue, 19 Apr 2016 12:11:57 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id zy2so26842618pac.1
        for <linux-mm@kvack.org>; Tue, 19 Apr 2016 09:11:57 -0700 (PDT)
Received: from mail-pa0-x235.google.com (mail-pa0-x235.google.com. [2607:f8b0:400e:c03::235])
        by mx.google.com with ESMTPS id h186si17482909pfb.59.2016.04.19.09.11.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Apr 2016 09:11:56 -0700 (PDT)
Received: by mail-pa0-x235.google.com with SMTP id er2so8009609pad.3
        for <linux-mm@kvack.org>; Tue, 19 Apr 2016 09:11:56 -0700 (PDT)
Subject: Re: [PATCHv7 00/29] THP-enabled tmpfs/shmem using compound pages
References: <1460766240-84565-1-git-send-email-kirill.shutemov@linux.intel.com>
 <571565F0.9070203@linaro.org> <571641AC.1050801@redhat.com>
From: "Shi, Yang" <yang.shi@linaro.org>
Message-ID: <571658CB.9080205@linaro.org>
Date: Tue, 19 Apr 2016 09:11:55 -0700
MIME-Version: 1.0
In-Reply-To: <571641AC.1050801@redhat.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Marchand <jmarchan@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Sasha Levin <sasha.levin@oracle.com>, Andres Lagar-Cavilla <andreslc@google.com>, Ning Qu <quning@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

On 4/19/2016 7:33 AM, Jerome Marchand wrote:
> On 04/19/2016 12:55 AM, Shi, Yang wrote:
>> 2. I ran my THP test (generated a program with 4MB text section) on both
>> x86-64 and ARM64 with yours and Hugh's patches (linux-next tree), I got
>> the program execution time reduced by ~12% on x86-64, it looks very
>> impressive.
>>
>> But, on ARM64, there is just ~3% change, and sometimes huge tmpfs may
>> show even worse data than non-hugepage.
>>
>> Both yours and Hugh's patches has the same behavior.
>>
>> Any idea?
>
> Just a shot in the dark, but what page size do you use? If you use 4k
> pages, then hugepage size should be the same as on x86 and a similar

I do use 4K pages for both x86-64 and ARM64 in my testing.

Thanks,
Yang

> behavior could be expected. Otherwise, hugepages would be too big to be
> taken advantage of by your test program.
>
> Jerome
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
