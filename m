Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f173.google.com (mail-ob0-f173.google.com [209.85.214.173])
	by kanga.kvack.org (Postfix) with ESMTP id EC5AD828DE
	for <linux-mm@kvack.org>; Thu,  7 Jan 2016 18:52:38 -0500 (EST)
Received: by mail-ob0-f173.google.com with SMTP id xn1so66885853obc.2
        for <linux-mm@kvack.org>; Thu, 07 Jan 2016 15:52:38 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id dh8si14691162obb.81.2016.01.07.15.52.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Jan 2016 15:52:38 -0800 (PST)
Subject: Re: [PATCH] mm/hugetlbfs Fix bugs in hugetlb_vmtruncate_list
References: <1452206137-12441-1-git-send-email-mike.kravetz@oracle.com>
 <20160107151356.0e131b25f5740f6046221419@linux-foundation.org>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <568EF9F9.8050404@oracle.com>
Date: Thu, 7 Jan 2016 15:51:21 -0800
MIME-Version: 1.0
In-Reply-To: <20160107151356.0e131b25f5740f6046221419@linux-foundation.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hillf Danton <hillf.zj@alibaba-inc.com>, Hugh Dickins <hughd@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Davidlohr Bueso <dave@stgolabs.net>, Dave Hansen <dave.hansen@linux.intel.com>, stable@vger.kernel.org

On 01/07/2016 03:13 PM, Andrew Morton wrote:
> On Thu,  7 Jan 2016 14:35:37 -0800 Mike Kravetz <mike.kravetz@oracle.com> wrote:
> 
>> Hillf Danton noticed bugs in the hugetlb_vmtruncate_list routine.
>> The argument end is of type pgoff_t.  It was being converted to a
>> vaddr offset and passed to unmap_hugepage_range.  However, end
>> was also being used as an argument to the vma_interval_tree_foreach
>> controlling loop.  In addition, the conversion of end to vaddr offset
>> was incorrect.
> 
> Could we please have a description of the user-visible effects of the
> bug?  It's always needed for -stable things.  And for all bugfixes, really.
> 
> (stable@vger.kernel.org[4.3] isn't an email address btw - my client barfed)

Will do.

As I stare at the code to come up with user visible effects, I am not
convinced the fix is correct.  An update will come after more study.

-- 
Mike Kravetz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
