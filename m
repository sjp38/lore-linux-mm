Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 52A6B6B0169
	for <linux-mm@kvack.org>; Thu,  4 Aug 2011 18:12:36 -0400 (EDT)
Date: Thu, 4 Aug 2011 15:11:31 -0700
From: Greg KH <gregkh@suse.de>
Subject: Re: [PATCH] zcache: Fix build error when sysfs is not defined
Message-ID: <20110804221131.GA1401@suse.de>
References: <1297484079-12562-1-git-send-email-ngupta@vflare.org>
 <20110804150524.2dcfcecf.rdunlap@xenotime.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110804150524.2dcfcecf.rdunlap@xenotime.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Randy Dunlap <rdunlap@xenotime.net>
Cc: Nitin Gupta <ngupta@vflare.org>, Stephen Rothwell <sfr@canb.auug.org.au>, Andrew Morton <akpm@linux-foundation.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>

On Thu, Aug 04, 2011 at 03:05:24PM -0700, Randy Dunlap wrote:
> On Fri, 11 Feb 2011 23:14:39 -0500 Nitin Gupta wrote:
> 
> > Signed-off-by: Nitin Gupta <ngupta@vflare.org>
> > ---
> >  drivers/staging/zcache/zcache.c |    2 +-
> >  1 files changed, 1 insertions(+), 1 deletions(-)
> > 
> > diff --git a/drivers/staging/zcache/zcache.c b/drivers/staging/zcache/zcache.c
> > index 61be849..8cd3fd8 100644
> > --- a/drivers/staging/zcache/zcache.c
> > +++ b/drivers/staging/zcache/zcache.c
> > @@ -1590,9 +1590,9 @@ __setup("nofrontswap", no_frontswap);
> >  
> >  static int __init zcache_init(void)
> >  {
> > -#ifdef CONFIG_SYSFS
> >  	int ret = 0;
> >  
> > +#ifdef CONFIG_SYSFS
> >  	ret = sysfs_create_group(mm_kobj, &zcache_attr_group);
> >  	if (ret) {
> >  		pr_err("zcache: can't create sysfs\n");
> > -- 
> 
> OMG.  This patch still needs to be applied to linux-next 20110804..........
> sad.

Heh, thanks, I'll queue it up soon.

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
