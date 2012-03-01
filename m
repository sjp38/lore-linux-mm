Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id DE9AA6B002C
	for <linux-mm@kvack.org>; Thu,  1 Mar 2012 15:37:01 -0500 (EST)
Date: Thu, 1 Mar 2012 21:36:58 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 6/9] fuse: Push file_update_time() into
 fuse_page_mkwrite()
Message-ID: <20120301203658.GC13104@quack.suse.cz>
References: <1330602103-8851-1-git-send-email-jack@suse.cz>
 <1330602103-8851-7-git-send-email-jack@suse.cz>
 <87obsgce4a.fsf@tucsk.pomaz.szeredi.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87obsgce4a.fsf@tucsk.pomaz.szeredi.hu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Al Viro <viro@ZenIV.linux.org.uk>, linux-fsdevel@vger.kernel.org, dchinner@redhat.com, fuse-devel@lists.sourceforge.net

On Thu 01-03-12 20:31:17, Miklos Szeredi wrote:
> Jan Kara <jack@suse.cz> writes:
> 
> > CC: Miklos Szeredi <miklos@szeredi.hu>
> > CC: fuse-devel@lists.sourceforge.net
> > Signed-off-by: Jan Kara <jack@suse.cz>
> > ---
> >  fs/fuse/file.c |    1 +
> >  1 files changed, 1 insertions(+), 0 deletions(-)
> >
> > diff --git a/fs/fuse/file.c b/fs/fuse/file.c
> > index 4a199fd..eade72e 100644
> > --- a/fs/fuse/file.c
> > +++ b/fs/fuse/file.c
> > @@ -1323,6 +1323,7 @@ static int fuse_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
> >  	 */
> >  	struct inode *inode = vma->vm_file->f_mapping->host;
> >  
> > +	file_update_time(vma->vm_file);
> 
> Fuse sets S_CMTIME in inode flags, so this is a no-op.  IOW the patch is
> not needed.
  I see. Thanks. Patch dropped.

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
