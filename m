Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id 880116B002C
	for <linux-mm@kvack.org>; Thu,  1 Mar 2012 14:31:13 -0500 (EST)
Received: by eaal1 with SMTP id l1so421155eaa.14
        for <linux-mm@kvack.org>; Thu, 01 Mar 2012 11:31:11 -0800 (PST)
From: Miklos Szeredi <miklos@szeredi.hu>
Subject: Re: [PATCH 6/9] fuse: Push file_update_time() into fuse_page_mkwrite()
References: <1330602103-8851-1-git-send-email-jack@suse.cz>
	<1330602103-8851-7-git-send-email-jack@suse.cz>
Date: Thu, 01 Mar 2012 20:31:17 +0100
In-Reply-To: <1330602103-8851-7-git-send-email-jack@suse.cz> (Jan Kara's
	message of "Thu, 1 Mar 2012 12:41:40 +0100")
Message-ID: <87obsgce4a.fsf@tucsk.pomaz.szeredi.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Al Viro <viro@ZenIV.linux.org.uk>, linux-fsdevel@vger.kernel.org, dchinner@redhat.com, fuse-devel@lists.sourceforge.net

Jan Kara <jack@suse.cz> writes:

> CC: Miklos Szeredi <miklos@szeredi.hu>
> CC: fuse-devel@lists.sourceforge.net
> Signed-off-by: Jan Kara <jack@suse.cz>
> ---
>  fs/fuse/file.c |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
>
> diff --git a/fs/fuse/file.c b/fs/fuse/file.c
> index 4a199fd..eade72e 100644
> --- a/fs/fuse/file.c
> +++ b/fs/fuse/file.c
> @@ -1323,6 +1323,7 @@ static int fuse_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
>  	 */
>  	struct inode *inode = vma->vm_file->f_mapping->host;
>  
> +	file_update_time(vma->vm_file);

Fuse sets S_CMTIME in inode flags, so this is a no-op.  IOW the patch is
not needed.

Thanks,
Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
