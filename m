Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id BF2346B0397
	for <linux-mm@kvack.org>; Thu, 30 Mar 2017 16:21:36 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id v4so57282900pgc.20
        for <linux-mm@kvack.org>; Thu, 30 Mar 2017 13:21:36 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id i5si2858749pgk.180.2017.03.30.13.21.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Mar 2017 13:21:36 -0700 (PDT)
Subject: Re: [PATCH RESEND] mm/hugetlb: Don't call region_abort if region_chg
 fails
References: <1490821682-23228-1-git-send-email-mike.kravetz@oracle.com>
 <20170329141711.50c183a7bb1bfa75e24d4426@linux-foundation.org>
 <CACT4Y+bC_AfWkG3US3f1Bkm36S+1+U2dedyJyOGN77K5joK2ZA@mail.gmail.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <66a8e9a2-b116-9d4c-fa74-138838a5b1d9@oracle.com>
Date: Thu, 30 Mar 2017 13:20:12 -0700
MIME-Version: 1.0
In-Reply-To: <CACT4Y+bC_AfWkG3US3f1Bkm36S+1+U2dedyJyOGN77K5joK2ZA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Hillf Danton <hillf.zj@alibaba-inc.com>, Michal Hocko <mhocko@suse.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

On 03/30/2017 05:28 AM, Dmitry Vyukov wrote:
> On Wed, Mar 29, 2017 at 11:17 PM, Andrew Morton
> <akpm@linux-foundation.org> wrote:
>> On Wed, 29 Mar 2017 14:08:02 -0700 Mike Kravetz <mike.kravetz@oracle.com> wrote:
>>
>>>
>>> syzkaller fuzzer found this bug, that resulted in the following:
>>
>> I'll change the above to
>>
>> : syzkaller fuzzer (when using an injected kmalloc failure) found this bug,
>> : that resulted in the following:
>>
>> it's important, because this bug won't be triggered (at all easily, at
>> least) in real-world workloads.
> 
> I wonder if memory-constrained cgroups make such bugs much easier to trigger.
> 

I think you might expose some bugs with memory-constrained cgroups.  However,
it is unlikely you could trigger this bug using that method.

In this bug the injected kmalloc failure was for a 32 byte allocation.  My
guess is that it would be very very unlikely/lucky to have the allocations
done by other routines on the stack succeed, and have this 32 byte allocation
fail.   

-- 
Mike Kravetz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
