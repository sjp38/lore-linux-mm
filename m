Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id 475CE6B002C
	for <linux-mm@kvack.org>; Thu,  1 Mar 2012 07:30:38 -0500 (EST)
Date: Thu, 1 Mar 2012 13:30:35 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 4/9] cifs: Push file_update_time() into
 cifs_page_mkwrite()
Message-ID: <20120301123035.GF4385@quack.suse.cz>
References: <1330602103-8851-1-git-send-email-jack@suse.cz>
 <1330602103-8851-5-git-send-email-jack@suse.cz>
 <20120301072537.502bd918@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120301072537.502bd918@tlielax.poochiereds.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Al Viro <viro@ZenIV.linux.org.uk>, linux-fsdevel@vger.kernel.org, dchinner@redhat.com, Steve French <sfrench@samba.org>, linux-cifs@vger.kernel.org

On Thu 01-03-12 07:25:37, Jeff Layton wrote:
> On Thu,  1 Mar 2012 12:41:38 +0100
> Jan Kara <jack@suse.cz> wrote:
> 
> > CC: Steve French <sfrench@samba.org>
> > CC: linux-cifs@vger.kernel.org
> > Signed-off-by: Jan Kara <jack@suse.cz>
> > ---
> >  fs/cifs/file.c |    3 +++
> >  1 files changed, 3 insertions(+), 0 deletions(-)
> > 
> > diff --git a/fs/cifs/file.c b/fs/cifs/file.c
> > index 4dd9283..8e3b23b 100644
> > --- a/fs/cifs/file.c
> > +++ b/fs/cifs/file.c
> > @@ -2425,6 +2425,9 @@ cifs_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
> >  {
> >  	struct page *page = vmf->page;
> >  
> > +	/* Update file times before taking page lock */
> > +	file_update_time(vma->vm_file);
> > +
> >  	lock_page(page);
> >  	return VM_FAULT_LOCKED;
> >  }
> 
> Sorry, I meant to comment on this earlier...
> 
> I think we can probably drop this patch. cifs doesn't currently set
> S_NOCMTIME on all inodes (only when MS_NOATIME is set currently), but I
> think that it probably should. Timestamps should be the purview of the
> server.
  OK, thanks for letting me know. Patch dropped.

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
