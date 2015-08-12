Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 896816B0038
	for <linux-mm@kvack.org>; Wed, 12 Aug 2015 16:26:02 -0400 (EDT)
Received: by pacgr6 with SMTP id gr6so21437821pac.2
        for <linux-mm@kvack.org>; Wed, 12 Aug 2015 13:26:02 -0700 (PDT)
Received: from mail-pd0-x22d.google.com (mail-pd0-x22d.google.com. [2607:f8b0:400e:c02::22d])
        by mx.google.com with ESMTPS id kz7si11120500pbc.144.2015.08.12.13.26.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Aug 2015 13:26:01 -0700 (PDT)
Received: by pdrh1 with SMTP id h1so10941686pdr.0
        for <linux-mm@kvack.org>; Wed, 12 Aug 2015 13:26:01 -0700 (PDT)
Date: Wed, 12 Aug 2015 13:25:59 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v4 1/2] mm: hugetlb: proc: add HugetlbPages field to
 /proc/PID/smaps
In-Reply-To: <1439365520-12605-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Message-ID: <alpine.DEB.2.10.1508121325450.5382@chino.kir.corp.google.com>
References: <20150812000336.GB32192@hori1.linux.bs1.fc.nec.co.jp> <1439365520-12605-1-git-send-email-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, =?UTF-8?Q?J=C3=B6rn_Engel?= <joern@purestorage.com>, Mike Kravetz <mike.kravetz@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Wed, 12 Aug 2015, Naoya Horiguchi wrote:

> Currently /proc/PID/smaps provides no usage info for vma(VM_HUGETLB), which
> is inconvenient when we want to know per-task or per-vma base hugetlb usage.
> To solve this, this patch adds a new line for hugetlb usage like below:
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
>   HugetlbPages:      18432 kB
>   Swap:                  0 kB
>   KernelPageSize:     2048 kB
>   MMUPageSize:        2048 kB
>   Locked:                0 kB
>   VmFlags: rd wr mr mw me de ht
> 
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
