Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f170.google.com (mail-qc0-f170.google.com [209.85.216.170])
	by kanga.kvack.org (Postfix) with ESMTP id F1F416B0035
	for <linux-mm@kvack.org>; Mon, 12 May 2014 12:05:28 -0400 (EDT)
Received: by mail-qc0-f170.google.com with SMTP id i8so8228299qcq.1
        for <linux-mm@kvack.org>; Mon, 12 May 2014 09:05:28 -0700 (PDT)
Received: from qmta06.emeryville.ca.mail.comcast.net (qmta06.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:56])
        by mx.google.com with ESMTP id j6si6174199qan.147.2014.05.12.09.05.27
        for <linux-mm@kvack.org>;
        Mon, 12 May 2014 09:05:27 -0700 (PDT)
Date: Mon, 12 May 2014 11:05:24 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 1/3] mm: add comment for __mod_zone_page_stat
In-Reply-To: <CAHz2CGUfLx7DNgdNoAL0G3a9Ht6yf3bhWaojjNx91aF7L-iDQw@mail.gmail.com>
Message-ID: <alpine.DEB.2.10.1405121102170.17673@gentwo.org>
References: <1399811500-14472-1-git-send-email-nasa4836@gmail.com> <alpine.DEB.2.10.1405120858040.3090@gentwo.org> <CAHz2CGUfLx7DNgdNoAL0G3a9Ht6yf3bhWaojjNx91aF7L-iDQw@mail.gmail.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jianyu Zhan <nasa4836@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, fabf@skynet.be, sasha.levin@oracle.com, oleg@redhat.com, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, iamjoonsoo.kim@lge.com, kirill.shutemov@linux.intel.com, Cyrill Gorcunov <gorcunov@gmail.com>, dave.hansen@linux.intel.com, toshi.kani@hp.com, paul.gortmaker@windriver.com, srivatsa.bhat@linux.vnet.ibm.com, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, 12 May 2014, Jianyu Zhan wrote:

> This means they guarantee that even they are preemted the vm
> counter won't be modified incorrectly.  Because the counter is page-related
> (e.g., a new anon page added), and they are exclusively hold the pte lock.

But there are multiple pte locks for numerous page. Another process could
modify the counter because the pte lock for a different page was
available which would cause counter corruption.


> So, as you concludes in the other mail that __modd_zone_page_stat
> couldn't be used.
> in mlocked_vma_newpage, then what qualifies other call sites for using
> it, in the same situation?

Preemption should be off in those functions because a spinlock is being
held.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
