Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 3274E6B0120
	for <linux-mm@kvack.org>; Tue, 26 May 2015 23:40:19 -0400 (EDT)
Received: by pdea3 with SMTP id a3so106638416pde.2
        for <linux-mm@kvack.org>; Tue, 26 May 2015 20:40:18 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id fn10si23883192pab.103.2015.05.26.20.40.16
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 May 2015 20:40:18 -0700 (PDT)
Message-ID: <55653A6C.3060707@oracle.com>
Date: Tue, 26 May 2015 20:30:52 -0700
From: Mike Kravetz <mike.kravetz@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm/hugetlb: document the reserve map/region tracking
 routines
References: <1432675630-7623-1-git-send-email-mike.kravetz@oracle.com> <20150526160900.0c0868b73e40995d3d65c616@linux-foundation.org>
In-Reply-To: <20150526160900.0c0868b73e40995d3d65c616@linux-foundation.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Davidlohr Bueso <dave@stgolabs.net>, David Rientjes <rientjes@google.com>, Luiz Capitulino <lcapitulino@redhat.com>

On 05/26/2015 04:09 PM, Andrew Morton wrote:
> On Tue, 26 May 2015 14:27:10 -0700 Mike Kravetz <mike.kravetz@oracle.com> wrote:
>
>> This is a documentation only patch and does not modify any code.
>> Descriptions of the routines used for reserve map/region tracking
>> are added.
>
> Confused.  This adds comments which are similar to the ones which were
> added by
> mm-hugetlb-compute-return-the-number-of-regions-added-by-region_add-v2.patch
> and
> mm-hugetlb-handle-races-in-alloc_huge_page-and-hugetlb_reserve_pages-v2.patch.
> But the comments are a bit different.  And this patch madly conflicts
> with the two abovementioned patches.
>
> Maybe the thing to do is to start again, with a three-patch series:
>
> mm-hugetlb-document-the-reserve-map-region-tracking-routines.patch
> mm-hugetlb-compute-return-the-number-of-regions-added-by-region_add-v3.patch
> mm-hugetlb-handle-races-in-alloc_huge_page-and-hugetlb_reserve_pages-v3.patch
>
> while resolving the differences in the new code comments?
>

Sorry for the confusion.  Naoya and Davidlohr suggested changes to
the documentation and code.  One suggestion was to create a separate
documentation only patch.


I will create a new series as you suggest above.

-- 
Mike Kravetz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
