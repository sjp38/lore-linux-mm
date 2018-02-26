Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0980A6B0005
	for <linux-mm@kvack.org>; Mon, 26 Feb 2018 05:08:35 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id d23so5832335wmd.1
        for <linux-mm@kvack.org>; Mon, 26 Feb 2018 02:08:34 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k129si5205791wme.177.2018.02.26.02.08.33
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 26 Feb 2018 02:08:33 -0800 (PST)
Date: Mon, 26 Feb 2018 11:08:32 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v3 5/6] dax: short circuit vma_is_fsdax() in the
 CONFIG_FS_DAX=n case
Message-ID: <20180226100832.xidetsf3eoagumqd@quack2.suse.cz>
References: <151943298533.29249.14597996053028346159.stgit@dwillia2-desk3.amr.corp.intel.com>
 <151943301788.29249.13371602951635567379.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <151943301788.29249.13371602951635567379.stgit@dwillia2-desk3.amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: linux-nvdimm@lists.01.org, Jan Kara <jack@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Christoph Hellwig <hch@lst.de>

On Fri 23-02-18 16:43:37, Dan Williams wrote:
> Do not bother looking up the file type in the case when Filesystem-DAX
> is disabled at build time.
> 
> Cc: Alexander Viro <viro@zeniv.linux.org.uk>
> Cc: linux-fsdevel@vger.kernel.org
> Cc: Christoph Hellwig <hch@lst.de>
> Cc: Jan Kara <jack@suse.cz>
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>

Looks good. You can add:

Reviewed-by: Jan Kara <jack@suse.cz>

								Honza

> ---
>  include/linux/fs.h |    2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/include/linux/fs.h b/include/linux/fs.h
> index 7418341578a3..c97fc4dbaae1 100644
> --- a/include/linux/fs.h
> +++ b/include/linux/fs.h
> @@ -3197,6 +3197,8 @@ static inline bool vma_is_fsdax(struct vm_area_struct *vma)
>  
>  	if (!vma->vm_file)
>  		return false;
> +	if (!IS_ENABLED(CONFIG_FS_DAX))
> +		return false;
>  	if (!vma_is_dax(vma))
>  		return false;
>  	inode = file_inode(vma->vm_file);
> 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
