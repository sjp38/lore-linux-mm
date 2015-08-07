Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 673296B0253
	for <linux-mm@kvack.org>; Fri,  7 Aug 2015 18:51:01 -0400 (EDT)
Received: by pabyb7 with SMTP id yb7so64584853pab.0
        for <linux-mm@kvack.org>; Fri, 07 Aug 2015 15:51:01 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id pf2si2734460pdb.253.2015.08.07.15.51.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Aug 2015 15:51:00 -0700 (PDT)
Date: Fri, 7 Aug 2015 15:50:59 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2 1/2] smaps: fill missing fields for vma(VM_HUGETLB)
Message-Id: <20150807155059.dbfdbdeacd4e9c9397901b7e@linux-foundation.org>
In-Reply-To: <1438932278-7973-2-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <20150806074443.GA7870@hori1.linux.bs1.fc.nec.co.jp>
	<1438932278-7973-1-git-send-email-n-horiguchi@ah.jp.nec.com>
	<1438932278-7973-2-git-send-email-n-horiguchi@ah.jp.nec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: David Rientjes <rientjes@google.com>, =?ISO-8859-1?Q?J=F6rn?= Engel <joern@purestorage.com>, Mike Kravetz <mike.kravetz@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Fri, 7 Aug 2015 07:24:50 +0000 Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> wrote:

> Currently smaps reports many zero fields for vma(VM_HUGETLB), which is
> inconvenient when we want to know per-task or per-vma base hugetlb usage.
> This patch enables these fields by introducing smaps_hugetlb_range().
> 
> before patch:
> 
>   Size:              20480 kB
>   Rss:                   0 kB
>   Pss:                   0 kB
>   Shared_Clean:          0 kB
>   Shared_Dirty:          0 kB
>   Private_Clean:         0 kB
>   Private_Dirty:         0 kB
>   Referenced:            0 kB
>   Anonymous:             0 kB
>   AnonHugePages:         0 kB
>   Swap:                  0 kB
>   KernelPageSize:     2048 kB
>   MMUPageSize:        2048 kB
>   Locked:                0 kB
>   VmFlags: rd wr mr mw me de ht
> 
> after patch:
> 
>   Size:              20480 kB
>   Rss:               18432 kB
>   Pss:               18432 kB
>   Shared_Clean:          0 kB
>   Shared_Dirty:          0 kB
>   Private_Clean:         0 kB
>   Private_Dirty:     18432 kB
>   Referenced:        18432 kB
>   Anonymous:         18432 kB
>   AnonHugePages:         0 kB
>   Swap:                  0 kB
>   KernelPageSize:     2048 kB
>   MMUPageSize:        2048 kB
>   Locked:                0 kB
>   VmFlags: rd wr mr mw me de ht
> 

Is there something we can say about this in
Documentation/filesystems/proc.txt?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
