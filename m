Date: Thu, 05 Jan 2006 14:43:27 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: Re: [Patch] New zone ZONE_EASY_RECLAIM take 4. (disable gfp_easy_reclaim bit)[5/8]
In-Reply-To: <43BAEDDD.8080805@austin.ibm.com>
References: <20051220173013.1B10.Y-GOTO@jp.fujitsu.com> <43BAEDDD.8080805@austin.ibm.com>
Message-Id: <20060105144247.491D.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: jschopp@austin.ibm.com
Cc: Linux Kernel ML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Linux Hotplug Memory Support <lhms-devel@lists.sourceforge.net>
List-ID: <linux-mm.kvack.org>

> 
> > ===================================================================
> > --- zone_reclaim.orig/fs/pipe.c	2005-12-16 18:36:20.000000000 +0900
> > +++ zone_reclaim/fs/pipe.c	2005-12-16 19:15:35.000000000 +0900
> > @@ -284,7 +284,7 @@ pipe_writev(struct file *filp, const str
> >  			int error;
> >  
> >  			if (!page) {
> > -				page = alloc_page(GFP_HIGHUSER);
> > +				page = alloc_page(GFP_HIGHUSER & ~__GFP_EASY_RECLAIM);
> >  				if (unlikely(!page)) {
> >  					ret = ret ? : -ENOMEM;
> >  					break;
> 
> That is a bit hard to understand.  How about a new GFP_HIGHUSER_HARD or 
> somesuch define back in patch 1, then use it here?

It looks better. Thanks for your idea.

-- 
Yasunori Goto 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
