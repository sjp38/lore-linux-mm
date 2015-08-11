Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 7AF766B0038
	for <linux-mm@kvack.org>; Tue, 11 Aug 2015 19:48:59 -0400 (EDT)
Received: by pawu10 with SMTP id u10so905874paw.1
        for <linux-mm@kvack.org>; Tue, 11 Aug 2015 16:48:59 -0700 (PDT)
Received: from mail-pd0-x235.google.com (mail-pd0-x235.google.com. [2607:f8b0:400e:c02::235])
        by mx.google.com with ESMTPS id zc8si6294209pac.59.2015.08.11.16.48.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Aug 2015 16:48:58 -0700 (PDT)
Received: by pdrg1 with SMTP id g1so453929pdr.2
        for <linux-mm@kvack.org>; Tue, 11 Aug 2015 16:48:58 -0700 (PDT)
Date: Tue, 11 Aug 2015 16:48:56 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v2 1/2] smaps: fill missing fields for vma(VM_HUGETLB)
In-Reply-To: <20150811233237.GA32192@hori1.linux.bs1.fc.nec.co.jp>
Message-ID: <alpine.DEB.2.10.1508111647110.1853@chino.kir.corp.google.com>
References: <20150806074443.GA7870@hori1.linux.bs1.fc.nec.co.jp> <1438932278-7973-1-git-send-email-n-horiguchi@ah.jp.nec.com> <1438932278-7973-2-git-send-email-n-horiguchi@ah.jp.nec.com> <alpine.DEB.2.10.1508101727230.28691@chino.kir.corp.google.com>
 <20150811233237.GA32192@hori1.linux.bs1.fc.nec.co.jp>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, =?UTF-8?Q?J=C3=B6rn_Engel?= <joern@purestorage.com>, Mike Kravetz <mike.kravetz@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Tue, 11 Aug 2015, Naoya Horiguchi wrote:

> > This memory was not included in rss originally because memory in the 
> > hugetlb persistent pool is always resident.  Unmapping the memory does not 
> > free memory.  For this reason, hugetlb memory has always been treated as 
> > its own type of memory.
> 
> Right, so it might be better not to use the word "RSS" for hugetlb, maybe
> something like "HugetlbPages:" seems better to me.
> 

When the pagesize is also specified, as it is in smaps, I think this would 
be the best option.  Note that we can't distinguish between variable 
hugetlb sizes with VmFlags alone.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
