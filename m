Received: from spaceape14.eur.corp.google.com (spaceape14.eur.corp.google.com [172.28.16.148])
	by smtp-out.google.com with ESMTP id l1CMEo0j030043
	for <linux-mm@kvack.org>; Mon, 12 Feb 2007 22:14:50 GMT
Received: from py-out-1112.google.com (pyea73.prod.google.com [10.34.153.73])
	by spaceape14.eur.corp.google.com with ESMTP id l1CMEiEb030326
	for <linux-mm@kvack.org>; Mon, 12 Feb 2007 22:14:44 GMT
Received: by py-out-1112.google.com with SMTP id a73so934346pye
        for <linux-mm@kvack.org>; Mon, 12 Feb 2007 14:14:43 -0800 (PST)
Message-ID: <b040c32a0702121414oc570ccfhd8b78a87c5ff7b86@mail.gmail.com>
Date: Mon, 12 Feb 2007 14:14:43 -0800
From: "Ken Chen" <kenchen@google.com>
Subject: Re: [PATCH 1/1] Enable fully functional truncate for hugetlbfs
In-Reply-To: <20070212142802.15738.80487.sendpatchset@wildcat.int.mccr.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20070212142802.15738.80487.sendpatchset@wildcat.int.mccr.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave McCracken <dave.mccracken@oracle.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Adam Litke <agl@us.ibm.com>
List-ID: <linux-mm.kvack.org>

On 2/12/07, Dave McCracken <dave.mccracken@oracle.com> wrote:
> This patch enables the full functionality of truncate for hugetlbfs
> files.  Truncate was originally limited to reducing the file size
> because page faults were not supported for hugetlbfs.  Now that page
> faults have been implemented it is now possible to fully support
> truncate.

ye!

> --- 2.6.20/./fs/hugetlbfs/inode.c       2007-02-04 12:44:54.000000000 -0600
> +++ 2.6.20-htrunc/./fs/hugetlbfs/inode.c        2007-02-05 13:02:00.000000000 -0600
> +       if (hugetlb_reserve_pages(inode, inode->i_size >> HPAGE_SHIFT,
> +                                 offset >> HPAGE_SHIFT))
> +               goto out_mem;
> +       i_size_write(inode, offset);

hugetlb_reserve_pages() is used to reserve pages for shared mapping
and is used only for the size of mapping at the time of mmap().  We
shouldn't call this function when expanding hugetlb file.

- Ken

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
