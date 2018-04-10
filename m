Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f197.google.com (mail-yb0-f197.google.com [209.85.213.197])
	by kanga.kvack.org (Postfix) with ESMTP id AFC386B0003
	for <linux-mm@kvack.org>; Mon,  9 Apr 2018 23:03:48 -0400 (EDT)
Received: by mail-yb0-f197.google.com with SMTP id v14-v6so5190494ybq.20
        for <linux-mm@kvack.org>; Mon, 09 Apr 2018 20:03:48 -0700 (PDT)
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id j205si328345ywg.593.2018.04.09.20.03.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Apr 2018 20:03:47 -0700 (PDT)
Subject: Re: [PATCH v3 3/3] mm: restructure memfd code
References: <20180409230505.18953-1-mike.kravetz@oracle.com>
 <20180409230505.18953-4-mike.kravetz@oracle.com>
 <20180410014153.GB31282@bombadil.infradead.org>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <d5bfc82f-9331-fc0d-abbf-acc0a80b2c4c@oracle.com>
Date: Mon, 9 Apr 2018 20:03:25 -0700
MIME-Version: 1.0
In-Reply-To: <20180410014153.GB31282@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@kernel.org>, =?UTF-8?Q?Marc-Andr=c3=a9_Lureau?= <marcandre.lureau@gmail.com>, David Herrmann <dh.herrmann@gmail.com>, Khalid Aziz <khalid.aziz@oracle.com>, Andrew Morton <akpm@linux-foundation.org>

On 04/09/2018 06:41 PM, Matthew Wilcox wrote:
> On Mon, Apr 09, 2018 at 04:05:05PM -0700, Mike Kravetz wrote:
>> +/*
>> + * We need a tag: a new tag would expand every radix_tree_node by 8 bytes,
>> + * so reuse a tag which we firmly believe is never set or cleared on shmem.
>> + */
>> +#define SHMEM_TAG_PINNED        PAGECACHE_TAG_TOWRITE
> 
> Do we also firmly believe it's never used on hugetlbfs?
> 

Yes.  hugetlbfs is memory resident only with no writeback.
This comment and name should have been updated when hugetlbfs support was
added.

Also, ideally all the memfd related function names of the form shmem_* should
have been changed to memfd_* when hugetlbfs support was added.  Some of them
were changed, but not all.

I can clean all this up.  But, I would want to do it in patch 2 of the series.
That is where other cleanup such as this was done before code movement.

Will wait a little while for any additional comments before sending series
again.
-- 
Mike Kravetz
