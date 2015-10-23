Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id 8EE836B0253
	for <linux-mm@kvack.org>; Fri, 23 Oct 2015 09:46:04 -0400 (EDT)
Received: by wijp11 with SMTP id p11so78300577wij.0
        for <linux-mm@kvack.org>; Fri, 23 Oct 2015 06:46:04 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id dh8si24959261wjc.205.2015.10.23.06.46.02
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 23 Oct 2015 06:46:03 -0700 (PDT)
Date: Fri, 23 Oct 2015 06:45:53 -0700
From: Davidlohr Bueso <dave@stgolabs.net>
Subject: Re: [PATCH] mm/hugetlb: i_mmap_lock_write before unmapping in
 remove_inode_hugepages
Message-ID: <20151023134553.GE27292@linux-uzut.site>
References: <1445478147-29782-1-git-send-email-mike.kravetz@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <1445478147-29782-1-git-send-email-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>

On Wed, 21 Oct 2015, Mike Kravetz wrote:

>Code was added to remove_inode_hugepages that will unmap a page if
>it is mapped.  i_mmap_lock_write() must be taken during the call
>to hugetlb_vmdelete_list().  This is to prevent mappings(vmas) from
>being added or deleted while the list of vmas is being examined.
                                   ^^^^ interval-tree.
>
>Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>

Reviewed-by: Davidlohr Bueso <dbueso@suse.de>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
