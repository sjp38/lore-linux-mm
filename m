Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id D3FEF6B0031
	for <linux-mm@kvack.org>; Mon, 13 Jan 2014 15:33:51 -0500 (EST)
Received: by mail-pd0-f172.google.com with SMTP id z10so2526551pdj.31
        for <linux-mm@kvack.org>; Mon, 13 Jan 2014 12:33:51 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id yy4si16659320pbc.159.2014.01.13.12.33.50
        for <linux-mm@kvack.org>;
        Mon, 13 Jan 2014 12:33:50 -0800 (PST)
Message-ID: <52D44D55.2090709@intel.com>
Date: Mon, 13 Jan 2014 12:32:21 -0800
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH] shmem: init on stack vmas
References: <1389638777-31891-1-git-send-email-jbacik@fb.com>
In-Reply-To: <1389638777-31891-1-git-send-email-jbacik@fb.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Josef Bacik <jbacik@fb.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

On 01/13/2014 10:46 AM, Josef Bacik wrote:
> We were hitting a weird bug with our cgroup stuff because shmem uses on stack
> vmas.  These aren't properly init'ed so we'd have garbage in vma->mm and bad
> things would happen.  Fix this by just init'ing to empty structs.  Thanks,
...
>  static struct page *shmem_swapin(swp_entry_t swap, gfp_t gfp,
>  			struct shmem_inode_info *info, pgoff_t index)
>  {
> -	struct vm_area_struct pvma;
> +	struct vm_area_struct pvma = {};

What does that code do if it needs an mm and doesn't find one?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
