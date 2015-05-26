Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 460BB6B0126
	for <linux-mm@kvack.org>; Tue, 26 May 2015 19:09:02 -0400 (EDT)
Received: by pdfh10 with SMTP id h10so101041750pdf.3
        for <linux-mm@kvack.org>; Tue, 26 May 2015 16:09:02 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id x12si22905556pbt.138.2015.05.26.16.09.01
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 May 2015 16:09:01 -0700 (PDT)
Date: Tue, 26 May 2015 16:09:00 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm/hugetlb: document the reserve map/region tracking
 routines
Message-Id: <20150526160900.0c0868b73e40995d3d65c616@linux-foundation.org>
In-Reply-To: <1432675630-7623-1-git-send-email-mike.kravetz@oracle.com>
References: <1432675630-7623-1-git-send-email-mike.kravetz@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Davidlohr Bueso <dave@stgolabs.net>, David Rientjes <rientjes@google.com>, Luiz Capitulino <lcapitulino@redhat.com>

On Tue, 26 May 2015 14:27:10 -0700 Mike Kravetz <mike.kravetz@oracle.com> wrote:

> This is a documentation only patch and does not modify any code.
> Descriptions of the routines used for reserve map/region tracking
> are added.

Confused.  This adds comments which are similar to the ones which were
added by
mm-hugetlb-compute-return-the-number-of-regions-added-by-region_add-v2.patch
and
mm-hugetlb-handle-races-in-alloc_huge_page-and-hugetlb_reserve_pages-v2.patch.
But the comments are a bit different.  And this patch madly conflicts
with the two abovementioned patches.

Maybe the thing to do is to start again, with a three-patch series:

mm-hugetlb-document-the-reserve-map-region-tracking-routines.patch
mm-hugetlb-compute-return-the-number-of-regions-added-by-region_add-v3.patch
mm-hugetlb-handle-races-in-alloc_huge_page-and-hugetlb_reserve_pages-v3.patch

while resolving the differences in the new code comments?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
