Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0E2686B000A
	for <linux-mm@kvack.org>; Tue,  6 Mar 2018 16:31:41 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id r29so42387wra.13
        for <linux-mm@kvack.org>; Tue, 06 Mar 2018 13:31:41 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id r75si6944992wmb.210.2018.03.06.13.31.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Mar 2018 13:31:39 -0800 (PST)
Date: Tue, 6 Mar 2018 13:31:35 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bug 199037] New: Kernel bug at mm/hugetlb.c:741
Message-Id: <20180306133135.4dc344e478d98f0e29f47698@linux-foundation.org>
In-Reply-To: <bug-199037-27@https.bugzilla.kernel.org/>
References: <bug-199037-27@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>, Mike Kravetz <mike.kravetz@oracle.com>, Michal Hocko <mhocko@kernel.org>
Cc: bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org, blurbdust@gmail.com


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Tue, 06 Mar 2018 21:11:50 +0000 bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=199037
> 
>             Bug ID: 199037
>            Summary: Kernel bug at mm/hugetlb.c:741
>            Product: Memory Management
>            Version: 2.5
>     Kernel Version: 4.16.0-rc3
>           Hardware: All
>                 OS: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Page Allocator
>           Assignee: akpm@linux-foundation.org
>           Reporter: blurbdust@gmail.com
>         Regression: No
> 
> Created attachment 274595
>   --> https://bugzilla.kernel.org/attachment.cgi?id=274595&action=edit
> crash.c
> 
> Hello,
> I apologize as this is my first time reporting a bug. When I compile and run
> the attached file it crashes the latest kernel running in QEMU. Call trace
> here: https://pastebin.com/1mMQvH0E
> 
> Let me know if you have any questions.
> 

Thanks for the report.

That's VM_BUG_ON(resv_map->adds_in_progress) in resv_map_release().

Do you know if earlier kernel versions are affected?

It looks quite bisectable.  Does the crash happen every time the test
program is run?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
