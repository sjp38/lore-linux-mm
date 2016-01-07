Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f172.google.com (mail-pf0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id D3B3E828DE
	for <linux-mm@kvack.org>; Thu,  7 Jan 2016 18:13:58 -0500 (EST)
Received: by mail-pf0-f172.google.com with SMTP id q63so354144pfb.1
        for <linux-mm@kvack.org>; Thu, 07 Jan 2016 15:13:58 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id gl10si80454564pac.164.2016.01.07.15.13.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Jan 2016 15:13:57 -0800 (PST)
Date: Thu, 7 Jan 2016 15:13:56 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm/hugetlbfs Fix bugs in hugetlb_vmtruncate_list
Message-Id: <20160107151356.0e131b25f5740f6046221419@linux-foundation.org>
In-Reply-To: <1452206137-12441-1-git-send-email-mike.kravetz@oracle.com>
References: <1452206137-12441-1-git-send-email-mike.kravetz@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hillf Danton <hillf.zj@alibaba-inc.com>, Hugh Dickins <hughd@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Davidlohr Bueso <dave@stgolabs.net>, Dave Hansen <dave.hansen@linux.intel.com>, stable@vger.kernel.org

On Thu,  7 Jan 2016 14:35:37 -0800 Mike Kravetz <mike.kravetz@oracle.com> wrote:

> Hillf Danton noticed bugs in the hugetlb_vmtruncate_list routine.
> The argument end is of type pgoff_t.  It was being converted to a
> vaddr offset and passed to unmap_hugepage_range.  However, end
> was also being used as an argument to the vma_interval_tree_foreach
> controlling loop.  In addition, the conversion of end to vaddr offset
> was incorrect.

Could we please have a description of the user-visible effects of the
bug?  It's always needed for -stable things.  And for all bugfixes, really.

(stable@vger.kernel.org[4.3] isn't an email address btw - my client barfed)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
