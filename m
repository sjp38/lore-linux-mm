Date: Thu, 8 May 2008 14:29:47 -0400
From: Josef Bacik <jbacik@redhat.com>
Subject: Re: NFS infinite loop in filemap_fault()
Message-ID: <20080508182947.GB30499@unused.rdu.redhat.com>
References: <E1JtqLW-0005j5-KU@pomaz-ex.szeredi.hu> <E1JtzuH-0006nY-AM@pomaz-ex.szeredi.hu> <20080508130759.GA30499@unused.rdu.redhat.com> <E1JuB47-0008C9-5n@pomaz-ex.szeredi.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <E1JuB47-0008C9-5n@pomaz-ex.szeredi.hu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: jbacik@redhat.com, trond.myklebust@fys.uio.no, npiggin@suse.de, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, May 08, 2008 at 08:42:03PM +0200, Miklos Szeredi wrote:
> > > Index: linux.git/mm/filemap.c
> > > ===================================================================
> > > --- linux.git.orig/mm/filemap.c	2008-05-08 08:17:22.000000000 +0200
> > > +++ linux.git/mm/filemap.c	2008-05-08 08:19:59.000000000 +0200
> > > @@ -1461,6 +1461,12 @@ page_not_uptodate:
> > >  	 */
> > >  	ClearPageError(page);
> > >  	error = mapping->a_ops->readpage(file, page);
> > > +	if (!error && !PageUptodate(page)) {
> > 
> > Shouldn't you have (!error || error != AOP_TRUNCATED_PAGE),
> 
> That would be a rather useless condition (hint: '!error' means 'error == 0')
> 
> > since the fs can
> > return AOP_TRUNCATED_PAGE if it needs vfs to try the readpage again?
> 
> Yep, I din't touch the 'error != 0' codepath.
>

Doh sorry, I hadn't had my coffee yet.

Josef 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
