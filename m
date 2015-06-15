Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f180.google.com (mail-qc0-f180.google.com [209.85.216.180])
	by kanga.kvack.org (Postfix) with ESMTP id 69DAB6B006E
	for <linux-mm@kvack.org>; Mon, 15 Jun 2015 10:00:00 -0400 (EDT)
Received: by qcsf5 with SMTP id f5so3600731qcs.2
        for <linux-mm@kvack.org>; Mon, 15 Jun 2015 07:00:00 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id m97si8115567qkh.28.2015.06.15.06.59.58
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Jun 2015 06:59:59 -0700 (PDT)
Message-ID: <557EDA53.3040906@redhat.com>
Date: Mon, 15 Jun 2015 09:59:47 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC 3/3] mm: make swapin readahead to improve thp collapse rate
References: <1434294283-8699-1-git-send-email-ebru.akagunduz@gmail.com> <1434294283-8699-4-git-send-email-ebru.akagunduz@gmail.com>
In-Reply-To: <1434294283-8699-4-git-send-email-ebru.akagunduz@gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ebru Akagunduz <ebru.akagunduz@gmail.com>, linux-mm@kvack.org
Cc: akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, iamjoonsoo.kim@lge.com, xiexiuqi@huawei.com, gorcunov@openvz.org, linux-kernel@vger.kernel.org, mgorman@suse.de, rientjes@google.com, vbabka@suse.cz, aneesh.kumar@linux.vnet.ibm.com, hughd@google.com, hannes@cmpxchg.org, mhocko@suse.cz, boaz@plexistor.com, raindel@mellanox.com

On 06/14/2015 11:04 AM, Ebru Akagunduz wrote:
> This patch makes swapin readahead to improve thp collapse rate.
> When khugepaged scanned pages, there can be a few of the pages
> in swap area.
> 
> With the patch THP can collapse 4kB pages into a THP when
> there are up to max_ptes_swap swap ptes in a 2MB range.
> 
> The patch was tested with a test program that allocates
> 800MB of memory, writes to it, and then sleeps. I force
> the system to swap out all. Afterwards, the test program
> touches the area by writing, it skips a page in each
> 20 pages of the area.
> 
> Without the patch, system did not swap in readahead.
> THP rate was %47 of the program of the memory, it
> did not change over time.
> 
> With this patch, after 10 minutes of waiting khugepaged had
> collapsed %99 of the program's memory.
> 
> Signed-off-by: Ebru Akagunduz <ebru.akagunduz@gmail.com>

Mechanism looks good to me.

Acked-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
