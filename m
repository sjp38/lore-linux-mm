Date: Wed, 7 Nov 2007 10:43:48 +0100
From: =?utf-8?B?SsO2cm4=?= Engel <joern@logfs.org>
Subject: Re: [patch 04/23] dentries: Extract common code to remove dentry from lru
Message-ID: <20071107094348.GB7374@lazybastard.org>
References: <20071107011130.382244340@sgi.com> <20071107011227.298491275@sgi.com> <20071107085027.GA6243@cataract>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20071107085027.GA6243@cataract>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Johannes Weiner <hannes-kernel@saeurebad.de>
Cc: Christoph Lameter <clameter@sgi.com>, akpm@linux-foundatin.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mel@skynet.ie>
List-ID: <linux-mm.kvack.org>

On Wed, 7 November 2007 09:50:27 +0100, Johannes Weiner wrote:
> On Tue, Nov 06, 2007 at 05:11:34PM -0800, Christoph Lameter wrote:
> > @@ -613,11 +606,7 @@ static void shrink_dcache_for_umount_sub
> >  			spin_lock(&dcache_lock);
> >  			list_for_each_entry(loop, &dentry->d_subdirs,
> >  					    d_u.d_child) {
> > -				if (!list_empty(&loop->d_lru)) {
> > -					dentry_stat.nr_unused--;
> > -					list_del_init(&loop->d_lru);
> > -				}
> > -
> > +				dentry_lru_remove(dentry);
> 
> Shouldn't this be dentry_lru_remove(loop)?

Looks like it.  Once this is fixed, feel free to add
Acked-by: Joern Engel <joern@logfs.org>

JA?rn

-- 
It does not require a majority to prevail, but rather an irate,
tireless minority keen to set brush fires in people's minds.
-- Samuel Adams

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
