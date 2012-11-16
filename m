Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id 398B86B004D
	for <linux-mm@kvack.org>; Fri, 16 Nov 2012 01:39:39 -0500 (EST)
Received: by mail-ia0-f169.google.com with SMTP id r4so1840175iaj.14
        for <linux-mm@kvack.org>; Thu, 15 Nov 2012 22:39:38 -0800 (PST)
Message-ID: <50A5DFA4.2030700@gmail.com>
Date: Fri, 16 Nov 2012 14:39:32 +0800
From: Jaegeuk Hanse <jaegeuk.hanse@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 20/21] mm: drop vmtruncate
References: <5094E4A3.8020409@gmail.com>
In-Reply-To: <5094E4A3.8020409@gmail.com>
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marco Stornelli <marco.stornelli@gmail.com>
Cc: Linux FS Devel <linux-fsdevel@vger.kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 11/03/2012 05:32 PM, Marco Stornelli wrote:
> Removed vmtruncate

Hi Marco,

Could you explain me why vmtruncate need remove? What's the problem and 
how to substitute it?

Regards,
Jaegeuk

>
> Signed-off-by: Marco Stornelli <marco.stornelli@gmail.com>
> ---
>   include/linux/mm.h |    1 -
>   mm/truncate.c      |   23 -----------------------
>   2 files changed, 0 insertions(+), 24 deletions(-)
>
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index fa06804..95f70bb 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -977,7 +977,6 @@ static inline void unmap_shared_mapping_range(struct address_space *mapping,
>   
>   extern void truncate_pagecache(struct inode *inode, loff_t old, loff_t new);
>   extern void truncate_setsize(struct inode *inode, loff_t newsize);
> -extern int vmtruncate(struct inode *inode, loff_t offset);
>   void truncate_pagecache_range(struct inode *inode, loff_t offset, loff_t end);
>   int truncate_inode_page(struct address_space *mapping, struct page *page);
>   int generic_error_remove_page(struct address_space *mapping, struct page *page);
> diff --git a/mm/truncate.c b/mm/truncate.c
> index d51ce92..c75b736 100644
> --- a/mm/truncate.c
> +++ b/mm/truncate.c
> @@ -577,29 +577,6 @@ void truncate_setsize(struct inode *inode, loff_t newsize)
>   EXPORT_SYMBOL(truncate_setsize);
>   
>   /**
> - * vmtruncate - unmap mappings "freed" by truncate() syscall
> - * @inode: inode of the file used
> - * @newsize: file offset to start truncating
> - *
> - * This function is deprecated and truncate_setsize or truncate_pagecache
> - * should be used instead, together with filesystem specific block truncation.
> - */
> -int vmtruncate(struct inode *inode, loff_t newsize)
> -{
> -	int error;
> -
> -	error = inode_newsize_ok(inode, newsize);
> -	if (error)
> -		return error;
> -
> -	truncate_setsize(inode, newsize);
> -	if (inode->i_op->truncate)
> -		inode->i_op->truncate(inode);
> -	return 0;
> -}
> -EXPORT_SYMBOL(vmtruncate);
> -
> -/**
>    * truncate_pagecache_range - unmap and remove pagecache that is hole-punched
>    * @inode: inode
>    * @lstart: offset of beginning of hole

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
