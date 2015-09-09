Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 5CAFC6B0038
	for <linux-mm@kvack.org>; Wed,  9 Sep 2015 18:14:07 -0400 (EDT)
Received: by pacex6 with SMTP id ex6so22208965pac.0
        for <linux-mm@kvack.org>; Wed, 09 Sep 2015 15:14:07 -0700 (PDT)
Received: from mail-pa0-x231.google.com (mail-pa0-x231.google.com. [2607:f8b0:400e:c03::231])
        by mx.google.com with ESMTPS id pw1si369393pbb.1.2015.09.09.15.14.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Sep 2015 15:14:06 -0700 (PDT)
Received: by padhk3 with SMTP id hk3so22007851pad.3
        for <linux-mm@kvack.org>; Wed, 09 Sep 2015 15:14:06 -0700 (PDT)
Date: Wed, 9 Sep 2015 15:14:05 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v5 1/2] mm: hugetlb: proc: add HugetlbPages field to
 /proc/PID/smaps
In-Reply-To: <55F04C48.7070105@suse.cz>
Message-ID: <alpine.DEB.2.10.1509091512080.21685@chino.kir.corp.google.com>
References: <20150812000336.GB32192@hori1.linux.bs1.fc.nec.co.jp> <1440059182-19798-1-git-send-email-n-horiguchi@ah.jp.nec.com> <1440059182-19798-2-git-send-email-n-horiguchi@ah.jp.nec.com> <55F04C48.7070105@suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andrew Morton <akpm@linux-foundation.org>, =?UTF-8?Q?J=C3=B6rn_Engel?= <joern@purestorage.com>, Mike Kravetz <mike.kravetz@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Wed, 9 Sep 2015, Vlastimil Babka wrote:

> On 08/20/2015 10:26 AM, Naoya Horiguchi wrote:
> > Currently /proc/PID/smaps provides no usage info for vma(VM_HUGETLB), which
> > is inconvenient when we want to know per-task or per-vma base hugetlb usage.
> > To solve this, this patch adds a new line for hugetlb usage like below:
> > 
> >    Size:              20480 kB
> >    Rss:                   0 kB
> >    Pss:                   0 kB
> >    Shared_Clean:          0 kB
> >    Shared_Dirty:          0 kB
> >    Private_Clean:         0 kB
> >    Private_Dirty:         0 kB
> >    Referenced:            0 kB
> >    Anonymous:             0 kB
> >    AnonHugePages:         0 kB
> >    HugetlbPages:      18432 kB
> >    Swap:                  0 kB
> >    KernelPageSize:     2048 kB
> >    MMUPageSize:        2048 kB
> >    Locked:                0 kB
> >    VmFlags: rd wr mr mw me de ht
> > 
> > Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> > Acked-by: Joern Engel <joern@logfs.org>
> > Acked-by: David Rientjes <rientjes@google.com>
> 
> Sorry for coming late to this thread. It's a nice improvement, but I find it
> somewhat illogical that the per-process stats (status) are more detailed than
> the per-mapping stats (smaps) with respect to the size breakdown. I would
> expect it to be the other way around. That would simplify the per-process
> accounting (I realize this has been a hot topic already), and allow those who
> really care to look at smaps.
> 

Smaps shows the pagesize for the hugepage of the vma and the rss, I 
believe you have all the information needed.  Some distributions also 
change smaps to only be readable by the owner or root for security 
reasons.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
