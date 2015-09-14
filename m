Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f49.google.com (mail-qg0-f49.google.com [209.85.192.49])
	by kanga.kvack.org (Postfix) with ESMTP id 8C4046B0255
	for <linux-mm@kvack.org>; Mon, 14 Sep 2015 15:47:32 -0400 (EDT)
Received: by qgx61 with SMTP id 61so124775099qgx.3
        for <linux-mm@kvack.org>; Mon, 14 Sep 2015 12:47:32 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 79si13548965qhs.124.2015.09.14.12.47.31
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Sep 2015 12:47:31 -0700 (PDT)
Message-ID: <55F7244D.9010605@redhat.com>
Date: Mon, 14 Sep 2015 15:47:25 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC v5 2/3] mm: make optimistic check for swapin readahead
References: <1442259105-4420-1-git-send-email-ebru.akagunduz@gmail.com> <1442259105-4420-3-git-send-email-ebru.akagunduz@gmail.com>
In-Reply-To: <1442259105-4420-3-git-send-email-ebru.akagunduz@gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ebru Akagunduz <ebru.akagunduz@gmail.com>, linux-mm@kvack.org
Cc: akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, iamjoonsoo.kim@lge.com, xiexiuqi@huawei.com, gorcunov@openvz.org, linux-kernel@vger.kernel.org, mgorman@suse.de, rientjes@google.com, vbabka@suse.cz, aneesh.kumar@linux.vnet.ibm.com, hughd@google.com, hannes@cmpxchg.org, mhocko@suse.cz, boaz@plexistor.com, raindel@mellanox.com

On 09/14/2015 03:31 PM, Ebru Akagunduz wrote:
> This patch introduces new sysfs integer knob
> /sys/kernel/mm/transparent_hugepage/khugepaged/max_ptes_swap
> which makes optimistic check for swapin readahead to
> increase thp collapse rate. Before getting swapped
> out pages to memory, checks them and allows up to a
> certain number. It also prints out using tracepoints
> amount of unmapped ptes.

This may need some more refinement in the future, but your
patch series seems to create a large improvement over what
we have now.

> Signed-off-by: Ebru Akagunduz <ebru.akagunduz@gmail.com>

Acked-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
