Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id 85A396B00F8
	for <linux-mm@kvack.org>; Mon, 20 Feb 2012 17:57:01 -0500 (EST)
Date: Mon, 20 Feb 2012 14:57:00 -0800 (PST)
From: Sage Weil <sage@newdream.net>
Subject: Re: [PATCH 04/11] ceph: Push file_update_time() into ceph_page_mkwrite()
In-Reply-To: <20120220224245.GE32708@quack.suse.cz>
Message-ID: <Pine.LNX.4.64.1202201456400.1154@cobra.newdream.net>
References: <1329399979-3647-1-git-send-email-jack@suse.cz>
 <1329399979-3647-5-git-send-email-jack@suse.cz> <1329419077.3121.38.camel@doink>
 <Pine.LNX.4.64.1202161113001.24079@cobra.newdream.net> <20120220224245.GE32708@quack.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Alex Elder <elder@dreamhost.com>, LKML <linux-kernel@vger.kernel.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Eric Sandeen <sandeen@redhat.com>, Dave Chinner <david@fromorbit.com>, ceph-devel@vger.kernel.org

On Mon, 20 Feb 2012, Jan Kara wrote:
> On Thu 16-02-12 11:13:53, Sage Weil wrote:
> > On Thu, 16 Feb 2012, Alex Elder wrote:
> > > On Thu, 2012-02-16 at 14:46 +0100, Jan Kara wrote:
> > > > CC: Sage Weil <sage@newdream.net>
> > > > CC: ceph-devel@vger.kernel.org
> > > > Signed-off-by: Jan Kara <jack@suse.cz>
> > > 
> > > 
> > > This will update the timestamp even if a write
> > > fault fails, which is different from before.
> > > 
> > > Hard to avoid though.
> > > 
> > > Looks good to me.
> > 
> > Yeah.  Let's put something in the tracker to take a look later (I think we 
> > can do better), but this is okay for now.
> > 
> > Signed-off-by: Sage Weil <sage@newdream.net>
>   Thanks! Just an administrative note - the tag above should rather be
> Acked-by or Reviewed-by. You'd use Signed-off-by only if you took the patch
> and merged it via your tree... So can I add Acked-by?

Oh, right.  Acked-by!

sage

> 
> 								Honza
> 
> > > Signed-off-by: Alex Elder <elder@dreamhost.com>
> > > 
> > > >  fs/ceph/addr.c |    3 +++
> > > >  1 files changed, 3 insertions(+), 0 deletions(-)
> > > > 
> > > > diff --git a/fs/ceph/addr.c b/fs/ceph/addr.c
> > > > index 173b1d2..12b139f 100644
> > > > --- a/fs/ceph/addr.c
> > > > +++ b/fs/ceph/addr.c
> > > > @@ -1181,6 +1181,9 @@ static int ceph_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
> > > >  	loff_t size, len;
> > > >  	int ret;
> > > >  
> > > > +	/* Update time before taking page lock */
> > > > +	file_update_time(vma->vm_file);
> > > > +
> > > >  	size = i_size_read(inode);
> > > >  	if (off + PAGE_CACHE_SIZE <= size)
> > > >  		len = PAGE_CACHE_SIZE;
> > > 
> > > 
> > > 
> > > --
> > > To unsubscribe from this list: send the line "unsubscribe ceph-devel" in
> > > the body of a message to majordomo@vger.kernel.org
> > > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > > 
> > > 
> -- 
> Jan Kara <jack@suse.cz>
> SUSE Labs, CR
> --
> To unsubscribe from this list: send the line "unsubscribe ceph-devel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
