Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id C85356B039F
	for <linux-mm@kvack.org>; Mon,  3 Apr 2017 05:38:44 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id 68so135242233pgj.23
        for <linux-mm@kvack.org>; Mon, 03 Apr 2017 02:38:44 -0700 (PDT)
Received: from mailout2.w1.samsung.com (mailout2.w1.samsung.com. [210.118.77.12])
        by mx.google.com with ESMTPS id u59si13781731plb.138.2017.04.03.02.38.43
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 03 Apr 2017 02:38:43 -0700 (PDT)
Received: from eucas1p1.samsung.com (unknown [182.198.249.206])
 by mailout2.w1.samsung.com
 (Oracle Communications Messaging Server 7.0.5.31.0 64bit (built May  5 2014))
 with ESMTP id <0ONT009IJUSGWD60@mailout2.w1.samsung.com> for
 linux-mm@kvack.org; Mon, 03 Apr 2017 10:38:40 +0100 (BST)
Subject: Re: [PATCH v3] please don't see patch set
From: Alexey Perevalov <a.perevalov@samsung.com>
Message-id: <63dd9e34-3ae9-e320-60a5-a5619dee402b@samsung.com>
Date: Mon, 03 Apr 2017 12:38:35 +0300
MIME-version: 1.0
In-reply-to: <1491211956-6095-1-git-send-email-a.perevalov@samsung.com>
Content-type: text/plain; charset=windows-1252; format=flowed
Content-transfer-encoding: 7bit
References: 
 <CGME20170403093307eucas1p2e1110dd2550426c53a7b8825efa34f99@eucas1p2.samsung.com>
 <1491211956-6095-1-git-send-email-a.perevalov@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org
Cc: rppt@linux.vnet.ibm.com, mike.kravetz@oracle.com, dgilbert@redhat.com

I'm so sorry, commit message in patch is wrong.

I'll resend

On 04/03/2017 12:32 PM, Alexey Perevalov wrote:
> Hi Andrea,
>
> This is third version of the patch. Modifications since previous versions:
> 	(v3 -> v2)
>   - type of ptid now is __u32. As you suggested.
>
> 	(v2 -> v1)
>   - process thread id is provided only when it was requested with
> UFFD_FEATURE_THREAD_ID bit.
>   - pid from namespace is provided, so locking thread's gettid in namespace
> and msg.arg.pagefault.ptid will be equal.
>
> This patch is based on
> git://git.kernel.org/pub/scm/linux/kernel/git/andrea/aa.git userfault branch.
> HEAD commit is "userfaultfd: switch to exclusive wakeup for blocking reads"
>
>
> Alexey Perevalov (1):
>    userfaultfd: provide pid in userfault msg
>
>   fs/userfaultfd.c                 | 8 ++++++--
>   include/uapi/linux/userfaultfd.h | 8 +++++++-
>   2 files changed, 13 insertions(+), 3 deletions(-)
>


-- 
Best regards,
Alexey Perevalov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
