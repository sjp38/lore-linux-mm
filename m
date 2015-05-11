Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f52.google.com (mail-oi0-f52.google.com [209.85.218.52])
	by kanga.kvack.org (Postfix) with ESMTP id 48A4C6B0038
	for <linux-mm@kvack.org>; Mon, 11 May 2015 07:29:34 -0400 (EDT)
Received: by oiko83 with SMTP id o83so101701465oik.1
        for <linux-mm@kvack.org>; Mon, 11 May 2015 04:29:34 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id bj4si6991370oec.64.2015.05.11.04.29.33
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 May 2015 04:29:33 -0700 (PDT)
Date: Mon, 11 May 2015 14:29:24 +0300
From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: mm: memory-hotplug: enable memory hotplug to handle hugepage
Message-ID: <20150511112924.GM16501@mwanda>
References: <20150511111748.GA20660@mwanda>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150511111748.GA20660@mwanda>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: n-horiguchi@ah.jp.nec.com
Cc: linux-mm@kvack.org

On Mon, May 11, 2015 at 02:17:48PM +0300, Dan Carpenter wrote:
> Hello Naoya Horiguchi,
> 
> The patch c8721bbbdd36: "mm: memory-hotplug: enable memory hotplug to
> handle hugepage" from Sep 11, 2013, leads to the following static
> checker warning:
> 
> 	mm/hugetlb.c:1203 dissolve_free_huge_pages()
> 	warn: potential right shift more than type allows '9,18,64'
> 
> mm/hugetlb.c
>   1189  void dissolve_free_huge_pages(unsigned long start_pfn, unsigned long end_pfn)
>   1190  {
>   1191          unsigned int order = 8 * sizeof(void *);
>                                      ^^^^^^^^^^^^^^^^^^
> Let's say order is 64.

Actually, the 64 here is just chosen to be an impossibly high number
isn't it?  It's a bit complicated to understand that at first glance.

regards,
dan carpenter

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
