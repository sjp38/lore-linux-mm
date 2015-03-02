Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 2ACAA6B006C
	for <linux-mm@kvack.org>; Mon,  2 Mar 2015 18:10:20 -0500 (EST)
Received: by pdno5 with SMTP id o5so43219829pdn.8
        for <linux-mm@kvack.org>; Mon, 02 Mar 2015 15:10:19 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id fh4si18271818pdb.133.2015.03.02.15.10.19
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Mar 2015 15:10:19 -0800 (PST)
Date: Mon, 2 Mar 2015 15:10:18 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC 1/3] hugetlbfs: add reserved mount fields to subpool
 structure
Message-Id: <20150302151018.ce35298f22d04d6d0296e53c@linux-foundation.org>
In-Reply-To: <1425077893-18366-3-git-send-email-mike.kravetz@oracle.com>
References: <1425077893-18366-1-git-send-email-mike.kravetz@oracle.com>
	<1425077893-18366-3-git-send-email-mike.kravetz@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Nadia Yvette Chambers <nyc@holomorphy.com>, Davidlohr Bueso <davidlohr@hp.com>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Fri, 27 Feb 2015 14:58:10 -0800 Mike Kravetz <mike.kravetz@oracle.com> wrote:

> Add a boolean to the subpool structure to indicate that the pages for
> subpool have been reserved.  The hstate pointer in the subpool is
> convienient to have when it comes time to unreserve the pages.
> subool_reserved() is a handy way to check if reserved and take into
> account a NULL subpool.
> 
> ...
>
> @@ -38,6 +40,10 @@ extern int hugetlb_max_hstate __read_mostly;
>  #define for_each_hstate(h) \
>  	for ((h) = hstates; (h) < &hstates[hugetlb_max_hstate]; (h)++)
>  
> +static inline bool subpool_reserved(struct hugepage_subpool *spool)
> +{
> +	return spool && spool->reserved;
> +}

"subpool_reserved" is not a good identifier.

>  struct hugepage_subpool *hugepage_new_subpool(long nr_blocks);
>  void hugepage_put_subpool(struct hugepage_subpool *spool);

See what they did?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
