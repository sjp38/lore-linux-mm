Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f51.google.com (mail-ee0-f51.google.com [74.125.83.51])
	by kanga.kvack.org (Postfix) with ESMTP id BCCDA6B0102
	for <linux-mm@kvack.org>; Sun, 23 Feb 2014 14:00:18 -0500 (EST)
Received: by mail-ee0-f51.google.com with SMTP id b57so2694491eek.10
        for <linux-mm@kvack.org>; Sun, 23 Feb 2014 11:00:18 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id g47si24551438eev.31.2014.02.23.11.00.15
        for <linux-mm@kvack.org>;
        Sun, 23 Feb 2014 11:00:16 -0800 (PST)
Date: Sun, 23 Feb 2014 13:59:47 -0500
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <530a4540.c7230f0a.4b3d.6f17SMTPIN_ADDED_BROKEN@mx.google.com>
In-Reply-To: <5309F1F8.6040006@oracle.com>
References: <1392068676-30627-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1392068676-30627-12-git-send-email-n-horiguchi@ah.jp.nec.com>
 <5306F29D.8070600@gmail.com>
 <530785b2.d55c8c0a.3868.ffffa4e1SMTPIN_ADDED_BROKEN@mx.google.com>
 <53078A53.9030302@oracle.com>
 <1393003512-qjyhnu0@n-horiguchi@ah.jp.nec.com>
 <5309F1F8.6040006@oracle.com>
Subject: Re: [PATCH 11/11] mempolicy: apply page table walker on
 queue_pages_range()
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: sasha.levin@oracle.com
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, mpm@selenic.com, cpw@sgi.com, kosaki.motohiro@jp.fujitsu.com, hannes@cmpxchg.org, kamezawa.hiroyu@jp.fujitsu.com, mhocko@suse.cz, aneesh.kumar@linux.vnet.ibm.com, xemul@parallels.com, riel@redhat.com, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org

On Sun, Feb 23, 2014 at 08:04:56AM -0500, Sasha Levin wrote:
...
> And here it is:
> 
> [  755.524966] page:ffffea0000000000 count:0 mapcount:1 mapping:          (null) index:0x0
> [  755.526067] page flags: 0x0()
> 
> Followed by the same stack trace as before.

Thanks.

It seems that this page is pfn 0, so we might have invalid value on page
table entry (pointing to pfn 0.) In this -next tree we have some update around
hugetlb fault code (like  "mm, hugetlb: improve page-fault scalability",)
so I'll check there could be a race window from this viewpoint.

Naoya

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
