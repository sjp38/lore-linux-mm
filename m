Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0B40C6B000A
	for <linux-mm@kvack.org>; Tue,  6 Mar 2018 16:46:20 -0500 (EST)
Received: by mail-it0-f71.google.com with SMTP id t74so479389itb.8
        for <linux-mm@kvack.org>; Tue, 06 Mar 2018 13:46:20 -0800 (PST)
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id w21si8177540ite.21.2018.03.06.13.46.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Mar 2018 13:46:19 -0800 (PST)
Subject: Re: [Bug 199037] New: Kernel bug at mm/hugetlb.c:741
References: <bug-199037-27@https.bugzilla.kernel.org/>
 <20180306133135.4dc344e478d98f0e29f47698@linux-foundation.org>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <7ffa77c8-8624-9c69-d1f5-058ef22c460c@oracle.com>
Date: Tue, 6 Mar 2018 13:46:11 -0800
MIME-Version: 1.0
In-Reply-To: <20180306133135.4dc344e478d98f0e29f47698@linux-foundation.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Michal Hocko <mhocko@kernel.org>
Cc: bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org, blurbdust@gmail.com

On 03/06/2018 01:31 PM, Andrew Morton wrote:
> 
> (switched to email.  Please respond via emailed reply-to-all, not via the
> bugzilla web interface).
> 
> On Tue, 06 Mar 2018 21:11:50 +0000 bugzilla-daemon@bugzilla.kernel.org wrote:
> 
>> https://bugzilla.kernel.org/show_bug.cgi?id=199037
>>
>>             Bug ID: 199037
>>            Summary: Kernel bug at mm/hugetlb.c:741
>>            Product: Memory Management
>>            Version: 2.5
>>     Kernel Version: 4.16.0-rc3
>>           Hardware: All
>>                 OS: Linux
>>               Tree: Mainline
>>             Status: NEW
>>           Severity: normal
>>           Priority: P1
>>          Component: Page Allocator
>>           Assignee: akpm@linux-foundation.org
>>           Reporter: blurbdust@gmail.com
>>         Regression: No
>>
>> Created attachment 274595
>>   --> https://bugzilla.kernel.org/attachment.cgi?id=274595&action=edit
>> crash.c
>>
>> Hello,
>> I apologize as this is my first time reporting a bug. When I compile and run
>> the attached file it crashes the latest kernel running in QEMU. Call trace
>> here: https://pastebin.com/1mMQvH0E
>>
>> Let me know if you have any questions.
>>
> 
> Thanks for the report.
> 
> That's VM_BUG_ON(resv_map->adds_in_progress) in resv_map_release().
> 
> Do you know if earlier kernel versions are affected?
> 
> It looks quite bisectable.  Does the crash happen every time the test
> program is run?

I'll take a look.  There was a previous bug in this area:
ff8c0c53: mm/hugetlb.c: don't call region_abort if region_chg fails

-- 
Mike Kravetz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
