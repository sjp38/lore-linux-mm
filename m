Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id 6DAAB6B00AF
	for <linux-mm@kvack.org>; Mon, 25 May 2015 16:29:54 -0400 (EDT)
Received: by wifw1 with SMTP id w1so7884437wif.0
        for <linux-mm@kvack.org>; Mon, 25 May 2015 13:29:53 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id fz5si14273354wib.94.2015.05.25.13.29.52
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 25 May 2015 13:29:52 -0700 (PDT)
Message-ID: <1432585785.2185.59.camel@stgolabs.net>
Subject: Re: [PATCH v2 1/2] mm/hugetlb: compute/return the number of regions
 added by region_add()
From: Davidlohr Bueso <dave@stgolabs.net>
Date: Mon, 25 May 2015 13:29:45 -0700
In-Reply-To: <1432353304-12767-2-git-send-email-mike.kravetz@oracle.com>
References: <1432353304-12767-1-git-send-email-mike.kravetz@oracle.com>
	 <1432353304-12767-2-git-send-email-mike.kravetz@oracle.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Rientjes <rientjes@google.com>, Luiz Capitulino <lcapitulino@redhat.com>, Andrew Morton <akpm@linux-foundation.org>

On Fri, 2015-05-22 at 20:55 -0700, Mike Kravetz wrote:
> + * The region data structures are embedded into a resv_map and protected
> + * by a resv_map's lock.  The set of regions within the resv_map represent
> + * reservations for huge pages, or huge pages that have already been
> + * instantiated within the map.  The from and to elements are huge page
> + * indicies into the associated mapping.  from indicates the starting index
> + * of the region.  to represents the first index past the end of  the region.

newline

> + * For example, a file region structure with from == 0 and to == 4 represents
> + * four huge pages in a mapping.  It is important to note that the to element
> + * represents the first element past the end of the region. This is used in
> + * arithmetic as 4(to) - 0(from) = 4 huge pages in the region.
>   */
>  struct file_region {
>  	struct list_head link;
> @@ -221,10 +229,23 @@ struct file_region {
>  	long to;
>  };
>  
> +/*
> + * Add the huge page range represented by indicies f (from)
> + * and t (to) to the reserve map.  Existing regions will be

How about simply renaming those parameters to from and to across the
entire hugetlb code.

Thanks,
Davidlohr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
