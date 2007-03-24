Received: from spaceape11.eur.corp.google.com (spaceape11.eur.corp.google.com [172.28.16.145])
	by smtp-out.google.com with ESMTP id l2O7Ba8R031348
	for <linux-mm@kvack.org>; Sat, 24 Mar 2007 07:11:36 GMT
Received: from an-out-0708.google.com (andd14.prod.google.com [10.100.30.14])
	by spaceape11.eur.corp.google.com with ESMTP id l2O7BXgG029419
	for <linux-mm@kvack.org>; Sat, 24 Mar 2007 07:11:33 GMT
Received: by an-out-0708.google.com with SMTP id d14so1680368and
        for <linux-mm@kvack.org>; Sat, 24 Mar 2007 00:11:32 -0700 (PDT)
Message-ID: <b040c32a0703240011ib9a66f3l1701b8adda94401d@mail.gmail.com>
Date: Sat, 24 Mar 2007 00:11:32 -0700
From: "Ken Chen" <kenchen@google.com>
Subject: Re: [patch] rfc: introduce /dev/hugetlb
In-Reply-To: <20070323221225.bdadae16.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <b040c32a0703230144r635d7902g2c36ecd7f412be31@mail.gmail.com>
	 <20070323205810.3860886d.akpm@linux-foundation.org>
	 <29495f1d0703232232o3e436c62lddccc82c4dd17b51@mail.gmail.com>
	 <20070323221225.bdadae16.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Nish Aravamudan <nish.aravamudan@gmail.com>, Adam Litke <agl@us.ibm.com>, Arjan van de Ven <arjan@infradead.org>, William Lee Irwin III <wli@holomorphy.com>, Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On 3/23/07, Andrew Morton <akpm@linux-foundation.org> wrote:
> a) Ken observes that obtaining private hugetlb memory via hugetlbfs
>    involves "fuss".
>
> b) the libhugetlbfs maintainers then go off and implement a no-fuss way of
>    doing this.

Hmm, what started this thread was libhugetlbfs maintainer complained
how "fuss" it was to create private hugetlb mapping and suggested an
even bigger kernel change with pagetable_operations API.  The new API
was designed with an end goal of introduce /dev/hugetlb (as one of the
feature, they might be thinking more).  What motivated me here is to
point out that we can achieve the same goal of having a /dev/hugetlb
with existing hugetlbfs infrastructure and the implementation is
relatively straightforward.  What it also buys us is a bit more
flexibility to the end user who wants to use the interface directly.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
