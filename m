Date: Fri, 24 Feb 2006 20:59:19 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] [RFC] for_each_page_in_zone [1/1]
Message-Id: <20060224205919.eee6745c.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20060224105220.GA1662@elf.ucw.cz>
References: <20060224171518.29bae84b.kamezawa.hiroyu@jp.fujitsu.com>
	<20060224105220.GA1662@elf.ucw.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pavel Machek <pavel@ucw.cz>
Cc: linux-mm@kvack.org, haveblue@us.ibm.com
List-ID: <linux-mm.kvack.org>

On Fri, 24 Feb 2006 11:52:20 +0100
Pavel Machek <pavel@ucw.cz> wrote:

> > This patch is against 2.6.16-rc4-mm1 and has no dependency to other pathces.
> > I did compile test and booted, but I don't have a hardware which touches codes
> > I modified. so...please check.
> 
> Patch looks good to me. I'll try it later today.
> 
Thank you!

> > Signed-Off-By: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > 
> > Index: testtree/include/linux/mmzone.h
> > ===================================================================
> > --- testtree.orig/include/linux/mmzone.h
> > +++ testtree/include/linux/mmzone.h
> > @@ -472,6 +472,26 @@ extern struct pglist_data contig_page_da
> >  
> >  #endif /* !CONFIG_NEED_MULTIPLE_NODES */
> >  
> > +/*
> > + * these function uses suitable algorythm for each memory model
> 
> "These functions use suitable algorithm for each memory model"?
> 
Yes (>_<....

--Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
