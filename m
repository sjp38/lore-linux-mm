Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 691B86B0253
	for <linux-mm@kvack.org>; Thu, 13 Aug 2015 17:14:21 -0400 (EDT)
Received: by pacgr6 with SMTP id gr6so44904995pac.2
        for <linux-mm@kvack.org>; Thu, 13 Aug 2015 14:14:21 -0700 (PDT)
Received: from mail-pa0-x22b.google.com (mail-pa0-x22b.google.com. [2607:f8b0:400e:c03::22b])
        by mx.google.com with ESMTPS id pr10si5490962pbb.122.2015.08.13.14.14.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Aug 2015 14:14:20 -0700 (PDT)
Received: by pacgr6 with SMTP id gr6so44904844pac.2
        for <linux-mm@kvack.org>; Thu, 13 Aug 2015 14:14:20 -0700 (PDT)
Date: Thu, 13 Aug 2015 14:14:18 -0700
From: =?iso-8859-1?Q?J=F6rn?= Engel <joern@purestorage.com>
Subject: Re: [PATCH v4 2/2] mm: hugetlb: proc: add HugetlbPages field to
 /proc/PID/status
Message-ID: <20150813211418.GE8588@Sligo.logfs.org>
References: <20150812000336.GB32192@hori1.linux.bs1.fc.nec.co.jp>
 <1439365520-12605-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1439365520-12605-2-git-send-email-n-horiguchi@ah.jp.nec.com>
 <alpine.DEB.2.10.1508121327290.5382@chino.kir.corp.google.com>
 <20150813004533.GA24716@hori1.linux.bs1.fc.nec.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20150813004533.GA24716@hori1.linux.bs1.fc.nec.co.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Mike Kravetz <mike.kravetz@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Thu, Aug 13, 2015 at 12:45:33AM +0000, Naoya Horiguchi wrote:
> From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Subject: [PATCH] mm: hugetlb: proc: add HugetlbPages field to /proc/PID/status
> 
> Currently there's no easy way to get per-process usage of hugetlb pages, which
> is inconvenient because userspace applications which use hugetlb typically want
> to control their processes on the basis of how much memory (including hugetlb)
> they use. So this patch simply provides easy access to the info via
> /proc/PID/status.
> 
> With this patch, for example, /proc/PID/status shows a line like this:
> 
>   HugetlbPages:      20480 kB (10*2048kB)
> 
> If your system supports and enables multiple hugepage sizes, the line looks
> like this:
> 
>   HugetlbPages:    1069056 kB (1*1048576kB 10*2048kB)
> 
> , so you can easily know how many hugepages in which pagesize are used by a
> process.
> 
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

Acked-by: Joern Engel <joern@logfs.org>

Jorn

--
Computer system analysis is like child-rearing; you can do grievous damage,
but you cannot ensure success."
-- Tom DeMarco

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
