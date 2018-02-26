Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f200.google.com (mail-yb0-f200.google.com [209.85.213.200])
	by kanga.kvack.org (Postfix) with ESMTP id D53A96B0005
	for <linux-mm@kvack.org>; Mon, 26 Feb 2018 04:43:56 -0500 (EST)
Received: by mail-yb0-f200.google.com with SMTP id b10-v6so391338ybj.1
        for <linux-mm@kvack.org>; Mon, 26 Feb 2018 01:43:56 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e76si3849380wme.5.2018.02.26.01.43.55
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 26 Feb 2018 01:43:55 -0800 (PST)
Date: Mon, 26 Feb 2018 10:43:54 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v2 3/5] dax: fix S_DAX definition
Message-ID: <20180226094354.puos4owvd5s5pxtv@quack2.suse.cz>
References: <151937026001.18973.12034171121582300402.stgit@dwillia2-desk3.amr.corp.intel.com>
 <151937027614.18973.7636331271085629639.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <151937027614.18973.7636331271085629639.stgit@dwillia2-desk3.amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: linux-nvdimm@lists.01.org, Jan Kara <jack@suse.cz>, linux-kernel@vger.kernel.org, stable@vger.kernel.org, linux-mm@kvack.org, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Christoph Hellwig <hch@lst.de>

On Thu 22-02-18 23:17:56, Dan Williams wrote:
> Make sure S_DAX is defined in the CONFIG_FS_DAX=n + CONFIG_DEV_DAX=y
> case. Otherwise vma_is_dax() may incorrectly return false in the
> Device-DAX case.
> 
> Cc: Alexander Viro <viro@zeniv.linux.org.uk>
> Cc: linux-fsdevel@vger.kernel.org
> Cc: Christoph Hellwig <hch@lst.de>
> Cc: Jan Kara <jack@suse.cz>
> Cc: <stable@vger.kernel.org>
> Fixes: dee410792419 ("/dev/dax, core: file operations and dax-mmap")
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>

Looks good. You can add:

Reviewed-by: Jan Kara <jack@suse.cz>

								Honza

> ---
>  include/linux/fs.h |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/include/linux/fs.h b/include/linux/fs.h
> index 79c413985305..b2fa9b4c1e51 100644
> --- a/include/linux/fs.h
> +++ b/include/linux/fs.h
> @@ -1859,7 +1859,7 @@ struct super_operations {
>  #define S_IMA		1024	/* Inode has an associated IMA struct */
>  #define S_AUTOMOUNT	2048	/* Automount/referral quasi-directory */
>  #define S_NOSEC		4096	/* no suid or xattr security attributes */
> -#ifdef CONFIG_FS_DAX
> +#if IS_ENABLED(CONFIG_FS_DAX) || IS_ENABLED(CONFIG_DEV_DAX)
>  #define S_DAX		8192	/* Direct Access, avoiding the page cache */
>  #else
>  #define S_DAX		0	/* Make all the DAX code disappear */
> 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
