Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id DC7986B0003
	for <linux-mm@kvack.org>; Sat, 28 Jul 2018 15:02:59 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id o16-v6so4901677pgv.21
        for <linux-mm@kvack.org>; Sat, 28 Jul 2018 12:02:59 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id p32-v6si6958034pgb.198.2018.07.28.12.02.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 28 Jul 2018 12:02:58 -0700 (PDT)
Date: Sat, 28 Jul 2018 12:02:48 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] ipc/shm.c add ->pagesize function to shm_vm_ops
Message-ID: <20180728190248.GA883@bombadil.infradead.org>
References: <20180727211727.5020-1-jane.chu@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180727211727.5020-1-jane.chu@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jane Chu <jane.chu@oracle.com>
Cc: akpm@linux-foundation.org, dan.j.williams@intel.com, mhocko@suse.com, jack@suse.cz, jglisse@redhat.com, mike.kravetz@oracle.com, dave@stgolabs.net, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-kernel@vger.kernel.org

On Fri, Jul 27, 2018 at 03:17:27PM -0600, Jane Chu wrote:
> +++ b/include/linux/mm.h
> @@ -387,6 +387,13 @@ enum page_entry_size {
>   * These are the virtual MM functions - opening of an area, closing and
>   * unmapping it (needed to keep files on disk up-to-date etc), pointer
>   * to the functions called when a no-page or a wp-page exception occurs.
> + *
> + * Note, when a new function is introduced to vm_operations_struct and
> + * added to hugetlb_vm_ops, please consider adding the function to
> + * shm_vm_ops. This is because under System V memory model, though
> + * mappings created via shmget/shmat with "huge page" specified are
> + * backed by hugetlbfs files, their original vm_ops are overwritten with
> + * shm_vm_ops.
>   */
>  struct vm_operations_struct {

I don't think this header file is the right place for this comment.
I'd think a better place for it would be at the definition of hugetlb_vm_ops.
