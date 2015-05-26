Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f51.google.com (mail-oi0-f51.google.com [209.85.218.51])
	by kanga.kvack.org (Postfix) with ESMTP id 765EF6B0126
	for <linux-mm@kvack.org>; Tue, 26 May 2015 19:00:14 -0400 (EDT)
Received: by oihb142 with SMTP id b142so89659619oih.3
        for <linux-mm@kvack.org>; Tue, 26 May 2015 16:00:14 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id xa3si813654oeb.12.2015.05.26.16.00.13
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 May 2015 16:00:13 -0700 (PDT)
Message-ID: <5564FACE.9070204@oracle.com>
Date: Tue, 26 May 2015 15:59:26 -0700
From: Mike Kravetz <mike.kravetz@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 1/2] mm/hugetlb: compute/return the number of regions
 added by region_add()
References: <1432353304-12767-1-git-send-email-mike.kravetz@oracle.com>	 <1432353304-12767-2-git-send-email-mike.kravetz@oracle.com> <1432585785.2185.59.camel@stgolabs.net>
In-Reply-To: <1432585785.2185.59.camel@stgolabs.net>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <dave@stgolabs.net>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Rientjes <rientjes@google.com>, Luiz Capitulino <lcapitulino@redhat.com>, Andrew Morton <akpm@linux-foundation.org>

On 05/25/2015 01:29 PM, Davidlohr Bueso wrote:
> On Fri, 2015-05-22 at 20:55 -0700, Mike Kravetz wrote:
>> +/*
>> + * Add the huge page range represented by indicies f (from)
>> + * and t (to) to the reserve map.  Existing regions will be
>
> How about simply renaming those parameters to from and to across the
> entire hugetlb code.
>
> Thanks,
> Davidlohr

After adding the notation suggested by Naoya Horiguchi and cleaning
up that specific comment, I think using f and t is OK.  See the
documentation only patch:

[PATCH] mm/hugetlb: document the reserve map/region tracking routines

-- 
Mike Kravetz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
