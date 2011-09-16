Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 1E0319000BD
	for <linux-mm@kvack.org>; Fri, 16 Sep 2011 14:08:12 -0400 (EDT)
Date: Fri, 16 Sep 2011 19:55:52 +0200
From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH] staging: zcache: fix cleancache crash
Message-ID: <20110916175552.GA25405@kroah.com>
References: <a7d17e7e-c6a1-448e-b60f-b79a4ae0c3ba@default>
 <8cb0f464-7e39-4294-9f98-c4c5a66110ba@default>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <8cb0f464-7e39-4294-9f98-c4c5a66110ba@default>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: gregkh@suse.de, devel@driverdev.osuosl.org, linux-mm@kvack.org, ngupta@vflare.org, linux-kernel@vger.kernel.org, francis.moro@gmail.com, Seth Jennings <sjenning@linux.vnet.ibm.com>

On Thu, Sep 15, 2011 at 07:16:10AM -0700, Dan Magenheimer wrote:
> > From: Dan Magenheimer
> > Sent: Tuesday, September 13, 2011 2:56 PM
> > To: Seth Jennings; gregkh@suse.de
> > Cc: devel@driverdev.osuosl.org; linux-mm@kvack.org; ngupta@vflare.org; linux-kernel@vger.kernel.org;
> > francis.moro@gmail.com
> > Subject: RE: [PATCH] staging: zcache: fix cleancache crash
> > 
> > > From: Seth Jennings [mailto:sjenning@linux.vnet.ibm.com]
> > > Sent: Tuesday, September 13, 2011 1:19 PM
> > > To: gregkh@suse.de
> > > Cc: devel@driverdev.osuosl.org; linux-mm@kvack.org; ngupta@vflare.org; linux-kernel@vger.kernel.org;
> > > francis.moro@gmail.com; Dan Magenheimer; Seth Jennings
> > > Subject: [PATCH] staging: zcache: fix cleancache crash
> > >
> > > After commit, c5f5c4db, cleancache crashes on the first
> > > successful get. This was caused by a remaining virt_to_page()
> > > call in zcache_pampd_get_data_and_free() that only gets
> > > run in the cleancache path.
> > >
> > > The patch converts the virt_to_page() to struct page
> > > casting like was done for other instances in c5f5c4db.
> > >
> > > Based on 3.1-rc4
> > >
> > > Signed-off-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
> > 
> > Yep, this appears to fix it!  Hopefully Francis can confirm.
> > 
> > Greg, ideally apply this additional fix rather than do the revert
> > of the original patch suggested in https://lkml.org/lkml/2011/9/13/234
> > 
> > Acked-by: Dan Magenheimer <dan.magenheimer@oracle.com>
> 
> 
> Greg, Francis has confirmed offlist that Seth's fix below
> has fixed his issue as well.  Please apply, hopefully as
> soon as possible and before 3.1 goes final!

Due to the loss of kernel.org, it might miss it, but don't worry, that's
what stable kernel releases are for :)

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
