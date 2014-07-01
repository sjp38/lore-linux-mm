Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f41.google.com (mail-wg0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id ED1EC6B0031
	for <linux-mm@kvack.org>; Tue,  1 Jul 2014 16:15:53 -0400 (EDT)
Received: by mail-wg0-f41.google.com with SMTP id a1so10208987wgh.12
        for <linux-mm@kvack.org>; Tue, 01 Jul 2014 13:15:53 -0700 (PDT)
Received: from kirsi1.inet.fi (mta-out1.inet.fi. [62.71.2.199])
        by mx.google.com with ESMTP id t3si29400832wju.44.2014.07.01.13.15.52
        for <linux-mm@kvack.org>;
        Tue, 01 Jul 2014 13:15:52 -0700 (PDT)
Date: Tue, 1 Jul 2014 23:15:40 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] rmap: fix pgoff calculation to handle hugepage correctly
Message-ID: <20140701201540.GA5953@node.dhcp.inet.fi>
References: <1404225982-22739-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20140701180739.GA4985@node.dhcp.inet.fi>
 <20140701185021.GA10356@nhori.bos.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140701185021.GA10356@nhori.bos.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Hillf Danton <dhillf@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Tue, Jul 01, 2014 at 02:50:21PM -0400, Naoya Horiguchi wrote:
> On Tue, Jul 01, 2014 at 09:07:39PM +0300, Kirill A. Shutemov wrote:
> > Why do we need this special case for hugetlb page ->index? Why not use
> > PAGE_SIZE units there too? Or I miss something?
> 
> hugetlb pages are never split, so we use larger page cache size for
> hugetlbfs file (to avoid large sparse page cache tree.)

For transparent huge page cache I would like to have native support in
page cache radix-tree: since huge pages are always naturally aligned we
can create a leaf node for it several (RADIX_TREE_MAP_SHIFT -
HPAGE_PMD_ORDER) levels up by tree, which would cover all indexes in the
range the huge page represents. This approach should fit hugetlb too. And
-1 special case for hugetlb.
But I'm not sure when I'll get time to play with this...

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
