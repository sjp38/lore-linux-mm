Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id E8F716B0002
	for <linux-mm@kvack.org>; Thu, 28 Feb 2013 19:37:44 -0500 (EST)
Date: Fri, 1 Mar 2013 00:37:41 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH] shmem: fix build regression
Message-ID: <20130301003740.GS4503@ZenIV.linux.org.uk>
References: <1362093459-24608-1-git-send-email-wsa@the-dreams.de>
 <20130228163111.5d61d391.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130228163111.5d61d391.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Wolfram Sang <wsa@the-dreams.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, Feb 28, 2013 at 04:31:11PM -0800, Andrew Morton wrote:

> -#ifndef CONFIG_MMU
> -	error = ramfs_nommu_expand_for_mapping(inode, size);
> -	res = ERR_PTR(error);
> -	if (error)
> +
> +	res = ERR_PTR(ramfs_nommu_expand_for_mapping(inode, size));
> +	if (IS_ERR(res))
>  		goto put_dentry;

My variant of fix leaves #ifndef in place and makes the check if (res) goto...
I'm not opposed to killing the ifndef, but I think it should be a separate
patch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
