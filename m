Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f43.google.com (mail-oi0-f43.google.com [209.85.218.43])
	by kanga.kvack.org (Postfix) with ESMTP id 96D8382A11
	for <linux-mm@kvack.org>; Fri, 22 May 2015 22:32:47 -0400 (EDT)
Received: by oihb142 with SMTP id b142so26173024oih.3
        for <linux-mm@kvack.org>; Fri, 22 May 2015 19:32:47 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id b72si2424434oih.14.2015.05.22.19.32.46
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 May 2015 19:32:46 -0700 (PDT)
Message-ID: <555FE6A8.3060707@oracle.com>
Date: Fri, 22 May 2015 19:32:08 -0700
From: Mike Kravetz <mike.kravetz@oracle.com>
MIME-Version: 1.0
Subject: Re: [RFC v3 PATCH 00/10] hugetlbfs: add fallocate support
References: <1432223264-4414-1-git-send-email-mike.kravetz@oracle.com> <1432331412.2185.10.camel@stgolabs.net>
In-Reply-To: <1432331412.2185.10.camel@stgolabs.net>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <dave@stgolabs.net>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Christoph Hellwig <hch@infradead.org>

On 05/22/2015 02:50 PM, Davidlohr Bueso wrote:
> On Thu, 2015-05-21 at 08:47 -0700, Mike Kravetz wrote:
>> This patch set adds fallocate functionality to hugetlbfs.
>
> It would be good to also have proper testcases in, say, libhugetlbfs.

Makes sense.  I have some functionality and stress tests I have been
using during development.  I'll start work on adding them to the
libhugetlbfs test harness.

-- 
Mike Kravetz

> Thanks,
> Davidlohr
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
