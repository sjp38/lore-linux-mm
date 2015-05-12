Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f171.google.com (mail-qk0-f171.google.com [209.85.220.171])
	by kanga.kvack.org (Postfix) with ESMTP id 146596B0038
	for <linux-mm@kvack.org>; Tue, 12 May 2015 04:43:54 -0400 (EDT)
Received: by qkgy4 with SMTP id y4so158909qkg.2
        for <linux-mm@kvack.org>; Tue, 12 May 2015 01:43:53 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id e145si7661294qhc.95.2015.05.12.01.43.52
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 May 2015 01:43:52 -0700 (PDT)
Date: Tue, 12 May 2015 11:43:39 +0300
From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: mm: memory-hotplug: enable memory hotplug to handle hugepage
Message-ID: <20150512084339.GN16501@mwanda>
References: <20150511111748.GA20660@mwanda>
 <20150511235443.GA8513@hori1.linux.bs1.fc.nec.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150511235443.GA8513@hori1.linux.bs1.fc.nec.co.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>

On Mon, May 11, 2015 at 11:54:44PM +0000, Naoya Horiguchi wrote:
> @@ -1086,7 +1086,8 @@ static void dissolve_free_huge_page(struct page *page)
>   */
>  void dissolve_free_huge_pages(unsigned long start_pfn, unsigned long end_pfn)
>  {
> -	unsigned int order = 8 * sizeof(void *);
> +	/* Initialized to "high enough" value which is capped later */
> +	unsigned int order = 8 * sizeof(void *) - 1;

Why not use UINT_MAX?  It's more clear that it's not valid that way.
Otherwise doing a complicated calculation it makes it seem like we will
use the variable.

regards,
dan carpenter

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
