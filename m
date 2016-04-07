Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f182.google.com (mail-lb0-f182.google.com [209.85.217.182])
	by kanga.kvack.org (Postfix) with ESMTP id A999B6B0005
	for <linux-mm@kvack.org>; Thu,  7 Apr 2016 14:58:58 -0400 (EDT)
Received: by mail-lb0-f182.google.com with SMTP id bk9so28629136lbc.3
        for <linux-mm@kvack.org>; Thu, 07 Apr 2016 11:58:58 -0700 (PDT)
Received: from mail-lf0-x22b.google.com (mail-lf0-x22b.google.com. [2a00:1450:4010:c07::22b])
        by mx.google.com with ESMTPS id b186si4038719lfb.211.2016.04.07.11.58.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Apr 2016 11:58:57 -0700 (PDT)
Received: by mail-lf0-x22b.google.com with SMTP id e190so62006538lfe.0
        for <linux-mm@kvack.org>; Thu, 07 Apr 2016 11:58:57 -0700 (PDT)
Date: Thu, 7 Apr 2016 21:58:54 +0300
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCH v5 2/2] mm, thp: avoid unnecessary swapin in khugepaged
Message-ID: <20160407185854.GO2258@uranus.lan>
References: <1460049861-10646-1-git-send-email-ebru.akagunduz@gmail.com>
 <1460050081-10765-1-git-send-email-ebru.akagunduz@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1460050081-10765-1-git-send-email-ebru.akagunduz@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ebru Akagunduz <ebru.akagunduz@gmail.com>
Cc: linux-mm@kvack.org, hughd@google.com, riel@redhat.com, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, iamjoonsoo.kim@lge.com, linux-kernel@vger.kernel.org, mgorman@suse.de, rientjes@google.com, vbabka@suse.cz, aneesh.kumar@linux.vnet.ibm.com, hannes@cmpxchg.org, mhocko@suse.cz, boaz@plexistor.com

On Thu, Apr 07, 2016 at 08:28:01PM +0300, Ebru Akagunduz wrote:
...
> +	swap = get_mm_counter(mm, MM_SWAPENTS);
> +	curr_allocstall = sum_vm_event(ALLOCSTALL);
> +	/*
> +	 * When system under pressure, don't swapin readahead.
> +	 * So that avoid unnecessary resource consuming.
> +	 */
> +	if (allocstall == curr_allocstall && swap !=)
> +		__collapse_huge_page_swapin(mm, vma, address, pmd);

This !=) looks like someone got fun ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
