Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f198.google.com (mail-yw0-f198.google.com [209.85.161.198])
	by kanga.kvack.org (Postfix) with ESMTP id 774836B0003
	for <linux-mm@kvack.org>; Tue, 10 Apr 2018 19:55:26 -0400 (EDT)
Received: by mail-yw0-f198.google.com with SMTP id a20so11890ywe.18
        for <linux-mm@kvack.org>; Tue, 10 Apr 2018 16:55:26 -0700 (PDT)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id j4si727584ywa.654.2018.04.10.16.55.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Apr 2018 16:55:25 -0700 (PDT)
Subject: Re: [PATCH v3 3/3] mm: restructure memfd code
From: Mike Kravetz <mike.kravetz@oracle.com>
References: <20180409230505.18953-1-mike.kravetz@oracle.com>
 <20180409230505.18953-4-mike.kravetz@oracle.com>
 <20180410014153.GB31282@bombadil.infradead.org>
 <d5bfc82f-9331-fc0d-abbf-acc0a80b2c4c@oracle.com>
Message-ID: <834861de-86ce-8cd4-4e6a-2e4cdb27cf70@oracle.com>
Date: Tue, 10 Apr 2018 16:55:01 -0700
MIME-Version: 1.0
In-Reply-To: <d5bfc82f-9331-fc0d-abbf-acc0a80b2c4c@oracle.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@kernel.org>, =?UTF-8?Q?Marc-Andr=c3=a9_Lureau?= <marcandre.lureau@gmail.com>, David Herrmann <dh.herrmann@gmail.com>, Khalid Aziz <khalid.aziz@oracle.com>, Andrew Morton <akpm@linux-foundation.org>

On 04/09/2018 08:03 PM, Mike Kravetz wrote:
> On 04/09/2018 06:41 PM, Matthew Wilcox wrote:
>> On Mon, Apr 09, 2018 at 04:05:05PM -0700, Mike Kravetz wrote:
>>> +/*
>>> + * We need a tag: a new tag would expand every radix_tree_node by 8 bytes,
>>> + * so reuse a tag which we firmly believe is never set or cleared on shmem.
>>> + */
>>> +#define SHMEM_TAG_PINNED        PAGECACHE_TAG_TOWRITE
>>
>> Do we also firmly believe it's never used on hugetlbfs?
>>
> 
> Yes.  hugetlbfs is memory resident only with no writeback.
> This comment and name should have been updated when hugetlbfs support was
> added.
> 
> Also, ideally all the memfd related function names of the form shmem_* should
> have been changed to memfd_* when hugetlbfs support was added.  Some of them
> were changed, but not all.
> 
> I can clean all this up.  But, I would want to do it in patch 2 of the series.
> That is where other cleanup such as this was done before code movement.
> 
> Will wait a little while for any additional comments before sending series
> again.

Cleanups were made in an updated patch 2.  This update is simply based on
the new cleanups made in patch 2.  No functional changes from previous
version.
