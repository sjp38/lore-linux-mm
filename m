Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 26FD16B0253
	for <linux-mm@kvack.org>; Thu, 13 Aug 2015 17:14:39 -0400 (EDT)
Received: by pdrg1 with SMTP id g1so23615395pdr.2
        for <linux-mm@kvack.org>; Thu, 13 Aug 2015 14:14:38 -0700 (PDT)
Received: from mail-pa0-x231.google.com (mail-pa0-x231.google.com. [2607:f8b0:400e:c03::231])
        by mx.google.com with ESMTPS id oq6si5510149pab.88.2015.08.13.14.14.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Aug 2015 14:14:38 -0700 (PDT)
Received: by paccq16 with SMTP id cq16so1426574pac.1
        for <linux-mm@kvack.org>; Thu, 13 Aug 2015 14:14:38 -0700 (PDT)
Date: Thu, 13 Aug 2015 14:14:35 -0700
From: =?iso-8859-1?Q?J=F6rn?= Engel <joern@purestorage.com>
Subject: Re: [PATCH v4 1/2] mm: hugetlb: proc: add HugetlbPages field to
 /proc/PID/smaps
Message-ID: <20150813211435.GF8588@Sligo.logfs.org>
References: <20150812000336.GB32192@hori1.linux.bs1.fc.nec.co.jp>
 <1439365520-12605-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <alpine.DEB.2.10.1508121325450.5382@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <alpine.DEB.2.10.1508121325450.5382@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andrew Morton <akpm@linux-foundation.org>, Mike Kravetz <mike.kravetz@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Wed, Aug 12, 2015 at 01:25:59PM -0700, David Rientjes wrote:
> On Wed, 12 Aug 2015, Naoya Horiguchi wrote:
> 
> > Currently /proc/PID/smaps provides no usage info for vma(VM_HUGETLB), which
> > is inconvenient when we want to know per-task or per-vma base hugetlb usage.
> > To solve this, this patch adds a new line for hugetlb usage like below:
> > 
> >   Size:              20480 kB
> >   Rss:                   0 kB
> >   Pss:                   0 kB
> >   Shared_Clean:          0 kB
> >   Shared_Dirty:          0 kB
> >   Private_Clean:         0 kB
> >   Private_Dirty:         0 kB
> >   Referenced:            0 kB
> >   Anonymous:             0 kB
> >   AnonHugePages:         0 kB
> >   HugetlbPages:      18432 kB
> >   Swap:                  0 kB
> >   KernelPageSize:     2048 kB
> >   MMUPageSize:        2048 kB
> >   Locked:                0 kB
> >   VmFlags: rd wr mr mw me de ht
> > 
> > Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> 
> Acked-by: David Rientjes <rientjes@google.com>

Acked-by: Joern Engel <joern@logfs.org>

Jorn

--
One of my most productive days was throwing away 1000 lines of code.
-- Ken Thompson.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
