Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id 856D36B0082
	for <linux-mm@kvack.org>; Thu, 16 Feb 2012 11:46:34 -0500 (EST)
Subject: Re: [PATCH 08/11] gfs2: Push file_update_time() into
 gfs2_page_mkwrite()
From: Steven Whitehouse <swhiteho@redhat.com>
In-Reply-To: <1329399979-3647-9-git-send-email-jack@suse.cz>
References: <1329399979-3647-1-git-send-email-jack@suse.cz>
	 <1329399979-3647-9-git-send-email-jack@suse.cz>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 16 Feb 2012 16:47:20 +0000
Message-ID: <1329410840.2719.27.camel@menhir>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Eric Sandeen <sandeen@redhat.com>, Dave Chinner <david@fromorbit.com>, cluster-devel@redhat.com

Hi,

On Thu, 2012-02-16 at 14:46 +0100, Jan Kara wrote:
> CC: Steven Whitehouse <swhiteho@redhat.com>
> CC: cluster-devel@redhat.com
> Signed-off-by: Jan Kara <jack@suse.cz>
> ---
>  fs/gfs2/file.c |    3 +++
>  1 files changed, 3 insertions(+), 0 deletions(-)
> 
That looks ok to me... 

Acked-by: Steven Whitehouse <swhiteho@redhat.com>

Steve.

> diff --git a/fs/gfs2/file.c b/fs/gfs2/file.c
> index c5fb359..1f03531 100644
> --- a/fs/gfs2/file.c
> +++ b/fs/gfs2/file.c
> @@ -375,6 +375,9 @@ static int gfs2_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
>  	 */
>  	vfs_check_frozen(inode->i_sb, SB_FREEZE_WRITE);
>  
> +	/* Update file times before taking page lock */
> +	file_update_time(vma->vm_file);
> +
>  	gfs2_holder_init(ip->i_gl, LM_ST_EXCLUSIVE, 0, &gh);
>  	ret = gfs2_glock_nq(&gh);
>  	if (ret)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
