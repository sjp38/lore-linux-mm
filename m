Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 41D006B0038
	for <linux-mm@kvack.org>; Wed, 12 Aug 2015 16:30:30 -0400 (EDT)
Received: by pabyb7 with SMTP id yb7so21493343pab.0
        for <linux-mm@kvack.org>; Wed, 12 Aug 2015 13:30:30 -0700 (PDT)
Received: from mail-pa0-x232.google.com (mail-pa0-x232.google.com. [2607:f8b0:400e:c03::232])
        by mx.google.com with ESMTPS id eh4si11165109pac.140.2015.08.12.13.30.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Aug 2015 13:30:29 -0700 (PDT)
Received: by pacrr5 with SMTP id rr5so21518850pac.3
        for <linux-mm@kvack.org>; Wed, 12 Aug 2015 13:30:29 -0700 (PDT)
Date: Wed, 12 Aug 2015 13:30:27 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v4 2/2] mm: hugetlb: proc: add HugetlbPages field to
 /proc/PID/status
In-Reply-To: <1439365520-12605-2-git-send-email-n-horiguchi@ah.jp.nec.com>
Message-ID: <alpine.DEB.2.10.1508121327290.5382@chino.kir.corp.google.com>
References: <20150812000336.GB32192@hori1.linux.bs1.fc.nec.co.jp> <1439365520-12605-1-git-send-email-n-horiguchi@ah.jp.nec.com> <1439365520-12605-2-git-send-email-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, =?UTF-8?Q?J=C3=B6rn_Engel?= <joern@purestorage.com>, Mike Kravetz <mike.kravetz@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Wed, 12 Aug 2015, Naoya Horiguchi wrote:

> Currently there's no easy way to get per-process usage of hugetlb pages, which
> is inconvenient because userspace applications which use hugetlb typically want
> to control their processes on the basis of how much memory (including hugetlb)
> they use. So this patch simply provides easy access to the info via
> /proc/PID/status.
> 
> With this patch, for example, /proc/PID/status shows a line like this:
> 
>   HugetlbPages:      20480 kB (10x2048kB)
> 
> If your system supports and enables multiple hugepage sizes, the line looks
> like this:
> 
>   HugetlbPages:    1069056 kB (1x1048576kB 10x2048kB)
> 
> , so you can easily know how many hugepages in which pagesize are used by a
> process.
> 
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

I'm happy with this and thanks very much for going the extra mile and 
breaking the usage down by hstate size.

I'd be interested in the comments of others, though, to see if there is 
any reservation about the hstate size breakdown.  It may actually find no 
current customer who is interested in parsing it.  (If we keep it, I would 
suggest the 'x' change to '*' similar to per-order breakdowns in 
show_mem()).  It may also be possible to add it later if a definitive 
usecase is presented.

But overall I'm very happy with the new addition and think it's a good 
solution to the problem.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
